local damage = {}

damage.elements = {"physical", "thunder", "fire", "frost"}
damage.resistance = {weak=2.0, normal=1.0, resist=0.5, immune=0.0, drain=-1.0}
damage.charge_multiplier = 2.0
damage.shield_multiplier = 0

local function write_health(state, id, value)
    return state:write(join("health", id), value)
end

local function do_damage(state, info, user, damage_data, target, ...)
    if not target then return state, info end

    local shield = state:shield(state, target)
    local charge = state:charge(state, user)
    local resist = state:resistance(state, target)
    local health, max_health = state:health(state, target)

    local function calculate_damage(element, dmg)
        if not dmg then return 0 end

        local key = resist[element] or "normal"
        local scale = damage[key] or 1
        return dmg * scale, key
    end

    local damage_sum = 0
    local resist_info = {}
    local damage_info = {}
    for _, element in ipairs(damage.elements) do
        local dmg, resist_key = calculate_damage(element, damage_data[element])
        damage_sum = damage_sum + dmg
        resist_info[element] = resist_key
    end

    local total_damage = 0

    if charge then
        total_damage = total_damage * damage.charge_multiplier
    end
    if shield then
        total_damage = total_damage * damage.shield_multiplier
    end

    total_damage = math.floor(total_damage)
    actual_damage = math.min(health, total_damage)

    local next_health = health - actual_damage

    state = write_health(state, target, next_health)

    info[#info + 1] = {
        target = target,
        shield = shield,
        charge = charge,
        resist = resist_info,
        total_damage = total_damage,
        damage = actual_damage
    }

    return do_damage(state, info, user, damage_data, ...)
end

local function format_damage_data(data)
    local dtype = type(data)
    if dtype == "number" then
        return {physical=data}
    elseif dtype == "table" then
        return data
    else
        error(string.format("Unsupported data type %s", data))
    end
end

function damage.damage(state, user, damage_data, ...)
    return do_damage(state, list(), user, format_damage_data(damage_data), ...)
end

function damage:heal(state, user, heal, target)
    local health, max_health = state:health(target)
    local actual_heal = math.min(max_health - health, heal)
    local next_health = health + actual_heal

    local info = {
        target = target,
        heal = actual_heal
    }

    state = write_health(state, target, next_health)

    return state, info
end

function State.setup.damage(root)
    root.health = dict{}
    root.max_health = dict{}
    root.resistance = dict{}
    root.shield = dict{}
    root.charge = dict{}
end

function State:health(id)
    return self:read(join("health", id)), self:read(join("max_health", id))
end

function State:resistance(id)
    return self:read(join("resistance", id))
end

function State:shield(id)
    return self:read(join("shield", id))
end

function State:charge(id)
    return self:read(join("charge", id))
end


Master.register("damage", damage.damage)
Master.register("heal", damage.heal)

return damage
