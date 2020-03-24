local settings = {
    range = 200
}

local laser = {}

function laser:create()

end

function laser:find_world()
    local node = self
    while node do
        if node.world then return node, node.world end
        node = node:find("..")
    end
end

function laser:find_level()
    local node = self
    while node do
        if node.level then return node.level end
        node = node:find("..")
    end
end

function laser:draw()
    gfx.setColor(1, 1, 1)
    gfx.rectangle("line", 0, 0, 100, 50)
end

local function query_filter(other)
    if not other.type then
        local prop = other.properties or {}
        if prop.oneway then
            return false
        else
            return true
        end
    end
end

local function phase_filter(self, other)
    if query_filter(other) then
        return "cross"
    end
end

local function find_farthest_possible(token, src, motion, world)
    local function is_valid(s)
        if not world:is_inbound(s) then return false end
        local _, len = world:queryRect(s.x, s.y, s.w, s.h, query_filter)
        return len == 0
    end

    local candidates = list()

    local _, _, col, len = world:check(token, src.x + motion.x, src.y + motion.y, phase_filter)

    local sx = math.sign(motion.x)
    local sy = math.sign(motion.y)

    for i = 1, len do
        local c = col[i]
        local r = c.itemRect
        table.insert(
            candidates,
            spatial(c.touch.x - 1e-10 * sx, c.touch.y - 1e-10 * sy, r.w, r.h)
        )
    end

    table.insert(candidates, src:move(motion:unpack()))

    for i = #candidates, 1, -1 do
        local c = candidates[i]
        if is_valid(c) then return c end
    end

    return src
end

function laser:update()
    local body, world = self:find_world()
    if not body or not level then return end

    local shape = spatial(world:getRect(body))

    local range = settings.range

    local motion = {
        vec2(range, 0),
        vec2(-range, 0),
        vec2(0, range),
        vec2(0, -range),

        vec2(range, range),
        vec2(-range, -range),
        vec2(-range, range),
        vec2(range, -range),
    }

    local collision_shapes = list()

    for _, m in ipairs(motion) do
        local target = find_farthest_possible(body, shape, m, world)
        table.insert(collision_shapes, target)
    end

    self.shapes = collision_shapes:map(function(s)
        return s:relative(shape)
    end)

end

local function draw_shape(shape, is_valid)
    if is_valid then
        gfx.setColor(0.1, 0.9, 0.6)
    else
        gfx.setColor(0.9, 0.2, 0.1)
    end
    gfx.rectangle("line", shape:unpack())
end

function laser:draw()
    if not self.shapes then return end

    gfx.push()

    for index, shape in ipairs(self.shapes) do
        draw_shape(shape, true)
    end

    gfx.pop()
end

local function teleport(scene_graph, id)
    local body = scene_graph:get_body(id)
    local sprite = scene_graph:get_sprite(id)
    local spell = require "spell"

    if not body then
        errorf("Could not find body for %s", id)
    end

    local function get_motion()
        local left = love.keyboard.isDown("left")
        local right = love.keyboard.isDown("right")
        local up = love.keyboard.isDown("up")
        local down = love.keyboard.isDown("down")

        if left == right and up == down then
            return vec2(body.transform.scale.x, 0)
        elseif up ~= down then
            return up and vec2(0, -1) or vec2(0, 1)
        else
            return left and vec2(-1, 0) or vec2(1, 0)
        end
    end

    --local motion = vec2(motion_x(), motion_y())
    local motion = get_motion()
    motion = settings.range * motion
    local world = body.world
    local shape = spatial(world:getRect(body))
    local destination = find_farthest_possible(body, shape, motion, world)

    body.velocity.x = 0
    body.velocity.y = 0
    body:set_gravity(vec2(0, 0))

    coroutine.on_cleanup(function()
        body:set_gravity()
        sprite.color = nil
        sprite.blend = nil
    end)

    sprite.color = color(0, 0, 0, 0)
    sprite.blend = "add"
    sprite:play("chant")

    body:warp(destination:centerbottom():unpack())

    local zap_sfx = require "sfx.teleport.zap"
    local src_sfx = require "sfx.teleport.src"
    scene_graph:child(zap_sfx, shape:center(), destination:center())
    scene_graph:child(src_sfx, shape, motion)

    local t = tween(0.3, sprite.color, color(1, 1, 3, 1))
    event:wait(t, "finish")
    --sprite.color = color(0, 0, 0, 0)

    coroutine.cleanup()

    return spell.idle.control(scene_graph, id)
end

return {
    settings = settings,
    teleport = teleport,
    laser = laser
}
