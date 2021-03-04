utils.log("Clownemoji.club Anti-Flicker | Welcome back, " .. zapped.username .. " | Script made by @neplo and @onion \n", color.new(110,221,255));

-- Controls
local enableAntiFlicker = gui.add_checkbox("Anti-Flicker");
local checkFocus = gui.add_checkbox("Focused Check");
local checkChoke = gui.add_checkbox("Restrict Choke");
local checkFPS = gui.add_slider("Minimum FPS", 1, 120, 75);
local checkPing = gui.add_slider("Maximum Ping", 1, 999, 100);

-- Misc Vars
local localPlayer;
local values = {};
local controls = { gui.find("legit_aa"), gui.find("legit_max_ping"), gui.find("fake_lag"), gui.find("fake_lag_trigger_limit") }
local time = utils.timestamp();

function on_render()
    if (utils.timestamp() - time >= 1) then
        localPlayer = entitylist.get_localplayer();

        if (localPlayer ~= nil and engine.in_game()) then
            values = { game.focused, game.fps, game.latency };

            if (values[1] ~= nil and values[2] ~= nil and values[3] ~= nil) then
                if (enableAntiFlicker:get_value()) then
                    controls[2]:set_value(0);
                    local allowed = true;
                        
                    if (checkFocus:get_value()) then allowed = values[1]; end
                    if (checkChoke:get_value() and controls[3]:get_value() ~= 0 or controls[4]:get_value() ~= 0) then allowed = false; end
                    if (values[2] < checkFPS:get_value()) then allowed = false; end
                    if (values[3] > checkPing:get_value()) then allowed = false; end

                    if (allowed) then
                        if (controls[1]:get_value() ~= "Always") then
                            controls[1]:set_value("Always");
                        end
                    else
                        if (controls[1]:get_value() ~= "Disabled") then
                            controls[1]:set_value("Disabled");
                        end
                    end
                end
            end
        end

        time = utils.timestamp();
    end
end