local scene_graph = {}

function scene_graph:create()
    self:child("actors")
end

function scene_graph:init_actor(id, f, ...)
    local actors = self:find("actors")
    local node = f(...)
    if node then
        actors:adopt(id, node)
    end
    return self
end

function scene_graph:get_body(id)
    return self:find(join("actors", id))
end

function scene_graph:get_sprite(id)
    return self:find(join("actors", id, "sprite"))
end

return scene_graph
