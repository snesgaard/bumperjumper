return {
    ["wizard_spell/chant"] = {
        interpolate = function(name, index) return name == "chant"
    end},
    ["wizard_spell/cast"] = {
        interpolate = function(name, index) return name == "cast"
    end}
}
