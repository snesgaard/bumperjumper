local charbar = {}
local uibar = require "ui.bar"

function charbar:create()
    self.drawstack = DrawStack.create()
    self.mana = {
        -- Bar components
        bar = {
            min=0,
            max=100,
            value=50,
            color={0.2, 0.7, 0.7}
        },
        -- Label components
        str = {
            str="50 / 100",
            font=font(12),
            align="right",
            valign="center",
            color = {
                normal = {
                    fg = {1.0, 1.0, 1.0}
                }
            }
        }
    }
    self.hp = {
        -- Bar components
        bar={
            min=0,
            max=50,
            value=25,
            color = {1.0, 0.5, 0.5},
        },
        str={
            -- Label components
            str="25 / 50",
            font=font(12),
            align="right",
            valign="center",
            color = {
                normal = {
                    fg = {1.0, 1.0, 1.0}
                }
            }
        }
    }
    self.layout = self:build_layout()
end

function charbar:set_mana(value, max)
    local bar = self.mana.bar
    bar.max = max or bar.max
    bar.value = value
    self.mana.str.str = string.format("%i / %i", bar.value, bar.max)
    return self
end

function charbar:set_hp(value, max)
    local bar = self.hp.bar
    bar.max =  max or bar.max
    bar.value = value
    self.hp.str.str = string.format("%i / %i", bar.value, bar.max)
    return self
end

function charbar:icon_from_atlas(atlas, icon)
    if not atlas then return self end
    self.icon = get_atlas(atlas):get_frame(icon)
    return self:rebuild()
end

function charbar:rebuild()
    local atlas = get_atlas("art/ui")
    local bar = atlas:get_animation("charbar")
    local overlay = atlas:get_animation("char_icon_holder")

    local label_opt = {
        align="left",
        valign="center",
        font = font(12),
    }

    return self
end

function charbar:build_layout()
    local layout = dict()

    layout.icon = spatial(0, 0, 20, 20):scale(2, 2)

    local label = spatial(0, 0, 32, 6):scale(2, 2)
    local bar = spatial(0, 0, 64, 3):scale(2, 2)

    layout.name = layout.icon
        :align(layout.icon, "left", "left", "top", "bottom")
        :move(0, 6)

    layout.hp_bar = bar
        :align(layout.icon, "left", "right", "bottom", "top")
        :move(8, 8)

    layout.mana_bar = bar
        :align(layout.icon, "left", "right", "bottom", "bottom")
        :move(8, -8)

    layout.hp_label = label
        :align(layout.hp_bar, "left", "left", "bottom", "top")
        :move(0, -6)
    layout.hp_value = layout.hp_label:right()

    layout.mana_label = label
        :align(layout.mana_bar, "left", "left", "top", "bottom")
        :move(0, 6)
    layout.mana_value = layout.mana_label:right()

    layout.bound = layout.icon
        :join(layout.hp_value, layout.mana_value)
        :compile()
        :expand(25, 15)

    return layout
end

local label_opt = {
    align="left",
    valign="center",
    font = font(12),
    color = {
        normal = {
            fg = {1.0, 1.0, 1.0}
        }
    }
}

local COLORS = {
    vanguard = {0, 0, 0.2, 0.3},
    cooldown = {0.2, 0.2, 0.2, 0.3},
    reserve = {0.6, 0, 0, 0.3}
}

function charbar:color_from_place(place)
    self.color = place > 3 and COLORS.reserve or COLORS.vanguard
    return self
end

function charbar:progress(prog)
    self.prog = prog
    return self
end

function charbar:__draw(x, y)
    --self.drawstack:draw(x, y + 100)
    gfx.setColor(unpack(self.color or COLORS.vanguard))
    gfx.rectangle(
        "fill", self.layout.bound.x, self.layout.bound.y,
        self.layout.bound.w, self.layout.bound.h, 10
    )

    gfx.setColor(1, 1, 1)
    if self.icon then
        self.icon:draw(self.layout.icon.x, self.layout.icon.y, 0, 2, 2)
    end
    gfx.setColor(1, 1, 1, 0.8)
    gfx.rectangle("line", self.layout.icon:unpack())

    suit.theme.Label(
        self.hp.str.str, self.hp.str, self.layout.hp_value:unpack()
    )
    suit.theme.Label(
        "Health", label_opt, self.layout.hp_label:unpack()
    )
    uibar(self.hp.bar, self.layout.hp_bar:unpack())

    suit.theme.Label(
        self.mana.str.str, self.hp.str, self.layout.mana_value:unpack()
    )
    suit.theme.Label(
        "Mana", label_opt, self.layout.mana_label:unpack()
    )
    uibar(self.mana.bar, self.layout.mana_bar:unpack())
end

function charbar:position(index)
    local oy = -200
    if index <= 3 then
        return vec2(50 + 225 * (3 - index), gfx.getHeight() + oy)
    else
        return vec2(50 + 225 * (5 - index), gfx.getHeight() + oy + 100)
    end
end

function charbar:set_id(id)
    self.id = id
    return self
end

function charbar:set_position(index)
    self.__transform.pos = self:position(index)
    return self
end

function charbar:update(state, id)
    id = id or self.id
    if not id then return end
    self:set_hp(
        state:read(join("actor/health", self.id)),
        state:read(join("actor/max_health", self.id))
    )
    return self
end

charbar.remap = {}

charbar.remap["mechanics.base:damage"] = function(self, state, info)
    if self.id ~= info.target then return end

    self:set_hp(
        state:read(join("actor/health", self.id)),
        state:read(join("actor/max_health", self.id))
    )
end

charbar.remap["mechanics.base:true_damage"] = charbar.remap["mechanics.base:damage"]

charbar.remap["mechanics.base:set_health"] = function(self, state, info, args)
    if args.id ~= self.id then return end

    self:set_hp(
        state:read(join("actor/health", self.id)),
        state:read(join("actor/max_health", self.id))
    )
end

return charbar