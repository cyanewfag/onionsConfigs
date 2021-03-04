local enabled = gui.add_checkbox("Enabled", false);
local name = gui.add_textbox("Namespam", "onion's penis");
local speed = gui.add_slider("Namespam Speed (ms)", 10, 500, 35);
local localPlayer = entitylist.get_localplayer();
local savedTick = globalvars.curtime;
local curTick = globalvars.curtime;
local boolSwap = false;
local nameChanged = 0;

function safeSetName(name)
    if (name ~= nil) then
        name = tostring(name)

        if (string.len(name) > 32) then
            name = name:sub(1, 32)
        end

        if (engine.in_game()) then
            utils.set_name(name);
        end
    end
end

function on_render()
    if (engine.in_game()) then
        localPlayer = entitylist.get_localplayer();
        curTick = globalvars.curtime;
        if (savedTick > curTick) then
            savedTick = globalvars.curtime;
        end

        if (localPlayer ~= nil) then
            if (nameChanged <= 10) then
                if (enabled:get_value()) then
                    if (curTick - savedTick >= speed:get_value() / 1000) then
                        if (boolSwap) then
                            safeSetName(name:get_value())
                            boolSwap = false;
                        else
                            safeSetName("߷" .. name:get_value())
                            boolSwap = true;
                        end

                        savedTick = globalvars.curtime;
                        nameChanged = nameChanged + 1;
                    end
                end
            end
        end
    else
        savedTick = globalvars.curtime;
        curTick = globalvars.curtime;
        nameChanged = 0;
    end
end