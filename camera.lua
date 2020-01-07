local Camera = {}
Camera.__index = Camera

function Camera:create()
    local this = {
        position = vec2(0, 0),
        scale = vec2(3, 3),
        max_speed = 200,
    }
    return setmetatable(this, Camera)
end

function Camera:get_size()
    return gfx.getWidth() / self.scale.x, gfx.getHeight() / self.scale.y
end

local function get_offset(speed, w, bias)
    if speed > 0 then
        return w * 0.2
    elseif speed < 0 then
        return -w * 0.2
    else
        return bias or 0
    end
end

local function get_max_speed(dt, scale, distance)
    local ad = math.abs(distance)
    return math.max(100, ad * ad * 0.05 * scale / 4.0)
end


function Camera:update(dt, target, level)
    -- First calculate the destination
    local w, h = self:get_size()
    local level_w = level.tilewidth * level.width
    local level_h = level.tileheight * level.height
    local x = target.__transform.pos.x - w * 0.5
    local y = target.__transform.pos.y - h * 0.5
    local speed = target.speed or vec2()
    local ox, oy = get_offset(speed.x, w), get_offset(speed.y, h, -100) * 0 - 50
    local next_pos = vec2(x + ox, y + oy)
    -- next calculate the rate of change
    local d_pos = next_pos - self.position
    -- Just some arbitrary speed limit
    local max_speed = vec2(
        get_max_speed(dt, self.scale.x, d_pos.x),
        get_max_speed(dt, self.scale.y, d_pos.y)
    )
    max_speed = max_speed * 1.5 * dt

    if math.abs(d_pos.x) > max_speed.x then
        d_pos.x = d_pos.x * (max_speed.x / math.abs(d_pos.x))
        x = self.position.x + d_pos.x
    else
        x = next_pos.x
    end

    if math.abs(d_pos.y) > max_speed.y then
        d_pos.y = d_pos.y * (max_speed.y / math.abs(d_pos.y))
        y = self.position.y + d_pos.y
    else
        y = next_pos.y
    end



    -- Clamp to the final map size
    x = math.clamp(x, 0, level_w - w)
    y = math.clamp(y, 0, level_h - h)
    self.position.x = x
    self.position.y = y
end

function Camera:transform()
    local x, y, sx, sy = self:get_transform()
    gfx.scale(sx, sy)
    gfx.translate(x, y)
    return x, y, sx, sy
end

function Camera:get_transform()
    return -self.position.x, -self.position.y, self.scale.x, self.scale.y
end

Camera.control = {}

function Camera.control.idle(camera, body, level)
    while true do
        local dt = event:wait("update")
        camera:update(dt, body, level)
    end
end

return Camera
