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
    if col.overlaps then
        return cross(world, col, x,y,w,h, goalX, goalY, filter)
    else
        return slide(world, col, x,y,w,h, goalX, goalY, filter)
    end
end

function love.load()
    level = level_io.load('art/maps/build/test.lua')
    level.world:addResponse("better_slide", better_slide)
    --level.world:add("this", 20, 420, 10, 100)
    scene_graph = {
        root = {"body"},
        body = {"hitbox", "hitbox2"}
    }
    nodes = {
        body = graph.node(require "body", level.world, -16, -32, 32, 32)
            :warp(600, 200),
        hitbox = graph.node(require "hitbox", level.world, 0, -20, 20, 20),
        hitbox2 = graph.node(require "hitbox", level.world, 0, -100, 20, 20),
    }
    nodes.body.transform.scale = vec2(2, 2)
    --print(rect.transform.position)
    --print(rect:can_change_shape(-16, -100, 32, 32))
end

local proc = {
    enter = function(node, args)
        args.transforms = args.transforms or list()
        if node.transform then
            table.insert(args.transforms, 1, node.transform)
        end
    end,
    visit = function(node, args)
        if node.update then
            node:update(args.dt, args.transforms)
        end
    end,
    exit = function(node, args, info)
        args.transforms = args.transforms:body()
    end
}

function love.update(dt)
    graph.traverse(scene_graph, nodes, proc, {dt=dt})
    local x, y = level.world:getRect(nodes.body)
    --level.world:move(nodes.body, x, y + 10, constant("better_slide"))
    --nodes.body:relative_move(0, 1)
end

function love.keypressed(key)
    if key == "1" then
        nodes.body.transform.scale = vec2(1, 1)
    elseif key == "2" then
        nodes.body.transform.scale = vec2(2, 2)
    end
end

function love.draw()
    gfx.translate(200, 200)
    draw_world(level.world)
end
