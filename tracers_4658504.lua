local group = ui.create("tracers")
local switch = group:switch("enable")
local color_picker = group:color_picker("color", color("#95A1B820"))

events.render:set(function()

    color_picker:set_visible(switch:get())

    if not switch:get() then return end

    local lp = entity.get_local_player()
    if lp == nil then return end
    local threat = entity.get_threat()
    if threat == nil then return end
    if not threat:is_alive() or threat:is_dormant() then return end

    local lp_hb = lp:get_origin()
    lp_hb.z = lp_hb.z + 40
    
    local threat_hb = threat:get_hitbox_position(3)

    render.line(lp_hb:to_screen(), threat_hb:to_screen(), color_picker:get())

end)