local manager = require(... .. ".state_manager")

local modules = {"damage"}
local out = {}

for _, name in ipairs(modules) do
    local m = require(... .. "." .. name)
    manager.register(m)
    out[name] = m
end

out.manager = manager

return out
