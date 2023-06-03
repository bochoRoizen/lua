_DEBUG = true

ui.sidebar("bocho visuals", "keyboard")

local smoothy = require("neverlose/smoothy")

local screen = render.screen_size()

local menuGroup = ui.create("visuals")
ui.global_color = menuGroup:color_picker("global color", "83CEDF2D")
ui.multicombo = menuGroup:selectable("ui", {"keybinds", "spectators"})

local font = {} 
font.font_size = 11
font.font_args = "d"
font.font_name = "verdana"
font.font_object = render.load_font(font.font_name, font.font_size, font.font_args)

local animations = (function()

    local t = {
        data = {},
    }

    function t:animate(n, s, t, mul, b)

        --[[
            string n: nombre del objecto [requerido]
            bool s: incrementa/decrese [requerido]
            int t: duracion de la animacion [opcional] (defualt: 0.05)  
            num mul: distancia [opcional] (default: 1)
            bool b: usar redondeo [opcional] (defualt: true)
        ]]

        if self.data[n] == nil then
            self.data[n] = {
                val = 0,
                c = true,
                smoothy = smoothy.new(0)
            }
        end

        t = t or 0.05
        mul = mul or 1
        b = b or true

        if s and self.data[n].c then
            self.data[n].smoothy = smoothy.new(0)
            self.data[n].c = false
        elseif not s and not self.data[n].c then
            self.data[n].smoothy = smoothy.new(mul)
            self.data[n].c = true
        end

        local mf =  self.data[n].c and math.floor or math.ceil

        self.data[n].val = self.data[n].smoothy(t, self.data[n].c and 0 or mul)


        if not b then return self.data[n].val end

        return mf(self.data[n].val)

    end

    return t
    
end)()

local get_text_size = function(text)
    return render.measure_text(font.font_object, font.font_args, text)
end

local is_mouse_bound = function(x, y, w, h)
    local mouse = ui.get_mouse_position()
    if mouse.x > x and mouse.x < x + w and mouse.y > y and mouse.y < y + h then
        return true
    end
end

--#region keybinds

local keybinds = {}
keybinds.config = {
    x = menuGroup:slider("keybinds_x", 0, render.screen_size().x, 600),
    y = menuGroup:slider("keybinds_y", 0, render.screen_size().y, 300)
}
keybinds.x = keybinds.config.x:get()
keybinds.y = keybinds.config.y:get()
keybinds.w = 140
keybinds.h = 20
keybinds.color = {r = 255, g = 255, b = 255, a = 255}
keybinds.drag = false
keybinds.enabled = false
keybinds.items = {}

keybinds.config.x:set_visible(false)
keybinds.config.y:set_visible(false)

function hook_keybinds()

    local mouse, binds = ui.get_mouse_position(), ui.get_binds()
    keybinds.x, keybinds.y = keybinds.config.x:get(), keybinds.config.y:get()
    local x, y, w, h = keybinds.x, keybinds.y, keybinds.w, keybinds.h
    keybinds.color.r, keybinds.color.g, keybinds.color.b = ui.global_color:get().r, ui.global_color:get().g, ui.global_color:get().b
    local r, g, b, a = keybinds.color.r, keybinds.color.g, keybinds.color.b, keybinds.color.a

    if common.is_button_down(1) and is_mouse_bound(x, y, w, h) and not keybinds.drag then
        keybinds.drag = true
    elseif common.is_button_down(1) and keybinds.drag and ui.get_alpha() > 0.5 then
        keybinds.x = mouse.x - w / 2
        keybinds.y = mouse.y - h / 2
    elseif not common.is_button_down(1) and not is_mouse_bound(x, y, w, h) then
        keybinds.drag = false
    end

    render.blur(vector(x, y), vector(x + w, y + h), math.min(ui.global_color:get().a / 255, a / 255), math.min(ui.global_color:get().a / 255, a / 255), 6)

    render.rect(vector(x, y), vector(x + w, y + h), color(20, 20, 20, math.min(ui.global_color:get().a, a)), 6)

    render.text(font.font_object, vector(x + w / 2 - get_text_size("keybinds").x / 2, y + h / 2 - get_text_size("keybinds").y / 2), color(255, 255, 255, a), nil, "keybinds")

    render.rect_outline(vector(x, y), vector(x + w, y + h), color(r, g, b, a), 1, 6)

    render.shadow(vector(x, y), vector(x + w, y + h), color(r, g, b, math.min(255 / 2, a)), 30, 0, 6)

    keybinds.items = {}
    keybinds.items.binds = {}
    keybinds.items.x = x + 5
    keybinds.items.y = y + h + 1

    keybinds.max_w = 0


    for i = 1, #binds do
        if binds[i] == nil then goto continue end
        table.insert(keybinds.items.binds, 1, binds[i])
        ::continue::
    end

    for i = 1, #keybinds.items.binds do

        local alpha = animations:animate(keybinds.items.binds[i].name .. "_alpha", keybinds.items.binds[i].active, nil, 255)
        alpha = math.min(alpha, a)

        keybinds.items.y = keybinds.items.y + animations:animate(keybinds.items.binds[i].name .. "_last_yoffset", i == #keybinds.items.binds and not keybinds.items.binds[i].active and #keybinds.items.binds > 1, nil, 4)

        render.text(font.font_object, vector(keybinds.items.x, keybinds.items.y), color(255, 255, 255, alpha), nil, keybinds.items.binds[i].name)

        local mode = keybinds.items.binds[i].mode == 1 and "[holding]" or "[toggled]"

        render.text(font.font_object, vector(x + w - get_text_size(mode).x - 5, keybinds.items.y), color(255, 255, 255, alpha), nil, mode)

        local bind_w = get_text_size(mode).x + get_text_size(keybinds.items.binds[i].name).x + 10

        if bind_w > keybinds.max_w and keybinds.items.binds[i].active then
            keybinds.max_w = bind_w
        end

        keybinds.items.y = keybinds.items.y + animations:animate(keybinds.items.binds[i].name .. "_yoffset", keybinds.items.binds[i].active, nil, font.font_object.height)
        
    end

    keybinds.w = math.max(140, keybinds.max_w)

    keybinds.w = keybinds.w + animations:animate("keybinds_anim_w", 140 < keybinds.w, nil, 10)

    --keybinds.w = keybinds.anim_w

    keybinds.color.a = animations:animate("keybinds_a", ((#binds == 1 and {binds[1].active} or {#binds ~= 0})[1] or ui.get_alpha() > 0.5) and ui.multicombo:get("keybinds"), nil, 255)

    keybinds.config.x:set(math.clamp(keybinds.x, 0, render.screen_size().x - keybinds.w))
    keybinds.config.y:set(keybinds.y)

end

--#endregion

--#region spectators

local spectators = {}
spectators.config = {
    x = menuGroup:slider("spectators_x", 0, render.screen_size().x, 10),
    y = menuGroup:slider("spectators_y", 0, render.screen_size().y, 670)
}
spectators.x = spectators.config.x:get()
spectators.y = spectators.config.y:get()
spectators.w = 140
spectators.h = 20
spectators.color = {r = 255, g = 255, b = 255, a = 255}
spectators.drag = false
spectators.enabled = false
spectators.items = {}

spectators.config.x:set_visible(false)
spectators.config.y:set_visible(false)

function hook_spectators()
    
    local mouse = ui.get_mouse_position()
    spectators.x, spectators.y = spectators.config.x:get(), spectators.config.y:get()
    local x, y, w, h = spectators.x, spectators.y, spectators.w, spectators.h
    spectators.color.r, spectators.color.g, spectators.color.b = ui.global_color:get().r, ui.global_color:get().g, ui.global_color:get().b
    local r, g, b, a = spectators.color.r, spectators.color.g, spectators.color.b, spectators.color.a

    if common.is_button_down(1) and is_mouse_bound(x, y, w, h) and not spectators.drag then
        spectators.drag = true
    elseif common.is_button_down(1) and spectators.drag and ui.get_alpha() > 0.5 then
        spectators.x = mouse.x - w / 2
        spectators.y = mouse.y - h / 2
    elseif not common.is_button_down(1) and not is_mouse_bound(x, y, w, h) then
        spectators.drag = false
    end

    render.blur(vector(x, y), vector(x + w, y + h), math.min(ui.global_color:get().a / 255, a / 255), math.min(ui.global_color:get().a / 255, a / 255), 6)

    render.rect(vector(x, y), vector(x + w, y + h), color(20, 20, 20, math.min(ui.global_color:get().a, a)), 6)

    render.text(font.font_object, vector(x + w / 2 - get_text_size("spectators").x / 2, y + h / 2 - get_text_size("spectators").y / 2), color(255, 255, 255, a), nil, "spectators")

    render.rect_outline(vector(x, y), vector(x + w, y + h), color(r, g, b, a), 1, 6)

    render.shadow(vector(x, y), vector(x + w, y + h), color(r, g, b, math.min(255 / 2, a)), 30, 0, 6)

    spectators.items = {}
    spectators.items.spectators = {}
    spectators.items.avatars = {}
    spectators.items.x = x + 5
    spectators.items.y = y + h + 2

    spectators.max_w = 0

    local lp = entity.get_local_player()

    if lp ~= nil then
        if lp:is_alive() then
            spectators.items.spectators = lp:get_spectators()
        elseif lp["m_hObserverTarget"] ~= nil then
            spectators.items.spectators = lp["m_hObserverTarget"]:get_spectators()
            table.insert(spectators.items.spectators, 1, lp)
        end
    end
    

    for i = 1, #spectators.items.spectators do
        spectators.items.avatars[i] = spectators.items.spectators[i]:get_steam_avatar()
        render.texture(spectators.items.avatars[i], vector(spectators.items.x, spectators.items.y), vector(font.font_object.height + 1, font.font_object.height + 1), color():alpha_modulate(a))
        render.text(font.font_object, vector(spectators.items.x + font.font_object.height + 3, spectators.items.y), color(255, 255, 255, a), nil, spectators.items.spectators[i]:get_name())
        local bind_w = font.font_object.height + 4 + get_text_size(spectators.items.spectators[i]:get_name()).x + 5
        if bind_w > spectators.max_w then
            spectators.max_w = bind_w
        end
        spectators.items.y = spectators.items.y + font.font_object.height + 2
        ::skip::
    end

    spectators.w = math.max(140, spectators.max_w)

    spectators.w = spectators.w + animations:animate("spectators_anim_w", 140 < spectators.w, nil, 10)

    --spectators.w = spectators.anim_w

    spectators.color.a = animations:animate("spectators_a", (#spectators.items.spectators > 0 or ui.get_alpha() > 0.5) and ui.multicombo:get("spectators"), nil, 255)

    spectators.config.x:set(math.clamp(spectators.x, 0, render.screen_size().x - spectators.w))
    spectators.config.y:set(spectators.y)

end

--#endregion

events.render:set(function()
    hook_keybinds()
    hook_spectators()
end)