
_DEBUG = true

local font_size = 11
local font = render.load_font("verdana", font_size, "a")

function get_prop(prop_name)
    local localplayer = entity.get_local_player()
    
    if localplayer == nil then
        return false
    end

    if type(prop_name) ~= "string" then
        return false
    end

    return localplayer[prop_name]

end

events.render:set(function ()

    if rage.antiaim:get_rotation() == nil or rage.antiaim:get_rotation(true) == nil or rage.antiaim:get_max_desync() == nil then
        return
    end

    local desync = math.clamp((function() -- (math.abs(rage.antiaim:get_rotation(true)) - math.abs(rage.antiaim:get_rotation())) / 2
        if rage.antiaim:get_rotation() > rage.antiaim:get_rotation(true) then
            return rage.antiaim:get_rotation() - rage.antiaim:get_rotation(true)
        end
        return rage.antiaim:get_rotation(true) - rage.antiaim:get_rotation()
    end)(), 0, rage.antiaim:get_max_desync())

    local render_list = {
        --"rotation: " .. math.floor(rage.antiaim:get_rotation()),
        --"fake rotation: " .. math.floor(rage.antiaim:get_rotation(true)),
        "desync: " .. string.format("%.1f", desync),
        "max desync: " .. string.format("%.1f", rage.antiaim:get_max_desync())
    }

    local y = 300

    for i = 1, #render_list do
        render.text(font, vector(700, y + i * font_size + 1), color(), nil, render_list[i])
    end
end)
