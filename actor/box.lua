local sprite = {}

function sprite:create(shape)
    self.shape = shape
end

function sprite:draw()
    gfx.setColor(1, 1, 1)
    gfx.rectangle("fill", self.shape:unpack())
end

local function ai_knockback(boxbody, dir)
    local token = event:listen(boxbody, "side", function(nx, ny)
        local vx = boxbody.velocity.x
        boxbody.velocity.x = 0.5 * math.abs(vx) * nx
    end)

    coroutine.on_cleanup(function()
        event:clear(token)
    end)

    dir = dir or 1
    boxbody.velocity.x = 1000 * dir
    boxbody.velocity.y = -200
    event:wait("update")
    event:wait("update")
    event:wait(boxbody, "ground")
    boxbody.velocity.x = 0
    coroutine.cleanup()
end

return function(world, shape)
    local boxbody = Node.create(collision.Body, world, shape:unpack())
    boxbody:child("sprite", sprite, shape)
    local hurtbox = boxbody:child("hurtbox", collision.Hitbox, shape:unpack())
    hurtbox.faction = "enemy"
    function hurtbox:knockback(dir)
        coroutine.set("box", ai_knockback, boxbody, dir)
    end
    return boxbody
end
