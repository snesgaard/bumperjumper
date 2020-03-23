local zap = {}

zap.max_radius = 15

local shader_code = [[
float attenuation(float dist, float radius) {
    float att = clamp(1.0 - pow(dist / radius, 2.0), 0.0, 1.0);
    return att * att;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 diff = abs(texture_coords - vec2(0.5f, 0.5f));

    float dist = length(diff);

    float b_radius = 0.5f;
    float rg_radius = 0.25f;

    float b_att = attenuation(dist, b_radius);
    float rg_att = attenuation(dist, rg_radius);

    return vec4(rg_att + 0.1f, rg_att + 0.7f, 1.0, b_att);
}
]]

zap.shader = gfx.newShader(shader_code)
zap.mesh = gfx.newMesh(
    {
        {-1, -1, 0, 0},
        {1, -1, 1, 0},
        {1, 1, 1, 1},
        {-1, 1, 0, 1},
    }
)

function zap:create(src, dst)
    local v = dst - src
    self.src = src
    self.dst = dst
    self.radius = v:length() * 0.5
    local pos = (dst + src) * 0.5
    self.transform = transform(pos.x, pos.y, v:argument(), v:length() * 0.5, 15)
    self.radius_2nd = 5

    self:fork(zap.life)
end

function zap:_drawdebug()
    gfx.push()
    gfx.scale(1.0 / self.transform.scale.x, 1.0 / self.transform.scale.y)
    gfx.rotate(-self.transform.angle)
    gfx.translate(-self.transform.position.x, -self.transform.position.y)

    gfx.circle("line", self.src.x, self.src.y, 5)
    gfx.circle("line", self.dst.x, self.dst.y, 5)
    gfx.pop()
end

function zap:life()
    self.transform.scale.y = 0
    local t = tween(0.1, self.transform.scale, {y=zap.max_radius})
    event:wait(t, "finish")
    local t = tween(0.1, self.transform.scale, {y=0})
    event:wait(t, "finish")
    self:destroy()
end

function zap:_draw_ellipse()
    gfx.setColor(0, 0, 1)
    --gfx.rectangle("fill", 0, 0, self.radius, self.radius_2nd + zap.margin)
    gfx.draw(zap.mesh, 0, 0)
end


function zap:draw()
    gfx.setShader(zap.shader)
    self:_draw_ellipse()

    if zap._debug then
        gfx.setColor(1, 1, 1)
        gfx.setShader()
        self:_drawdebug()
    end
end

zap.glow = zap.draw

zap.testargs = {vec2(-200, 0), vec2(200, 100)}

function zap:test(settings)
    event:sleep(0.1)
    settings.paused = true

    while true do
        local key = event:wait("keypressed")
        if key == "g" then
            settings.disable_glow = not settings.disable_glow
        end
    end
end

return zap
