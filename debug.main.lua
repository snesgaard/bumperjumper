require "nodeworks"
level_io = require "level"
wizard = require "actor.wizard"
actor = require "actor"
Camera = require "camera"
mechanics = require "mechanics"
local animation = require "animation"
require "bumpdebug"

local function better_slide(world, col, x,y,w,h, goalX, goalY, filter)
    local slide = world.responses.slide
    local cross = world.responses.cross
    print(col.ti, x, y, goalX, goalY)
    if col.overlaps then
        return cross(world, col, x,y,w,h, goalX, goalY, filter)
    else
        return slide(world, col, x,y,w,h, goalX, goalY, filter)
    end
end

function love.load()
    level = level_io.load('art/maps/build/test.lua')
    level.world:addResponse("better_slide", better_slide)
    level.world:add("this", 372, 200, 10, 100)
    --level.world:move("this", 272, 330, constant("better_slide"))
    --level.world:move("this", 282, 200, constant("better_slide"))
    --level.world:move("this", 282, 600, constant("better_slide"))
    --level.world:addResponse('bounce', bounce)
end

function love.update()
    --local x, y = level.world:getRect("this")
    --level.world:move("this", x, y + 10, constant("better_slide"))
end

function love.draw()
    draw_world(level.world)
end
