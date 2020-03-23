local fire = {}

fire.spark_image = gfx.prerender(14, 4, function(w, h)
    gfx.push()
    gfx.origin()
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w / 2, h / 2, w / 2, h / 2)
    gfx.pop()
end)

fire.rate = 2

function fire:create()
    local atlas = get_atlas("art/particles")
    local frames = atlas:get_animation("fire")

    local buffer = 30
    local rate = fire.rate

    self.particles = list()

    for _, frame in ipairs(frames) do
        self.particles[#self.particles + 1] = particles{
            image=frame.image,
            quad=frame.quad,
            rate=rate,
            emit=5,
            lifetime={4.0, 6.0},
            acceleration={0, -3},
            damp=0.5,
            spread=math.pi * 0.5,
            dir=-math.pi * 0.5,
            speed={3, 6},
            color=List.concat(
                vec4(0.1, 0.1, 0.9, 0.0),
                vec4(1.0, 0.95, 0.5, 0.3),
                vec4(1.0, 0.5, 0.14, 0.2),
                vec4(0.9, 0.1, 0.05, 0.3),
                vec4(1.0, 0, 0, 0.0)
            ),
            offset={frame.offset.x, frame.offset.y},
            area={"uniform", 1, 1},
            size={0.2, 0.75},
        }
    end

    self.particles.sparks = particles{
        image=fire.spark_image,
        buffer=20,
        rate=0,
        area={"uniform", 2, 2},
        spread=math.pi * 0.45,
        lifetime={1},
        dir=-math.pi * 0.5,
        acceleration={0, 100},
        color = List.concat(
            vec4(0.93, 0.87, 0.13, 0.8),
            vec4(0.93, 0.87, 0.13, 1.0),
            vec4(0.93, 0.87, 0.13, 0.0)
        ),
        speed={50, 100},
        size=0.35,
        relative_rotation=true
    }
end

function fire:halt()
    local function is_done()
        for _, p in ipairs(self.particles) do
            if p:getCount() ~= 0 then return false end
        end
        return true
    end

    self:fork(function(self)
        for _, p in ipairs(self.particles) do p:stop() end
        while not is_done() do
            event:wait("update")
        end
        self:destroy()
    end)
end

function fire:set_level(level)
    self.level = level
    self:child(require "sfx.ping", vec4(0.94, 0.35, 0.05, 0.88))
    if self.level >= 3 then
        self.particles.sparks:setEmissionRate(fire.rate * 4)
    end
end

function fire:get_speed()
    local level = self.level or 1
    if level == 1 then
        return 7
    elseif level == 2 then
        return 14
    else
        return 28
    end
end

function fire:update(dt)
    self.particles.sparks:update(dt * 2)
    dt = dt * self:get_speed()
    for _, p in ipairs(self.particles) do p:update(dt) end
end

function fire:draw()
    gfx.setBlendMode("add")
    for _, p in ipairs(self.particles) do gfx.draw(p, 0, 0) end
    gfx.draw(self.particles.sparks, 0, -5)
    gfx.setBlendMode("alpha")
end

function fire:glow()
    gfx.draw(self.particles.sparks, 0, -5)
    for _, p in ipairs(self.particles) do gfx.draw(p, 0, 0) end
end

return fire
