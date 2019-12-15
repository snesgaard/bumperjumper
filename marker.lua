local marker = {}

function marker:__draw()
    gfx.setColor(0.1, 0.2, 0.8)
    gfx.circle("fill", 0, 0, 5)
end

return marker
