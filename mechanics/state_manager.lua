local function fetch_reactions(epoch)
    -- TODO reaction fetching goes here
    return list()
end


local function invoke_transforms(state, transform, ...)
    local function invoke(state, func, ...)
        return func(state, ...)
    end

    local history = list()
    local transforms = list({transform, ...})
    local first_info = nil

    while #transforms > 0 do
        local next_transform = transforms:head()
        table.remove(transforms, 1)

        local next_state, info, post_transforms = invoke(
            state, unpack(next_transform)
        )

        first_info = first_info or info

        local id = next_transform[1]
        table.remove(next_transform, 1)
        local epoch = {
            state=next_state, info=info, args=next_transform,
            id=id
        }
        table.insert(history, epoch)

        if post_transforms and #post_transforms > 0 then
            transforms = post_transforms + transforms
        end

        local reactions = fetch_reactions(epoch)

        if reactions and #reactions > 0 then
            transforms = reactions + transforms
        end

        state = next_state or state
    end

    return state, first_info, history
end


local manager = {modules={}}
manager.__index = manager


function manager:state() return self._state end


function manager:broadcast(epoch)
    event(self, epoch.id, epoch.state, epoch.info, unpack(epoch.args))
end


function manager:_call_transform(transform, ...)
    local next_state, info, history = invoke_transforms(
        self:state(), transform, ...
    )
    for _, epoch in ipairs(history) do
        self:broadcast(epoch)
    end

    self._state = next_state

    return next_state, info, history
end


function manager._register_call(method_name, transform)
    local function call(self, ...)
        return self:_call_transform(transform, ...)
    end

    manager[method_name] = call
end

function manager._register_read(method_name, reader)
    local function call(self, ...)
        return reader(self:state(), ...)
    end

    manager[method_name] = call
end


function manager:update(dt)
    for _, module in pairs(manager.modules) do
        if module.update then
            self:_call_transform(module.update, dt)
        end
    end
end

function manager:setup(id, data)
    if not data then
        errorf("No data supplied for %s", id)
    end

    for _, module in pairs(manager.modules) do
        if module.setup then
            self:_call_transform(module.setup, id, data)
        end
    end
end


function manager.register(module)
    local name = module.name or (#manager.modules + 1)

    if manager.modules[name] then
        errorf("Module already exists: %s", tostring(name))
    end
    manager.modules[name] = module

    for name, transform in pairs(module.transform) do
        if type(transform) == "function" then
            manager._register_call(name, transform)
        end
    end

    for name, reader in pairs(module.reader) do
        if type(reader) == "function" then
            local reader_name = "read_" .. name
            manager._register_read(reader_name, reader)
        end
    end
end


function manager.create()
    local this = {_state = State.create()}

    local function gen_structure(root, key, substructure)
        local sub_root = dict()

        for key, subsub in pairs(substructure) do
            gen_structure(sub_root, key, subsub)
        end

        root[key] = sub_root

        return root
    end

    for name, module in pairs(manager.modules) do
        if module.structure then
            local structure = module.structure() or {}

            for key, substructure in pairs(structure) do
                gen_structure(this._state.root, key, substructure)
            end
        end
    end

    return setmetatable(this, manager)
end


function manager:apply_remap(node, remap)
    remap = remap or node.remap

    node._tokens = node._tokens or {}
    for key, func in pairs(remap) do
        local function callback(...)
            func(node, ...)
        end
        node._tokens[key] = event:listen(self, key, callback)
    end

    local on_destroyed = node.on_destroyed

    function node:on_destroyed()
        for _, token in pairs(self._tokens) do
            event:clear(token)
        end

        if on_destroyed then on_destroyed(self) end
    end
end


return manager
