local src = {}

src.testargs = {spatial(0, 0, 30, 100)}

src.image = gfx.prerender(14, 4, function(w, h)
    gfx.push("all")
    gfx.origin()
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
    gfx.pop("all")
end)

src.acceleration = 600

function src:create(shape, direction)
    self.transform = transform(shape:center():unpack())
    local dx = shape.w * 0.5
    local dy = shape.h * 0.25
    local area = shape.w * shape.h
    local count = area * 0.04
    self.shape = shape
    local r, g, b = 0.2, 0.7, 0.9
    direction = direction or vec2(1, 0)
    local a = src.acceleration * direction:normalize()
    self.particles = particles{
        image=src.image,
        buffer=count,
        emit=count,
        rate=0,
        lifetime=1.5,
        speed={10, 300},
        size=0.5,
        color={
            r, g, b, 0.0,
            r, g, b, 0.15,
            r, g, b, 0.6,
            r, g, b, 0
        },
        acceleration={a.x, a.y},
        damp=4,
        area={"uniform", dx, dy, 0, true},
        relative_rotation=true,
        radial_acceleration = {-150, -300},
        tangential_acceleration = 10,
    }

    self:fork(src.life)
end

function src:life()
    while self.particles:getCount() > 0 do
        event:wait("update")
    end
    self:destroy()
end

function src:update(dt)
    self.particles:update(dt * 6)
end

function src:draw()
    gfx.setBlendMode("add")
    gfx.draw(self.particles, 0, 0)
    gfx.setBlendMode("alpha")
end

src.glow = src.draw

return src
