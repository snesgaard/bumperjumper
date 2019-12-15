local control = {}

function control.idle(body, sprite)
    local context = {prev = nil}

    local function set_animation(key)
        if context.prev ~= key then
            sprite:queue(key)
            context.prev = key
        end
    end

    while true do
        event:wait("update")
        if body.speed.y < 0 then
            set_animation("ascend")
        elseif body.speed.y > 0 then
            set_animation("descend")
        elseif body.speed.x ~= 0 then
            set_animation("run")
        else
            set_animation("idle")
        end
    end
end

return control
