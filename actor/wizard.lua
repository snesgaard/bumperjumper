local atlas_path = "art/characters"

local wizard = {}

wizard.animations = {
    cast='wizard_cast/cast',
    chant='wizard_cast/chant',
    idle='wizard_movement/idle',
    run='wizard_movement/run',
    ascend="wizard_movement/ascend",
    descend="wizard_movement/descend",
}

wizard.atlas = 'art/characters'

wizard.name = "wizard"

function wizard.init_state(state, id)
    return {
        path="mechanics.base:set_health",
        args={id=id, health=10, max_health=10}
    }
end

return wizard
