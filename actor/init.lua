local actor = {control={}}

local function load_sprite(root, actor_data)
    if not actor_data.animations or not actor_data.atlas then
        return
    end
    root.sprite = root:child(
        Sprite, actor_data.animations, actor_data.atlas
    )

end

function actor.load(path, world)
    local actor_data = require(path)
    local root = Node.create()
    root.body = root:child(require "nodeworks.body", world, 0, 0, 1, 1)
    load_sprite(root, actor_data)

    return root
end



return actor
