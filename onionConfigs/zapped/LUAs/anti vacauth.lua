local enableVacAuth = gui.add_checkbox("VAC Auth");
local time = utils.timestamp();
local vacControls = { gui.find("desync"), gui.find("fake_duck"), gui.find("fake_turn"), gui.find("legit_aa"), gui.find("modifier"), gui.find("offset"), gui.find("pitch") };

function on_render()
    if (utils.timestamp() - time >= 1) then
        if(enableVacAuth:get_value()) then
            if (engine.in_game()) then
                local ip = game.server_ip;
                if (string.find(ip, "A:1")) then
                    local lp = entitylist.get_localplayer();
                    local lpHealth = lp:get_prop("m_iHealth");
                    if (lpHealth ~= nil and lpHealth > 0) then
                        local gameMode = cvars.find("game_mode");
                        local gameType = cvars.find("game_type");
                        if (gameType:get_string() ~= "0" or gameMode:get_string() == "0") then
                            for i = 1, #vacControls do
                                local value = vacControls[i]:get_value();
                                if (i == 4 or i == 3 or i == 5 or i == 6 or i == 7) then
                                    if (value ~= 0) then
                                        vacControls[i]:set_value(0);
                                    end
                                else
                                    if (value == true) then
                                        vacControls[i]:set_value(false);
                                    end
                                end
                            end

                            local fov = gui.find("fov_extras");
                            if (fov:get_value() ~= 10.5) then
                                fov:set_value(10.5);
                            end

                            time = utils.timestamp();
                        end
                    end
                end
            end
        end
    end
end