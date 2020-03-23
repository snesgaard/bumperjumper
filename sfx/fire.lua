local fire = {}

function fire:create()
    local atlas = get_atlas("art/particles")
    local frames = atlas:get_animation("fire")

    local buffer = 30
    local rate = 7

    self.particles = list()
    self.smoke = list()

    for _, frame in ipairs(frames) do
        self.particles[#self.particles + 1] = particles{
            image=frame.image,
            quad=frame.quad,
            rate=rate,
            lifetime={2.0, 6.0},
            acceleration={0, -10},
            damp=0.5,
            spread=math.pi * 0.2,
            dir=-math.pi * 0.5,
            speed={30, 60},
            color=List.concat(
                vec4(0.1, 0.1, 0.9, 0.0),
                vec4(1.0, 0.95, 0.5, 0.3),
                vec4(1.0, 0.5, 0.14, 0.2),
                vec4(0.9, 0.1, 0.05, 0.6),
                vec4(0.0, 0, 0, 0.0)
            ),
            area={"uniform", 3, 3},
            --radial_acceleration=-10.0,
            size={1, 2},
        }
    end

    for _, frame in ipairs(frames) do
        self.smoke[#self.smoke + 1] = particles{
            image=frame.image,
            quad=frame.quad,
            rate=rate,
            lifetime={2.0, 4.0},
            acceleration={0, -30},
            damp=1.0,
            spread=math.pi * 0.3,
            dir=-math.pi * 0.5,
            speed={100},
            color=List.concat(
                vec4(0.0, 0.0, 0.0, 0.0),
                vec4(0.36, 0.24, 0.17, 0.6),
                vec4(0.0, 0.0, 0.0, 0.0)
            ),
            area={"uniform", 3, 3},
            radial_acceleration=1.0,
            size={1, 4},
        }
    end

end

function fire:update(dt)
    dt = dt * 3
    for _, p in ipairs(self.particles) do p:update(dt) end
    for _, p in ipairs(self.smoke) do p:update(dt) end
end

function fire:draw()
    for _, p in ipairs(self.smoke) do gfx.draw(p, 0, -20) end
    gfx.setBlendMode("add")
        for _, p in ipairs(self.particles) do gfx.draw(p, 0, 0) end
    gfx.setBlendMode("alpha")
end

function fire:glow()
    for _, p in ipairs(self.particles) do gfx.draw(p, 0, 0) end
end

return fire
