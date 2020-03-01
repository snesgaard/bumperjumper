local render = {}

local stack_op = {
    color = gfx.setColor,
    transform = function(t)
        if t.position then
            gfx.translate(t.position.x, t.position.y)
        end
        if t.angle then
            gfx.rotate(t.angle)
        end
        if t.scale then
            gfx.scale(t.scale.x, t.scale.y)
        end
    end
}

function render.enter(node)
    gfx.push("all")

    for key, op in pairs(stack_op) do
        local data = node[key]
        if data then op(data) end
    end
end

function render.exit(node, info)
    if node.post_draw then node:post_draw() end
    gfx.pop("all")
end

function render.visit(node, args)
    local draw = node[args.func or "draw"]
    if draw then draw(node) end

    if args.draw_frame then
        gfx.push("all")
        gfx.setLineWidth(2)
        gfx.setColor(0.2, 1.0, 0.3)
        gfx.line(0, -5, 0, 20)
        gfx.setColor(1.0, 0.3, 0.2)
        gfx.line(-5, 0, 20, 0)
        gfx.pop("all")
    end
end

return render
