local scene_graph = {}

function scene_graph:create()
    local world = self:child("world")
    world:child("actors")
    world:child("sfx")
    world:child("world_ui")

    self:child("screen_ui")
end

function scene_graph:init_actor(id, f, ...)
    local actors = self:find("world/actors")
    local node = f(...)
    if node then
        node.id = id
        actors:adopt(id, node)
    end
    return self
end

function scene_graph:screen_ui(node_type, ...)
    local node = self:find("screen_ui"):child(node_type, ...)
    if node.remap then
        -- TODO manager should probably be instantiated in the scene graph
        -- creation method
        self.manager:apply_remap(node)
    end

    return node
end

function scene_graph:world_ui(node_type, ...)
    local node = self:find("world/world_ui"):child(node_type, ...)
    if node.remap then
        -- TODO manager should probably be instantiated in the scene graph
        -- creation method
        self.manager:apply_remap(node)
    end

    return node
end

function scene_graph:sfx(node_type, ...)
    return self:find("world/sfx"):child(node_type, ...)
end

function scene_graph:get_body(id)
    return self:find(join("world/actors", id))
end

function scene_graph:get_sprite(id)
    return self:find(join("world/actors", id, "sprite"))
end

return scene_graph
