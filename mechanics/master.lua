local master = {}
master.__index = master

function master.register(name, method)
    if master[name] then
        error(string.format("Name already taken: %s", name))
    end

    master[name] = function(self, ...)
        local state, info = method(self._state, ...)
        event(self, method, state, info, ...)
        self._state = state
        return state, info
    end
end

function master.create()
    return setmetatable(state(), master)
end

return master
