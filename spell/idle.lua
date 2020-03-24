local blast = require "spell.blast"
local teleport = require "spell.teleport"

local idle = {}

idle.settings = {
    jump_key = "space",
    teleport_key = "lshift"
}

function idle.animation_id(id)
    return join("animation", id)
end

function idle.motion_controls(body, key)
    local speed = 0
    if love.keyboard.isDown("left") then
        speed = speed - 1
    end
    if love.keyboard.isDown("right") then
        speed = speed + 1
    end
    if speed ~= 0 then
        body.transform.scale.x = speed
    end

    body.velocity.x = 200 * speed
end

function idle.jump(body)
    body.velocity.y = body.jump_speed or 0
end

function idle.to_int(bool)
    return bool and 1 or 0
end

function idle.set_orientation(body)
    local s = 0
    s = s + to_int(love.keyboard.isDown("right"))
    s = s - to_int(love.keyboard.isDown("left"))
    if s ~= 0 then
        body.transform.scale.x = s
    end
end

function idle.animation_control(scene_graph, id)
    local body = scene_graph:get_body(id)
    local sprite = scene_graph:get_sprite(id)
    while true do
        if body.velocity.y < 0 then
            sprite:play("ascend")
        elseif body.velocity.y > 0 then
            sprite:play("descend")
        elseif body.velocity.x ~= 0 then
            sprite:play("run")
        else
            sprite:play("idle")
        end
        event:wait("update")
    end
end

function idle.can_jump(body)
    return body.on_ground
end

function idle.interrupt(token, msg_key, body, key)
    print(key, idle.settings.jump_key, idle.settings.teleport_key)
    if key == idle.settings.jump_key and idle.can_jump(body) then
        event(token ,msg_key, idle.control_with_jump)
        return true
    elseif key == idle.settings.teleport_key then
        local spell = require "spell"
        event(token, msg_key, spell.teleport.teleport)
        return true
    end
end

function idle.control_with_jump(scene_graph, id)
    return idle.control(scene_graph, id, true)
end

function idle.control(scene_graph, id, init_jump)
    local body = scene_graph:get_body(id)
    local spell = require "spell"
    if not body then
        errorf("Could no locate body for %s", id)
    end

    coroutine.set(idle.animation_id(id), idle.animation_control, scene_graph, id)
    local token = event:listen("update", curry(idle.motion_controls, body))

    coroutine.on_cleanup(function()
        event:clear(token)
        coroutine.set(idle.animation_id(id))
    end)

    if init_jump and idle.can_jump(body) then
        idle.jump(body)
    end

    while true do
        local key = event:wait("keypressed")
        if key == "space" and body.on_ground then
            if love.keyboard.isDown("down") then
                body:relative_move(0, 1, true)
            else
                idle.jump(body)
            end
        elseif key == "a" then
            coroutine.cleanup()
            return actor.cast(scene_graph, id)
        elseif key == "d" then
            coroutine.cleanup()
            return spell.blast.control(scene_graph, id, "d")
        elseif key == "lshift" then
            coroutine.cleanup()
            return spell.teleport.teleport(scene_graph, id)
        end
    end
end

return idle
