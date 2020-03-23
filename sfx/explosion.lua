local sfx = {}

sfx.flash_image = gfx.prerender(200, 200, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
end)

sfx.blur = moon(moon.effects.gaussianblur)
sfx.blur.gaussianblur.sigma = 6.0

sfx.fire_circle_image = gfx.prerender(26, 26, function(w, h)
    gfx.setColor(1, 1, 1)
    --sfx.blur(function()
        gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.25, h * 0.25)
    --end)
end)

sfx.blur.gaussianblur.sigma = 3.0

sfx.smoke_circle_image = gfx.prerender(52, 52, function(w, h)
    gfx.setColor(1, 1, 1)
    sfx.blur(function()
        gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.25, h * 0.25)
    end)
end)

sfx.spark_image = gfx.prerender(20, 6, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
end)

function sfx:create()
    self.flash_circle = {
        image = sfx.flash_image,
        color = {1, 1, 1, 1}
    }

    self.particles = {
        fire=particles{
            image=sfx.fire_circle_image,
            buffer=60,
            rate=0,
            emit=60,
            lifetime={0.35, 0.75},
            color=List.concat(
                gfx.hex2color("ffd541af"),
                gfx.hex2color("f9a31b8f"),
                gfx.hex2color("fa6a0a0f"),
                gfx.hex2color("df3e2300")
            ),
            size={1, 2},
            speed={100, 1000},
            acceleration={0, -600},
            damp=20,
            area={"ellipse", 20, 20, 0, true}
        },
        smoke=particles{
            image=sfx.smoke_circle_image,
            buffer=40,
            rate=0,
            emit=40,
            lifetime={0.35, 0.75},
            color=List.concat(
                gfx.hex2color("6f3e23cf"),
                gfx.hex2color("6d758d00")
            ),
            size={1, 3},
            speed={50, 600},
            acceleration={0, -600},
            damp=5,
            area={"ellipse", 20, 20, 0, true}
        }
    }

    self:fork(self.life)
end


function sfx:life()
    local t = tween(0.1, self.flash_circle.color, {1, 1, 1, 0})
    event:wait(t, "finish")

    local function is_done()
        for _, p in pairs(self.particles) do
            if p:getCount() > 0 then return false end
        end
        return true
    end

    while not is_done() do event:wait("update") end

    if self.on_finished then
        self.on_finished()
    end

    self:destroy()
end

function sfx:update(dt)
    for _, p in pairs(self.particles) do p:update(dt) end
end

function sfx:draw()
    gfx.setColor(self.flash_circle.color)
    local im = self.flash_circle.image
    gfx.draw(im, -im:getWidth() * 0.5, -im:getHeight() * 0.5)
    gfx.setColor(1, 1, 1, 0.5)
    gfx.setBlendMode("add")
    gfx.draw(self.particles.smoke, 0, 0)
    gfx.setBlendMode("alpha")
    gfx.setColor(1, 1, 1, 0.2)
    gfx.draw(self.particles.fire, 0, 0)
end

function sfx:glow()
    gfx.setColor(1, 1, 1)
    gfx.draw(self.particles.fire, 0, 0)
end



return sfx
