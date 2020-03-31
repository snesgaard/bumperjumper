return function(opt, x, y, w, h)
    local color = opt.color or {1, 1, 1}
    gfx.setColor(unpack(color))
    gfx.rectangle("fill", x, y, w, h, 2)
    gfx.setColor(0, 0, 0, 0.6)
    gfx.rectangle("fill", x, y, w, h, 2)
    gfx.setColor(unpack(color))
    local min = opt.min or 0
    local max = opt.max or 1
    local value = opt.value or max
    if value > min then
        local ratio = (value - min) / (max - min)
        gfx.rectangle("fill", x, y, w * ratio, h, 2)
    end
end
