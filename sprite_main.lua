mechanics = require "mechanics"
update = require "update"
render = require "render"
level_io = require "level"
collision = require "collision"
Camera = require "camera"
actor = require "actor"
require "update_coroutine"
require "bumpdebug"
local teleport = require "spell.teleport"

context = {}

local function init_wizard(world)
    body = Node.create(require "collision.body", world)

    local sprite = body:child(
        "sprite",
        Sprite,
        actor.wizard.animations,
        actor.wizard.atlas
    )
    --body:child("laser", teleport.laser)

    sprite:queue("idle")
    local body_shape = sprite:get_animation("run"):head().slices.body
    body:reshape(body_shape:relative():unpack())
    body.transform.scale = vec2(1, 1)
    body.transform.position = vec2(200, 200)
    local grav_y, jump_speed = collision.Body.jump_curve(110, 0.4)
    body.jump_speed = jump_speed
    body.default_gravity = vec2(0, grav_y)
    body:set_gravity(vec2(0, grav_y))


    sprite.on_slice_update = curry(collision.sprite_hitbox_sync, body)

    return body
end

local wizard_id = "wizard"

function love.load()
    local t = dict{5, 3, 1, foo=3, bar=5}

    Sprite.default_origin = "body"

    atlas = get_atlas("art/characters")

    level = level_io.load('art/maps/build/lab.lua')
    world = level.world
    collision.init(world)
    scene_graph = Node.create(require "scene_graph")
    scene_graph.world = world
    print(dict(world))
    scene_graph.level = level
    scene_graph:init_actor(wizard_id, init_wizard, world)
    scene_graph:init_actor("box", require "actor.box", world, spatial(0, 0, 24, 90))

    scene_graph:get_body("box").transform.position = vec2(600, 100)

    coroutine.set("player_control", actor.control, scene_graph, wizard_id)
    camera = Camera.create()
end

function love.keypressed(key, scancode, isrepeat)
    event("keypressed", key)
end


function love.update(dt)
    event("update", dt)
    scene_graph:traverse(update, {dt = dt})
    camera:update(dt, scene_graph:get_body(wizard_id), level)
    event:spin()
    tween.update(dt)
    require("lovebird").update()
end

function love.draw()
    level:draw(camera:get_transform())
    --gfx.scale(sx, sy)
    --gfx.translate(x, y)
    camera:transform()
    --scene_graph:traverse(render, {draw_frame=false})
    render.fullpass(scene_graph)
    --draw_world(world)
end
