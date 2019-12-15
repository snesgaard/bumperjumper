local core = {}

core.base = require "mechanics.base"
core.ailment = require "mechanics.ailments"

-- First update state with expansions and utilities
function state._init()
    local root = dict{}
    core.base.init_state(root)
    core.ailment.init_state(root)

    return root
end

function core.broadcast(...)
    for key, epoch in pairs({...}) do
        event(epoch.id, epoch.state, epoch.info or {}, epoch.args)
    end
end

function core.transform(state, ...)
    local next_state, epic = state:transform(...)
    core.broadcast(data, unpack(epic))
    return next_state, epic
end

function core.init_actor(state, type)
    local id = id_gen.register(type.name or "undefined")
    if type.init_state then
        state, _ = core.transform(state, type.init_state(state, id))
    end
    return state, id
end

function core.remap(node)
    node.__remap_handle = dict()

    if not node.remap then return end

    for key, func in pairs(node.remap or {}) do
        local function f(...) return func(node, ...) end
        node.__remap_handle[key] = event:listen(key, f)
    end

    local f = node.on_destroyed or identity

    function node.on_destroyed(self)
        for _, handle in ipairs(self.__remap_handle) do
            event:clear(handle)
        end
        return f(self)
    end
end

return core
