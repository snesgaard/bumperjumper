require "nodeworks"
level_io = require "level"
wizard = require "actor.wizard"
actor = require "actor"
Camera = require "camera"
mechanics = require "mechanics"
local animation = require "animation"
require "bumpdebug"
local context = require "context"
spells = require "spells"

root = Node.create()


function love.load()
    level = level_io.load('art/maps/build/test.lua')
    body = root:child(require "body", level.world)
    body.__transform.scale = vec2(1, 1)
    body.__transform.pos = vec2(100, 100)
    sprite = body:child(Sprite, wizard.animations, wizard.atlas)
    sprite:queue("ascend")
    -- TODO:
    -- Alignment should happen to the intial frame of the animation
    -- Not the current. The first frame should be idle position, will thus tell
    -- How to get from one coordinate system to the other
    event:listen(sprite, "slice/body", function(_, hitbox, frame_id)
        sprite.__transform.pos.x = -hitbox.x - hitbox.w * 0.5
        sprite.__transform.pos.y = -hitbox.h - hitbox.y
        body:set(hitbox.w, hitbox.h)
        body.frame_id = frame_id
    end)
    set_sprite("wizard", sprite)
    set_body("wizard", body)

    camera = Camera:create()
    swap_co("player_control", spells.control_idle, "wizard")

    ui = Node.create(require "ui.char_bar")
    mechanics.remap(ui)

    play_state = state.create()
    play_state, id = mechanics.init_actor(play_state, wizard)

    ui:set_id(id):update(play_state)
end

function love.update(dt)
    tween.update(dt)
    require("lovebird").update()
    event:update(dt)
    event:spin()
    --body.__transform.pos.y = body.__transform.pos.y + 10
    root:update(dt)
    clear_keys()
    --camera:update(dt, body, level)
end

function love.draw()
    gfx.setColor(1, 1, 1)
    local x, y, sx, sy = camera:transform()
    --gfx.scale(sx, sy)
    --gfx.translate(x, y)
    level:draw(x, y, sx, sy)
    root:draw()
    gfx.origin()
    ui:draw(50, 50)
    --draw_world(level.world)
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    register_press(key)
    event("keypressed", key)
end
