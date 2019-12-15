local level = {}

function level.load(path)
    local world = bump.newWorld()
    local level = sti(path, { "bump" })
    level:bump_init(world)
    level.world = world

    local bg_layer = level:addCustomLayer("bg_layer",1)

    function bg_layer:draw()
        gfx.push()
        gfx.origin()
        gfx.setColor(0.3, 0.3, 0.5)
        gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
        gfx.setColor(1, 1, 1)
        gfx.pop()
    end

    return level
end

level.__call = level.load

return setmetatable(level, level)
