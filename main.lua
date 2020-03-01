--require "lovedebug"
require "nodeworks"
require "update_coroutine"

function love.load(arg)
    log.outfile = "./log.txt"
    -- SET A BATTLE AS DEFALT
    gfx.setBackgroundColor(0, 0, 0, 0)
    arg = list(unpack(arg))

    local old_load = love.load
    local entry = arg[1] or "battle"
    log.info("Entering %s", entry)

    entry = entry:gsub('/', '')

    local entrymap = {
        node = "designer/node",
        platform = "platform_main",
        glow = "glow_main",
        debug = "debug_main",
        sprite = "sprite_main"
    }
    entry = entrymap[entry]
    if entry then
        require(entry)
    end
    if love.load ~= old_load then
        return love.load(arg:sub(2))
    end
end

local input_from_key = {
    left = "left", right = "right", space = "confirm", backspace = "abort",
    tab = "swap"
}

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end

    local input = input_from_key[key]

    if input then event("inputpressed", input) end

    event("keypressed", key, scancode, isrepeat)
end
