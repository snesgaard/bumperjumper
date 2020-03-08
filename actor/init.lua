local function animation_id(id)
    return join("animation", id)
end

local function motion_controls(body, key)
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

local function jump(body)
    body.velocity.y = body.jump_speed or 0
end

local function to_int(bool)
    return bool and 1 or 0
end

local function set_orientation(body)
    local s = 0
    s = s + to_int(love.keyboard.isDown("right"))
    s = s - to_int(love.keyboard.isDown("left"))
    if s ~= 0 then
        body.transform.scale.x = s
    end
end

local actor = {}

function actor.idle_animation(scene_graph, id)
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

function actor.cast(scene_graph, id)
    local body = scene_graph:get_body(id)
    local sprite = scene_graph:get_sprite(id)

    set_orientation(body)

    local press_token = event:listen("keypressed", function(key)
        if key == "left" then
            body.transform.scale.x = -1
        elseif key == "right" then
            body.transform.scale.x = 1
        end
    end)

    local ground_token = event:listen(body, "ground", function()
        body.velocity.x = 0
    end)

    coroutine.on_cleanup(function()
        event:clear(press_token)
        event:clear(ground_token)
    end)

    sprite:queue("idle2chant", "chant")
    while love.keyboard.isDown("a") do
        event:wait("update")
    end

    event:clear(press_token)

    sprite:queue("chant2cast", "cast")

    local token = event:once(sprite, "slice/cast/global", function(slice)
        local center = slice:center()
        local root = scene_graph:find("actors")
        local id = join("firebal", lume.uuid())
        root:child(id, require "fireball", center, body.transform.scale.x)
    end)

    event:wait(sprite, "finish")

    event:sleep(0.1)

    coroutine.set(animation_id(id), function()
        event:sleep(0.3)
        sprite:queue("cast2idle", "idle")
    end)

    coroutine.cleanup()

    local token = {}
    local press_token = event:listen("keypressed", function(key)
        if key == "space" then
            event(token, "do_exit", true)
            return true
        end
    end)
    local finish_token = event:listen(sprite, "finish", function(name)
        if name == "cast2idle" then
            event(token, "do_exit")
            return true
        end
    end)
    local ground_token = event:listen(body, "ground", function()
        body.velocity.x = 0
    end)

    coroutine.on_cleanup(function()
        event:clear(press_token)
        event:clear(finish_token)
        event:clear(ground_token)
    end)

    local should_jump = event:wait(token, "do_exit")
    if should_jump then jump(body) end

    coroutine.cleanup()

    return actor.control(scene_graph, id)
end

function actor.control(scene_graph, id)
    local body = scene_graph:get_body(id)
    if not body then
        errorf("Could no locate body for %s", id)
    end
    coroutine.set(animation_id(id), actor.idle_animation, scene_graph, id)

    local token = event:listen("update", curry(motion_controls, body))

    coroutine.on_cleanup(function()
        event:clear(token)
        coroutine.set(animation_id(id))
    end)

    while true do
        local key = event:wait("keypressed")
        if key == "space" and body.on_ground then
            if love.keyboard.isDown("down") then
                body:relative_move(0, 1, true)
            else
                jump(body)
            end
        elseif key == "a" then
            coroutine.cleanup()
            return actor.cast(scene_graph, id)
        end
    end
end

function actor:__index(key, value)
    return require(join("actor", key))
end

return setmetatable(actor, actor)
