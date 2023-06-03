_DEBUG = true

local bit = require 'bit'

local refs = {
    fake_duck = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
    slow_walk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
    yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
    yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
    yaw_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
    yaw_modifier = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
    yaw_modifier_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
    body_yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
    body_yaw_inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
    body_yaw_left_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
    body_yaw_right_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
    body_yaw_options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
    body_yaw_freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
    body_yaw_on_shot = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "On Shot"),
    body_yaw_lby_mode = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "LBY Mode"),
    freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
    freestanding_disable_yaw_modifiers = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"),
    freestanding_body_freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"),
}

local menu = {}
menu.anti_aim = {}
menu.builder = {}
menu.anti_aim_menu_group = ui.create("Anti-Aims")
menu.builder_menu_group = ui.create("Anti-Aim builder")

menu.anti_aim.override_anti_aim = menu.anti_aim_menu_group:switch("Override Anti-Aim")
menu.anti_aim.yaw_base = menu.anti_aim_menu_group:combo("Yaw Base", {"Disabled", "Left", "Right", "Backward", "Forward", "At Target", "Freestanding"})

local conditions = {"Global", "Air+", "Air", "Duck", "Walk", "Running", "Standing"}
menu.builder.condition = menu.builder_menu_group:combo("Condition", conditions)

-- hay 7 condiciones
for i = 1, 7 do
    menu.builder[conditions[i] .. "_override_condition"] = menu.builder_menu_group:switch("Override " .. conditions[i], i == 1)
    menu.builder[conditions[i] .. "_inverter"] = menu.builder_menu_group:switch("Inverter")
    menu.builder[conditions[i] .. "_fake_angles"] = menu.builder_menu_group:switch("Fake Angles")
    menu.builder[conditions[i] .. "_yaw_add_left"] = menu.builder_menu_group:slider("Yaw Add Left", -180, 180, 0)
    menu.builder[conditions[i] .. "_yaw_add_right"] = menu.builder_menu_group:slider("Yaw Add Right", -180, 180, 0)
    menu.builder[conditions[i] .. "_yaw_modifier"] = menu.builder_menu_group:combo("Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin"})
    menu.builder[conditions[i] .. "_modifier_scale"] = menu.builder_menu_group:slider("Modifier Scale", -180, 180, 0)
    menu.builder[conditions[i] .. "_fake_options"] = menu.builder_menu_group:selectable("Fake Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"})
    menu.builder[conditions[i] .. "_lby_mode"] = menu.builder_menu_group:combo("LBY Mode", {"Disabled", "Opposite", "Sway"})
    menu.builder[conditions[i] .. "_freestand_fake"] = menu.builder_menu_group:combo("Freestand Fake", {"Off", "Peek Fake", "Peek Real"})
    menu.builder[conditions[i] .. "_desync_on_shot"] = menu.builder_menu_group:combo("Desync On Shot", {"Disabled", "Opposite", "Freestand", "Switch"})
    menu.builder[conditions[i] .. "_desync_mode"] = menu.builder_menu_group:combo("Desync Mode", {"Static", "Jitter"})
    menu.builder[conditions[i] .. "_fake_limit_left"] = menu.builder_menu_group:slider("Fake Limit Left", 0, 58, 58)
    menu.builder[conditions[i] .. "_fake_limit_right"] = menu.builder_menu_group:slider("Fake Limit Right", 0, 58, 58)
end

local handle_builder = function(a)
    for i = 1, 7 do
        menu.builder[conditions[i] .. "_override_condition"]:set_visible(menu.builder.condition:get() == conditions[i] and a and i ~= 1)
        menu.builder[conditions[i] .. "_inverter"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_fake_angles"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_yaw_add_left"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_yaw_add_right"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_yaw_modifier"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_modifier_scale"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_fake_options"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_lby_mode"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_freestand_fake"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_desync_on_shot"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_desync_mode"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_fake_limit_left"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        menu.builder[conditions[i] .. "_fake_limit_right"]:set_visible(menu.builder.condition:get() == conditions[i] and menu.builder[conditions[i] .. "_override_condition"]:get() and a)
        
    end
end

local state_id = 1

local set_state = function()
    local lp = entity.get_local_player()
    if lp == nil then return end
    local vel = lp["m_vecVelocity"]:length2d()
    local duck = lp["m_bDucking"] or lp["m_bDucked"] or refs.fake_duck:get()
    local walk = refs.slow_walk:get()
    local air = bit.band(lp["m_fFlags"], 1) == 0
    if air and duck then state_id = 1
    elseif air then state_id = 2
    elseif duck then state_id = 3
    elseif walk and vel > 2 then state_id = 4
    elseif vel > 2 then state_id = 5
    else state_id = 6 end
end

local antiaim = {}
antiaim.jitter_side = true
antiaim.side = 1
antiaim.body_yaw = 0

local anti_aim = require("neverlose/anti_aim")

local anti_aim_conditions = function(a)

    local lp = entity.get_local_player()
    if lp == nil then return end

    if globals.choked_commands == 0 then antiaim.body_yaw = lp.m_flPoseParameter[11] * 120 - 60 end

    if globals.choked_commands == 0 then antiaim.jitter_side = anti_aim.get_desync_delta() > 0 end
    antiaim.side = antiaim.jitter_side and 1 or -1

    if menu.builder[a .. "_fake_options"]:get("Jitter") then
        if antiaim.side == 1 then
            refs.yaw_offset:override(menu.builder[a .. "_yaw_add_right"]:get())
        else
            refs.yaw_offset:override(menu.builder[a .. "_yaw_add_left"]:get())
        end
    else
        if menu.builder[a .. "_inverter"]:get() then
            refs.yaw_offset:override(menu.builder[a .. "_yaw_add_right"]:get())
        else
            refs.yaw_offset:override(menu.builder[a .. "_yaw_add_left"]:get())
        end
    end

    refs.body_yaw_inverter:override(menu.builder[a .. "_inverter"]:get())
    refs.body_yaw:override(menu.builder[a .. "_fake_angles"]:get())
    refs.yaw_modifier:override(menu.builder[a .. "_yaw_modifier"]:get())
    refs.yaw_modifier_offset:override(menu.builder[a .. "_modifier_scale"]:get())
    refs.body_yaw_options:override(menu.builder[a .. "_fake_options"]:get())
    refs.body_yaw_lby_mode:override(menu.builder[a .. "_lby_mode"]:get())
    refs.body_yaw_freestanding:override(menu.builder[a .. "_freestand_fake"]:get())
    refs.body_yaw_on_shot:override(menu.builder[a .. "_desync_on_shot"]:get())
    refs.body_yaw_left_limit:override(menu.builder[a .. "_fake_limit_left"]:get())
    refs.body_yaw_right_limit:override(menu.builder[a .. "_fake_limit_right"]:get())

end

local handle_anti_aim = function()
    for i =1, 7 do
        if i == 1 then goto skip end
        if not menu.builder[conditions[i] .. "_override_condition"]:get() then
            anti_aim_conditions(conditions[1])
        else
            anti_aim_conditions(conditions[state_id + 1])
        end
        ::skip::
    end
end

events.render:set(function()
    handle_builder(menu.anti_aim.override_anti_aim:get())
    menu.builder.condition:set_visible(menu.anti_aim.override_anti_aim:get())
end)

events.createmove:set(function(cmd)
    set_state()
    handle_anti_aim()
end)