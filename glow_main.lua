render = require "render"

local blur = moon(moon.effects.gaussianblur)
blur.gaussianblur.sigma = 10

local function draw_box(x, y, w, h)
    return function()
        gfx.rectangle("fill", x, y, w, h)
    end
end

local function draw_circle(x, y, r)
    return function()
        gfx.circle("fill", x, y, r)
    end
end

function love.load()
    scene_graph = {
        root = {"red_box", "green_box", "blue_box", "orange_cicle"}
    }
    nodes = {
        red_box = {
            transform = {
                position = vec2(100, 100)
            },
            color = color(1.0, 0.1, 0.2),
            draw = draw_box(0, 0, 50, 30),
            glow = draw_box(0, 0, 50, 30),
        },
        green_box = {
            transform = {
                position = vec2(150, 100)
            },
            color = color(0.2, 1.0, 0.2),
            draw = draw_box(0, 0, 50, 30),
            glow = draw_box(0, 0, 50, 30),
        },
        blue_box = {
            transform = {
                position = vec2(125, 130)
            },
            color = color(0.2, 0.1, 1.0),
            draw = draw_box(0, 0, 50, 30),
            glow = draw_box(0, 0, 50, 30),
        },
        orange_cicle = {
            transform = {
                position = vec2(150, 100)
            },
            color = color(0.8, 0.6, 0.2),
            draw = draw_circle(0, 0, 25),
            glow = draw_circle(0, 0, 25)
        },
        sprite = graph.node(Sprite, ...)
    }
end

function love.draw()
    gfx.setBlendMode("alpha")
    graph.traverse(scene_graph, nodes, render)
    gfx.setBlendMode("add")
    blur(function()
        graph.traverse(scene_graph, nodes, render,  {func="glow"})
    end)
end
