require "nodeworks"
level_io = require "level"
wizard = require "actor.wizard"
actor = require "actor"
Camera = require "camera"
require "bumpdebug"

local function resolve_overlap(world, body)
    for i = 1, 50 do
        local _, _, col, len = world:check(body)
        if len == 0 then return end
        world:update(body, col[1].touch.x, col[1].touch.y)
    end
end

local function animation_control(body, sprite)
    local context = {prev = nil}

    local function set_animation(key)
        if context.prev ~= key then
            sprite:queue(key)
            context.prev = key
        end
    end

    while true do
        event:wait("update")
        if body.speed.y < 0 then
            set_animation("ascend")
        elseif body.speed.y > 0 then
            set_animation("descend")
        elseif body.speed.x ~= 0 then
            set_animation("run")
        else
            set_animation("idle")
        end
    end
end

local function motion_control(body)
    while true do
        event:wait("update")
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

local function jump_control(body)

end


function love.load()
    level = level_io.load('art/maps/build/test.lua')
    body = Node.create(require "body", level.world)
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

    local co = coroutine.create(animation_control)
    coroutine.resume(co, body, sprite)
    local co = coroutine.create(motion_control)
    coroutine.resume(co, body)

    camera = Camera:create()
end

function love.update(dt)
    tween.update(dt)
    require("lovebird").update()
    event:update(dt)
    event:spin()
    --body.__transform.pos.y = body.__transform.pos.y + 10
    body:update(dt)
    camera:update(dt, body, level)
end

function love.draw()
    local x, y, sx, sy = camera:transform()
    --gfx.scale(sx, sy)
    --gfx.translate(x, y)
    level:draw(x, y, sx, sy)
    body:draw()
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
