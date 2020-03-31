update = require "update"
render = require "render"
require "bumpdebug"

function reload(p)
    package.loaded[p] = nil
    return require(p)
end

function love.load(arg)
    nodes = Node.create()
    nodes.world = bump.newWorld(64)
    --gfx.setBackgroundColor(0.2, 0.3, 0.4, 1)
    gfx.setBackgroundColor(0, 0, 0, 0)

    event = EventServer()

    settings = {origin = false, scale=2}

    local function init_node(nodes, Type)
        local args = Type.testargs
        if type(args) == "function" then
            return nodes:child(Type, args())
        elseif type(args) == "table" then
            return nodes:child(Type, unpack(args))
        else
            return nodes:child(Type, args)
        end
    end

    local function creation(path_base)
        local component = path_base:split(':')
        local path = component:head()
        local keys = component:body()
        local p = path:gsub('.lua', '')
        local t = reload(p)

        if #keys == 0 then
            local n = init_node(nodes, t)
            if n.test then
                n:fork(n.test, settings)
            end
        else
            for _, key in ipairs(keys) do
                local n = init_node(nodes, t[key])
                if n.test then
                    n:fork(n.test, settings)
                end
            end
        end
    end

    for _, p in ipairs(arg) do
        creation(p)
    end

    function reload_scene()
        love.load(arg)
    end

    function lurker.preswap(f)
        f = f:gsub('.lua', '')
        package.loaded[f] = nil
    end
    function lurker.postswap(f)
        reload_scene()
    end

    event:listen("keypressed", function(key)
        if key == "tab" then reload_scene() end
    end)

    dress = suit.new()
    --gfx.setBackgroundColor(0.5, 0.5, 0.5)

end

local combo = {value = 1, items = {'A', 'B', 'C'}}

local slider_state = {value=75, min=0, max=100, step=20}

local tvec = vec2(0, 0)

function love.update(dt)
    require("lovebird").update()
    local step = dt * 100
    if not settings.disable_navigation then
        if love.keyboard.isDown("left") then
            tvec.x = tvec.x + step
        end
        if love.keyboard.isDown("right") then
            tvec.x = tvec.x - step
        end
        if love.keyboard.isDown("up") then
            tvec.y = tvec.y + step
        end
        if love.keyboard.isDown("down") then
            tvec.y = tvec.y - step
        end
    end

    if not settings.paused then
        nodes:traverse(update, {dt = dt})
        tween.update(dt)
        lurker:update(dt)
        event:update(dt)
    end
    event:spin()
end

local glow_blur = moon(moon.effects.gaussianblur)
glow_blur.gaussianblur.sigma = 12.0

local function render_scene(nodes)
    nodes:traverse(render, {draw_frame=false})
    if not settings.disable_glow then
        gfx.setBlendMode("add")
        glow_blur(function()
            nodes:traverse(render, {draw_frame=false, func="glow"})
        end)
        gfx.setBlendMode("alpha")
    end
end


function love.draw()
    local w, h = gfx.getWidth(), gfx.getHeight()
    gfx.translate(tvec.x, tvec.y)
    gfx.setColor(0.2, 0.3, 0.4, 1)
    gfx.rectangle("fill", 0, 0, w, h)
    gfx.setColor(1, 1, 1)
    gfx.setLineWidth(1)
    gfx.line(0, h / 2, w, h / 2)
    for x = w / 2, w, 100 do
        gfx.line(x, h / 2 - 10, x, h / 2 + 10)
    end
    for x = w / 2, 0, -100 do
        gfx.line(x, h / 2 - 10, x, h / 2 + 10)
    end
    gfx.line(w / 2, 0, w / 2, h)
    for y = h / 2, h, 100 do
        gfx.line(w / 2 - 10, y, w / 2 + 10, y)
    end
    for y = h / 2, 0, -100 do
        gfx.line(w / 2 - 10, y, w / 2 + 10, y)
    end
    if not settings.origin then
        nodes.transform = transform(w / 2, h / 2, 0, settings.scale, settings.scale)
        render_scene(nodes)
    else
        nodes.transform = transform(0, 0, 0, settings.scale, setting.scale)
        render_scene(nodes)
    end
    gfx.setColor(1, 1, 1)
    dress:draw()

    draw_world(nodes.world)
end
