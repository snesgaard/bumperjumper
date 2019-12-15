local body = {}

function body:create(world)
    --self.body = spatial(x, y, w, h)
    self.token = {}
    self.world = world
    self.speed = vec2(0, 0)
    self.gravity = vec2(0, 500)
    self.offset = vec2(0, 0)
    --self.world:add(self.token, self.body:unpack())
end

function body:set_gravity(acc)
    self.gravity = acc or default_gravity
    return self
end

function body:set(w, h)
    self.body = spatial(-w * 0.5, -h, w, h)
    return self
end

local function resolve_overlap(world, body)
    for i = 1, 50 do
        local ax, ay, col, len = world:check(body)
        if len == 0 then return ax, ay end
        world:update(body, col[1].touch.x, col[1].touch.y)
    end
end

function body:__motion(dt)
    local pos = self.__transform.pos
    local speed = self.speed
    local gravity = self.gravity
    speed.x = speed.x + gravity.x * dt
    speed.y = speed.y + gravity.y * dt
    pos.x = pos.x + speed.x * dt
    pos.y = pos.y + speed.y * dt
end

function body:warp(dx, dy)
    if not self.body then return end
    local bx, by = self.world:getRect(self.token)
    local x, y = bx + dx, by + dy
    self.world:update(self.token, x, y)
    --resolve_overlap(self.world, self.token)
    local ax, ay = self.world:getRect(self.token)
    print(bx, by, ax, ay, x, y)
    local pos = self.__transform.pos
    pos.x = pos.x + ax - bx
    pos.y = pos.y + ay - by
end

function body:__update(dt)
    if not self.body then return end

    local m = mat3stack:peek()
    local next_body = m:transform_spatial(self.body)

    if not self.world:hasItem(self.token) then
        self.world:add(self.token, next_body:unpack())
    else
        local x, y = self.world:getRect(self.token)
        self.world:update(
            self.token, x, y, next_body.w, next_body.h
        )
        resolve_overlap(self.world, self.token)
    end

    local scale = self.__transform.scale
    local ax, ay, col, len = self.world:move(
        self.token, next_body.x, next_body.y
    )
    for i = 1, len do
        local n = vec2(col[i].normal.x, col[i].normal.y)
        if n:dot(vec2(0, -1)) > 0.9 then
            self.speed.y = 0
        end
    end

    local dx = ax - next_body.x
    local dy = ay - next_body.y
    self.__transform.pos.x = self.__transform.pos.x + dx
    self.__transform.pos.y = self.__transform.pos.y + dy
end

function body:set_main(w, h)
    self.body = spatial(-w * 0.5, -h, w, h)
    self.world:add(self.token, self.body:unpack())
end



return body
