local common = {}

function common.target_marker(args)
    local id = args[1]
    local offset = args.offset or 100
    local marker_type = args.marker
    local speed = args.speed
    local sprite = get_sprite(id)
    local body = get_body(id)
    local key = args.key or "lctrl"
    local check = args.check or constant(false)

    sprite:queue("chant")
    swap_co(join(id, "animation"))

    body.speed.x = 0
    local pos = body.__transform.pos
    local offset = body.__transform.scale.x > 0 and offset or -offset

    local marker = root:child(require(marker_type))
    marker:set_size(body:get_size())
    marker.__transform.pos = pos + vec2(offset, 0)

    local marker_speed = speed
    swap_co(
        "camera_control", camera_control.idle, camera, marker, level
    )

    while love.keyboard.isDown(key) or check(body, marker.__transform.pos) do
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

    marker:destroy()
    return maker.__transform.pos
end


function common.control_idle(id)
    local animation = require "animation"
    local Camera = require "camera"
    local body = get_body(id)
    local sprite = get_sprite(id)
    swap_co(join(id, "animation"), animation.control.idle, body, sprite)
    swap_co("camera_control", Camera.control.idle, camera, body, level)
    while true do
        local dt = event:wait("update")
        local next_speed = 0
        if love.keyboard.isDown("lctrl") then
            local pos = common.target_marker{"wizard"}
            body:warp_to(marker.__transform.pos:unpack())
        end
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

return common
