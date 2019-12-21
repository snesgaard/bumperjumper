local marker = {}

function marker:create()
    self.blur = moon(moon.effects.gaussianblur)
    self.size = vec2(3, 3)
end

function marker:set_size(w, h)
    self.size = vec2(w * 0.5, h * 0.5)
end

function marker:__draw()
    local function draw_shape(mode)
        gfx.ellipse(mode or "fill", 0, -self.size.y, self.size.x, self.size.y)
    end
    local function draw()
        gfx.setColor(0.1, 0.2, 0.8, 0.3)
        gfx.setLineWidth(5)
        draw_shape("line")

        gfx.setColor(0.2, 0.6, 0.8, 0.3)
        draw_shape("fill")
    end

    self.blur(draw)
end

function marker:test()
    self:set_size(25, 75)
end

return marker
