local ball = {}

function ball:create(pos)
    self.transform = transform()
    self.transform.position = pos
end

function ball:draw()
    gfx.setColor(1, 1, 1)
    gfx.circle("line", 0, 0, 10)
end

return ball
