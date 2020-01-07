local context = {
    thread = {},
    sprite = {},
    body = {},
    keypressed = {},
}

function swap_co(name, func, ...)
    if context.thread[name] then
        local prev_co = context.thread[name]
        event:clear(prev_co)
        context.thread[name] = nil
    end

    if func then
        local co = coroutine.create(func)
        context.thread[name] = co
        coroutine.resume(co, ...)
    end
end

function set_sprite(id, sprite)
    context.sprite[id] = sprite
end

function get_sprite(id)
    return context.sprite[id]
end

function set_body(id, body)
    context.body[id] = body
end

function get_body(id)
    return context.body[id]
end

function register_press(key)
    context.keypressed[key] = true
end

function clear_keys()
    
    context.keypressed = {}
end

function keypressed(key)
    return context.keypressed[key]
end

return context
