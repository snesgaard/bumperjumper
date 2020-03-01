local fireball = {}

function fireball:create(pos, dir)
    self.transform = transform()
    self.transform.position = pos
    self.velocity = vec2(500, 0) * dir
    self:child("hitbox", collision.Hitbox, -5, -5, 10, 10)
    local hitbox = self:find("hitbox")

    function hitbox.on_collision(col)
        local other = col.other
        local prop = other.properties or {}
        if (not other.type and not prop.oneway) or other.faction == "enemy" then
            self.velocity.x = 0
            hitbox:destroy()
            self:child("explosion", require "sfx.explosion")
            self.impact = true
            local node = self:find("explosion")
            function node.on_finished()
                self:destroy()
            end

            if other.knockback then
                other:knockback(-col.normal.x)
            end
        end
    end
end

function fireball:update(dt)
    self.transform.position = self.transform.position + self.velocity * dt
end

function fireball:draw()
    if not self.impact then
        gfx.setColor(1, 1, 1)
        gfx.circle("line", 0, 0, 10)
    end
end

return fireball
