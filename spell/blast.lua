local settings = {
    charge_time = 0.75
}

local blast = {}

blast.hitbox = spatial(0, 0, 80, 80):relative(nil, "center")

function blast:create(position)
    self.transform = transform(position.x, position.y)
end

function blast:on_adopted()
    self:fork(self.life)
end

function blast:life(world)
    local hitbox = self:child("hitbox", require "collision.hitbox", blast.hitbox:unpack())
    self:child("sfx", require "sfx.explosion")
    event:sleep(0.1)
    hitbox:destroy()
    --self:destroy()
end

local function control(scene_graph, id, action_key)
    local body = scene_graph:get_body(id)
    local sprite = scene_graph:get_sprite(id)
    local spell = require "spell"

    local context = {
        time=settings.charge_time, level=1, tokens={}
    }

    if not body then
        errorf("Could not find body for %s", id)
    end

    sprite:queue("idle2chant", "chant")

    body.velocity.x = 0

    local token = event:listen("keypressed", function(key)
        if key == "left" then
            body.transform.scale.x = -1
        elseif key == "right" then
            body.transform.scale.x = 1
        end
    end)

    local sfx_token = event:once(sprite, "slice/chant", function(slice)
        context.handfire = sprite:child(require "sfx/handfire")
        context.handfire.transform = transform(slice:centerbottom():unpack())
        context.handfire:set_level(context.level)
    end)

    coroutine.on_cleanup(function()
        event:clear(token)
        event:clear(sfx_token)
        for _, node in pairs(context) do
            if type(node) == "table" and node.halt then
                node:halt()
            end
        end
    end)

    while love.keyboard.isDown(action_key) do
        local dt = event:wait("update")
        context.time = context.time - dt
        if context.time < 0 then
            context.time = context.time + settings.charge_time
            context.level = context.level + 1
            if context.handfire and context.level <= 3 then
                context.handfire:set_level(context.level)
            end
        end
    end

    coroutine.cleanup()

    sprite:queue("chant2cast", "cast")

    local token = event:once(sprite, "slice/cast/global", function(slice)
        local sx = body.transform.scale.x
        local xself = sx > 0 and "left" or "right"
        local xother = sx > 0 and "right" or "left"
        local center = blast.hitbox:align(slice, xself, xother, "center", "center"):center()
        local effect = scene_graph:child(blast, center)
        if context.level == 1 then
            effect.transform.scale = vec2(0.3, 0.3)
        elseif context.level == 2 then
            effect.transform.scale = vec2(0.6, 0.6)
        end
    end)

    coroutine.on_cleanup(function()
        event:clear(token)

        for _, token in pairs(context.tokens) do
            event:clear(token)
        end
    end)

    while event:wait(sprite, "finish") ~= "chant2cast" do end

    event:sleep(0.2)

    sprite:queue("cast2idle", "idle")

    local next_token = {}

    context.tokens.animation = event:listen(sprite, "finish", function(key)
        if key == "cast2idle" then
            event(next_token, "next", spell.idle.control)
            return true
        end
    end)
    context.tokens.interrupt = event:listen("keypressed", function(key)
        return spell.idle.interrupt(next_token, "next", body, key)
    end)

    local next_action = event:wait(next_token, "next")

    coroutine.cleanup()

    return next_action(scene_graph, id)
end

return {
    control=control,
    effect=blast
}
