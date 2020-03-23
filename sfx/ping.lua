local ping = {}

function ping:create(base_color)
    self.radius = 0
    self.color = {base_color[1], base_color[2], base_color[3], 1}
    self.thick = 3

    self:fork(ping.life)
end

function ping:life()
    local t = tween(
        0.15,
        self.color, {[4] = 0},
        self, {radius=50}
    )
    event:wait(t, "finish")
    self:destroy()
end

function ping:draw()
    gfx.setLineWidth(self.thick)
    gfx.circle("line", 0, 0, self.radius)
end

ping.testargs = {vec4(0.15, 0.8, 0.87, 0.9)}

return ping
