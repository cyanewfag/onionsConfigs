local localPlayer = entitylist.get_localplayer();
local controls = {{"Enabled", gui.add_checkbox("Enabled", true)}, {"Time", gui.add_slider("Anti-AFK (s)", 5, 180, 180)}, {"Score", gui.add_slider("Spectate Score", 0, 350, 310)}, {"Name Stealer", gui.add_checkbox("Invisible Name", true)}, {"Auto Health-Shot Health", gui.add_slider("Health-Shot Health", 1, 99, 35)}, {"Auto Health-Shot", gui.add_checkbox("Auto Health-Shot", true)}, {"Auto-Reload", gui.add_slider("Auto-Reload (Percent)", 1, 100, 25)}, {"Auto-Reload", gui.add_checkbox("Auto-Reload", true)}, {"Visibility Check", gui.add_checkbox("Visibility Check", true)}};
local savedTime = utils.timestamp();
local visibleCheck = savedTime;
local reloadTime = savedTime;
local inProgress = false;
local reloadInProgress = false;
local visible = false;

function safeLog(str, r, g, b, a)
    if (str ~= nil) then
        str = tostring(str)
        if (str ~= "") then
            if (r ~= nil and g ~= nil and b ~= nil and a ~= nil) then
                local color = color.new(r, g, b, a);
                if (color ~= nil) then
                    utils.log(str, color);
                end
            else
                utils.event_log(str, true);
            end
        end
    end
end

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

function safeGetProp(entity, str, index, custom)
    if (engine.in_game()) then
        if (entity ~= nil and str ~= nil) then
            str = tostring(str)
            if (str ~= "") then
                if (index == nil) then
                    local prop;
                    if (custom) then
                        prop = entity:get_prop(str);
                    else
                        prop = playerresources.get_prop(entity, str);
                    end
                    if (prop == nil) then return nil; else return prop; end
                else
                    local prop;
                    if (not custom) then
                        prop = playerresources.get_prop(entity, str, index);
                    end
                    if (prop == nil) then return nil; else return prop; end
                end
                return nil;
            end
            return nil;
        end
        return nil;
    end
    return nil;
end

function setTeam(id)
    if (id ~= nil) then
        if (id >= 1 and id <= 3) then
            if (engine.in_game()) then
                if (localPlayer ~= nil) then
                    id = tostring(id);
                    engine.client_cmd("jointeam " .. id .. " 1");
                end
            end
        end
    end
end

function sayInChat(text)
    if (text ~= nil) then
        text = tostring(text);
        engine.client_cmd("say " .. text);
    end
end

function safeClientCmd(cmd)
    if (cmd ~= nil) then
        cmd = tostring(cmd);
        engine.client_cmd(cmd);
    end
end

function buyItem(table)
    if (table ~= nil) then
        local text = "";
        for i = 1, #table do
            if (text == "") then
                text = "buy " .. tostring(table[i]);
            else
                text = text .. "; buy " .. tostring(table[i]);
            end
        end

        if (text ~= "") then
            engine.client_cmd(text);
        end
    end
end

function checkForWeapon(entity, id)
    if (entity ~= nil and id ~= nil) then
        if (entitylist.get_player_weapon(localPlayer):get_class_id() == id) then
            return true;
        else
            return false;
        end
    end
end

function checkForHasWeapon(entity, id)
    if (entity ~= nil and id ~= nil) then
        local weapons = entitylist.get_player_weapons(localPlayer);
        
        for i = 1, #weapons do
            if (weapons[i]:get_class_id() == id) then
                return true;
            end
        end
        
        return false;
    end
end

function checkVisibleEnemies()
    if (utils.timestamp() - visibleCheck >= 1) then
        local enemies = entitylist.get_enemies();
        for i = 1, #enemies do
            if (enemies[i] ~= nil) then
                if (enemies[i]:is_valid()) then
                    if (enemies[i]:is_enemy()) then
                        if (enemies[i]:is_visible(enemies[i]:get_eye_pos())) then
                            visibleCheck = utils.timestamp();
                            visible = true;
                            return visible;
                        end
                    end
                end
            end
        end
        visible = false;
        visibleCheck = utils.timestamp();
        return visible;
    end

    return visible;
end

function on_render()
    localPlayer = entitylist.get_localplayer();
    if (localPlayer == nil) then return end

    if (controls[1][2]:get_value()) then
        local score = safeGetProp(localPlayer, "m_iScore");
        local team = safeGetProp(localPlayer, "m_iTeam");
        local health = safeGetProp(localPlayer, "m_iHealth");

        if (controls[9][2]:get_value()) then
            checkVisibleEnemies();
        else
            visible = false;
        end

        if (utils.timestamp() - reloadTime >= 1) then
            if (controls[8][2]:get_value()) then
                local weaponEntity = entitylist.get_player_weapon(localPlayer)
                if (weaponEntity ~= nil) then
                    if (weaponEntity:is_weapon()) then
                        local curAmmo = safeGetProp(weaponEntity, "m_iClip1", nil, true)
                        if (curAmmo ~= nil) then
                            -- this is retarded but I'm not adding a long table of weapon clip sizes cause that's a lot of work. smd
                            local saveAmmo = safeGetProp(weaponEntity, "m_iPrimaryReserveAmmoCount", nil, true) / 3;

                            if (reloadInProgress) then
                                reloadInProgress = false;
                                safeClientCmd("-reload");
                                reloadTime = utils.timestamp();
                            else
                                if ((curAmmo / saveAmmo) * 100 <= controls[7][2]:get_value()) then
                                    if (not reloadInProgress) then
                                        reloadInProgress = true;
                                        safeClientCmd("+reload");
                                        reloadTime = utils.timestamp();
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if (score ~= nil) then
            if (team ~= nil) then
                if (utils.timestamp() - savedTime >= 1) then
                    if (checkForHasWeapon(localPlayer, 104)) then
                        if (engine.in_game()) then
                            if (not checkVisibleEnemies()) then
                                if (checkForHasWeapon(localPlayer, 104)) then
                                    if (controls[9][2]:get_value()) then
                                        if (health <= controls[5][2]:get_value()) then      
                                            if (not checkForWeapon(localPlayer, 104)) then
                                                safeClientCmd("slot12")
                                            else
                                                if (not inProgress) then
                                                    inProgress = true;
                                                    safeClientCmd("+attack")
                                                    savedTime = utils.timestamp();
                                                else
                                                    safeClientCmd("-attack")
                                                    inProgress = false;
                                                    savedTime = utils.timestamp();
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if (inProgress) then
                            safeClientCmd("-attack")
                            safeClientCmd("slot1")
                            inProgress = false;
                        end
                    end
                end

                if (utils.timestamp() - savedTime >= 1) then
                    if (team > 1) then
                        if (score >= controls[3][2]:get_value()) then
                            setTeam(1);
                            savedTime = utils.timestamp();
                        else
                            if (controls[4][2]:get_value()) then
                                if (utils.timestamp() - savedTime >= 5) then
                                    safeSetName("߷");
                                    savedTime = utils.timestamp();
                                end
                            end
                        end
                    else
                        if (utils.timestamp() - savedTime >= controls[2][2]:get_value()) then
                            setTeam(3);
                            savedTime = utils.timestamp();
                        end
                    end
                end
            end
        end
    end
end