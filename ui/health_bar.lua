local bar = require "ui.bar"
local label = require "ui.label"
local mechanics = require "mechanics"

local health_bar = {}

function health_bar:compute_structure()
    local margin = vec2(24, 16)
    local bar = spatial(0, 0, 200, 5)
    local textbox = bar:up(0, 5, nil, 20)
    local border = bar:join(textbox):expand(margin:unpack())

    local structure = {
        bar = bar,
        textbox = textbox,
        border = border
    }

    for key, val in pairs(structure) do
        structure[key] = val:relative(border, "topleft")
    end

    return structure
end

function health_bar:structure()
    self._structure = self._structure or self:compute_structure()
    return self._structure
end

function health_bar:clear_structure()
    self._structure = nil
    return self
end

function health_bar:create(id)
    self:set_id(id)
end

function health_bar.format_value_str(current, max)
    return string.format("%i / %i", current, max)
end

function health_bar:draw()
    local health = self:get_health()
    local opt = {value=health.current, max=health.max}

    local structure = self:structure()

    local round = 5
    gfx.setColor(0.1, 0.2, 0.3, 0.6)
    gfx.rectangle(
        "fill",
        structure.border.x, structure.border.y,
        structure.border.w, structure.border.h,
        round
    )
    local font_size = 15
    label(
        "Health",
        structure.textbox.x, structure.textbox.y,
        structure.textbox.w, structure.textbox.h,
        {
            font = font(font_size),
            hide_background = true,
            align = "left",
            valign = "center"
        }
    )
    label(
        health.text,
        structure.textbox.x, structure.textbox.y,
        structure.textbox.w, structure.textbox.h,
        {
            font = font(font_size),
            hide_background = true,
            align = "right",
            valign = "center"
        }
    )
    bar(opt, structure.bar:unpack())
end

function health_bar:set_id(id)
    self._id = id
    self:update_health()
    return self
end

function health_bar:on_adopted()
    local manager = self:update_health()

    if not manager then return end

    --manager:apply_remap(self)
end

function health_bar:update_health(state)
    local manager = self:upsearch("manager")

    local id = self._id
    if not manager or not id then return manager end

    local state = manager:state()

    self:set_health(manager:read_health(id))

    return manager
end

function health_bar:health_from_state(state, id)
    self:set_health(mechanics.damage.reader.health(state, id))
end

function health_bar:set_health(current, max)
    self._health = {
        current=current, max=max,
        text=health_bar.format_value_str(current, max)
    }
end

function health_bar:get_health()
    return self._health or {current=1, max=1, text="1 / 1"}
end

health_bar.remap = {
    [mechanics.damage.transform.damage] = function(self, state, info, user, target)
        if self._id ~= target then return end
        self:health_from_state(state, target)
    end
}


function health_bar:test(settings)
    settings.scale = 1
    self:set_health(10, 20)
end


return health_bar
