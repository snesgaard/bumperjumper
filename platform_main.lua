require "nodeworks"
level_io = require "level"
wizard = require "actor.wizard"
actor = require "actor"
Camera = require "camera"
mechanics = require "mechanics"
local animation = require "animation"
require "bumpdebug"

local root = Node.create()

local context = {}

function swap_co(name, func, ...)
    if context[name] then
        local prev_co = context[name]
        event:clear(prev_co)
        context[name] = nil
    end

    if func then
        local co = coroutine.create(func)
        context[name] = co
        coroutine.resume(co, ...)
    end
end

local camera_control = {}

function camera_control.idle(camera, body, level)
    while true do
        local dt = event:wait("update")
        camera:update(dt, body, level)
    end
end

local player_control = {}

function player_control.idle(body, sprite)
    coroutine.set("player_animation", animation.control.idle, body, sprite)

    coroutine.set("camera_control", camera_control.idle, camera, body, level)
    while true do
        local dt = event:wait("update")
        if love.keyboard.isDown("lctrl") then
            return player_control.teleport(body, sprite, dt)
        end
        local next_speed = 0
        if love.keyboard.isDown("left") then
            next_speed = next_speed - 200
        end
        if love.keyboard.isDown("right") then
            next_speed = next_speed + 200
        end
        if next_speed > 0 then
            body.__transform.scale.x = 1
        elseif next_speed < 0 then
            body.__transform.scale.x = -1
        end
        body.speed.x = next_speed
    end
end

function player_control.teleport(body, sprite, dt)
    coroutine.set("player_animation")
    sprite:queue("chant")
    body.speed.x = 0
    local pos = body.__transform.pos
    local offset = body.__transform.scale.x > 0 and 100 or -100

    local marker = root:child(require "marker")
    marker:set_size(body:get_size())
    marker.__transform.pos = pos + vec2(offset, 0)
    local marker_speed = 300

    coroutine.set("camera_control", camera_control.idle, camera, marker, level)

    log.debug("Inter telepor %s", tostring(coroutine.running()))
    coroutine.on_cleanup(function()
        marker:destroy()
    end)

    while love.keyboard.isDown("lctrl") or not body:can_warp_to(marker.__transform.pos:unpack()) do
        event:wait("update")
        local marker_motion = vec2(0, 0)
        local dir = {
            up = vec2(0, -1), down = vec2(0, 1),
            right = vec2(1, 0), left = vec2(-1, 0)
        }
        for k, d in pairs(dir) do
            if love.keyboard.isDown(k) then
                marker_motion = marker_motion + d
            end
        end
        marker_motion = marker_motion * marker_speed * dt
        marker.__transform.pos = marker.__transform.pos + marker_motion

        if marker.__transform.pos.x < body.__transform.pos.x then
            body.__transform.scale.x = -1
        else
            body.__transform.scale.x = 1
        end
    end

    body:warp_to(marker.__transform.pos:unpack())
    coroutine.cleanup()

    return player_control.idle(body, sprite)
end



function love.load()
    level = level_io.load('art/maps/build/test.lua')
    body = root:child(require "body", level.world)
    body.__transform.scale = vec2(1, 1)
    body.__transform.pos = vec2(100, 100)
    sprite = body:child(Sprite, wizard.animations, wizard.atlas)
    sprite:queue("ascend")
    -- TODO:
    -- Alignment should happen to the intial frame of the animation
    -- Not the current. The first frame should be idle position, will thus tell
    -- How to get from one coordinate system to the other
    event:listen(sprite, "slice/body", function(_, hitbox, frame_id)
        sprite.__transform.pos.x = -hitbox.x - hitbox.w * 0.5
        sprite.__transform.pos.y = -hitbox.h - hitbox.y
        body:set(hitbox.w, hitbox.h)
        body.frame_id = frame_id
    end)

    camera = Camera:create()

    coroutine.set("player_control", player_control.idle, body, sprite)

    ui = Node.create(require "ui.char_bar")
    mechanics.remap(ui)

    play_state = state.create()
    play_state, id = mechanics.init_actor(play_state, wizard)

    ui:set_id(id):update(play_state)
    log.debug("Ready")
end

function love.update(dt)
    tween.update(dt)
    require("lovebird").update()
    event:update(dt)
    event:spin()
    --body.__transform.pos.y = body.__transform.pos.y + 10
    root:update(dt)
    --camera:update(dt, body, level)
end

function love.draw()
    gfx.setColor(1, 1, 1)
    local x, y, sx, sy = camera:transform()
    --gfx.scale(sx, sy)
    --gfx.translate(x, y)
    level:draw(x, y, sx, sy)
    root:draw()
    gfx.origin()
    ui:draw(50, 50)
    --draw_world(level.world)
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "a" then
        sprite:queue("chant")
    elseif key == "lshift" then
        body:warp(100, 0)
    elseif key == "s" then
        sprite:queue("cast")
    elseif key == "space" then
        body.speed.y = -300
    elseif key == "w" then
        sprite:queue("idle")
    end
end
