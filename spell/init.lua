print(...)

local includes = {
    "idle", "teleport", "blast"
}

local modules = {}

for _, name in ipairs(includes) do
    modules[name] = require(string.format("%s.%s", ..., name))
end

return modules
