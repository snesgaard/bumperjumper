local damage = {}
damage.name = "damage"

damage.resist_multiplier = {
    weak=2.0, normal=1.0, resist=0.5, void=0.0
}

function damage.structure()
    return {
        health = {
            current = {}, max = {}
        },
        resistance = {}
    }
end

--[[
data = {
    damage = {
        health = 22,
        resistance = {
            thunder = "resist",
            fire = "weak"
        }
    }
}
]]--

function damage.setup(state, id, global_data)
    local data = global_data.damage

    local next_state = damage.writer.health(state, id, data.health, data.health)
    if data.resistance then
        next_state = damage.writer.resistance(next_state, id, dict(data.resistance))
    end

    return next_state
end


damage.transform = {}

function damage.transform.damage(state, user, target, data)
    if type(data) == "number" then
        data = {physical=data}
    end

    local sum = 0

    for _, num in pairs(data) do
        sum = sum + num
    end

    sum = math.max(sum, 0)
    local current, max = damage.reader.health(state, target)
    local actual_damage = math.min(current, sum)

    local next_state = damage.writer.health(
        state, target, current - actual_damage
    )

    local info = {
        damage = actual_damage
    }

    return next_state, info
end

function damage.transform.heal(state, user, target, heal)
    local current, max = damage.reader.health(state, target)

    local actual_heal = math.min(max - current, heal)
    actual_heal = math.max(actual_heal, 0)

    local next_state = damage.writer.health(
        state, target, current + actual_heal
    )

    local info = {
        heal = actual_heal
    }

    return next_state, info
end


damage.writer = {}

function damage.writer.health(state, id, current, max)
    if not id then return state end

    state = state:write(join("health/current", id), current)
    if max then
        state = state:write(join("health/max", id), max)
    end
    return state
end

function damage.writer.resistance(state, id, resist)
    if not id then return state end

    return state:write(join("resistance", id), resist)
end


damage.reader = {}

function damage.reader.health(state, id)
    if not id then return end

    local current = state:read(join("health/current", id))
    local max = state:read(join("health/max", id))

    return current, max
end

function damage.reader.resistance(state, id, resist)
    if not id then return state end

    return state:read(join("resistance", id))
end


return damage
