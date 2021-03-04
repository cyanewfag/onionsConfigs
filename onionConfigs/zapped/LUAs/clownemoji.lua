local version = "1.1.0" -- Version
if (not string.find(http.get("https://raw.githubusercontent.com/smdfatnn/clownemojiZapped/main/version"), version)) then -- Auto Update
    http.download("https://raw.githubusercontent.com/smdfatnn/clownemojiZapped/main/clownemoji.lua", "C:/zapped/lua/clownemoji.lua")
else
    -- UI Variables
    local antiReportbot = gui.add_checkbox("Anti-Reportbot");
    local greyLobbyColor = gui.add_checkbox("Gray Lobby Color");
    local enableWatermark = gui.add_checkbox("Watermark");
    local retardCheck = gui.add_checkbox("Anti-VAC Auth");
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07); -- please add fucking spacers

    -- Killsay
    local enableKillsay = gui.add_checkbox("Killsay Enabled");
    local includeTeammates = gui.add_checkbox("Killsay - On Friendly")
    local filterNames = gui.add_checkbox("Killsay - Filter Name")
    local messageKillsay = gui.add_textbox("Killsay - Message", "&user& killed by &local& username &username& uid &uid& using &weapon& and was &headshot&")  
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);

    -- Namespam
    local enableNameSpam = gui.add_checkbox("Namespam Enabled");
    local name = gui.add_textbox("Namespam - Message", "clownemoji.club");
    local nameSpamSpeed = gui.add_slider("Namespam - Interval (ms)", 10, 500, 35);
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);

    -- Clantag Changer
    local enableClantagChanger = gui.add_checkbox("Clantag Changer");
    local clantag = gui.add_textbox("Clantag - Text", "clownemoji");
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);

    -- Anti Flicker
    local enableAntiFlicker = gui.add_checkbox("Anti-Flicker Enabled");
    local speedCheck = gui.add_slider("Clantag - Speed (ms)", 5, 500, 35);
    local checkFocus = gui.add_checkbox("Anti-Flicker - Focused Check");
    local checkChoke = gui.add_checkbox("Anti-Flicker - Restrict Choke");
    local checkFPS = gui.add_slider("Anti-Flicker - Minimum FPS", 0, 120, 75);
    local checkPing = gui.add_slider("Anti-Flicker - Maximum Ping", 0, 999, 100);
    local checkVelocity = gui.add_slider("Velocity Threshold", 0, 250, 30);
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);

    -- Logging
    local zappedConsoleLogger = gui.add_checkbox("Logging Enabled");
    local consoleColor = gui.add_colorpicker("Logging - Color", color.new(214, 76, 203, 255))
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);
    
    -- WAV Player
    local trackList = gui.add_filedropdown("Radio Track List", "C:\\zapped\\lua", ".wav")
    gui.add_keybind(" ", 0x07); gui.add_keybind(" ", 0x07);

    -- Crosshair
    local crosshairEnabled = gui.add_checkbox("Crosshair Enabled");
    local crosshairColor = gui.add_colorpicker("Crosshair - Color", color.new(214, 76, 203, 255));
    local forceWhenUnscoped = gui.add_checkbox("Crosshair - Only Snipers");
    local crosshairSize = gui.add_slider("Crosshair - Size", 0, 300)
    local crosshairWidth = gui.add_slider("Crosshair - Width", 1, 10)
    local crosshairGap = gui.add_slider("Crosshair - Gap", 0, 300)

    -- Misc Variables
    local localPlayer;
    local savedTick = globalvars.curtime;
    local curTick = globalvars.curtime
    local currentTime = globalvars.curtime;
    local radioCurtime = globalvars.curtime;
    local boolSwap = false;
    local nameChanged = 0;
    local screenSize = engine.screen_size();
    local watermarkFont = renderer.create_font("Verdana", 12, true);
    local loaded = false;
    local values = {};
    local controls = { gui.find("legit_aa"), gui.find("legit_max_ping"), gui.find("fake_lag"), gui.find("fake_lag_trigger_limit") }
    local time = utils.timestamp();
    local vacControls = { gui.find("desync"), gui.find("fake_duck"), gui.find("fake_turn"), gui.find("legit_aa"), gui.find("modifier"), gui.find("offset"), gui.find("pitch") };
    local playing = false;
    local colors = { gui.find("main"), gui.find("accent")  }
    local defaults = { color.new(255, 255, 255, 255), renderer.create_font("Arial", 12, true) }

    -- Load message
    utils.log("Clownemoji.club LUA Loaded | Welcome back, " .. zapped.username .. " | Script made by @neplo and @onion \nFor radio put your downloaded (.wav) music files into C:\\zapped\\lua folder!\n", color.new(235, 64, 52));

    -- Addictional functions
    local function time_to_ticks(time)
        return math.floor(time / globalvars.interval_per_tick + .5)
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

    function drawText(x, y, text, font, color, style)
        if (x ~= nil and y ~= nil and text ~= nil) then
            text = tostring(text);
            if (color == nil) then color = defaults[1]; end
            if (font == nil) then font = defaults[2]; end

            if (style ~= "c" and style ~= "r" and style ~= "cr") then
                renderer.text(x, y, text, color, font);
            else
                local textSize = renderer.get_text_size(text, font);

                if (style == "c") then
                    renderer.text(x - (textSize.x / 2), y - (textSize.y / 2), text, color, font);
                elseif (style == "r") then
                    renderer.text(x - textSize.x, y, text, color, font);
                else
                    renderer.text(x - textSize.x, y - (textSize.y / 2), text, color, font);
                end
            end
        end
    end

    local function tableContains(table, string)
        for i = 1, #table do
            if (table[i] == string) then
                return true;
            end
        end

        return false;
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

    function sendMessage(msg)
        if (msg ~= nil) then
            msg = tostring(msg)

            if (string.len(msg) >= 256) then
                msg = msg:sub(1, 256)
            end

            engine.client_cmd("say " .. msg);
        end
    end

    -- Credits Adrian Mole and user973713
    function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end

    function setupString(str, event)
        local entity = entitylist.get_entity_from_userid(event:get_int("userid"));
        local weapon = event:get_string("weapon");
        local headshot = event:get_bool("headshot");

        if (entity ~= nil and localPlayer ~= nil and weapon ~= nil and headshot ~= nil) then
            local table = mysplit(str, "&");
            local endText = "";

            for i = 1, #table do
                if (table[i] == "user") then
                    endText = endText .. entity:get_name();
                elseif (table[i] == "local") then
                    endText = endText .. localPlayer:get_name();
                elseif (table[i] == "weapon") then
                    endText = endText .. weapon;
                elseif (table[i] == "headshot") then
                    if (headshot) then
                        endText = endText .. "headshot";
                    else
                        endText = endText .. "bodyshot";
                    end
                elseif (table[i] == "username") then
                    endText = endText .. zapped.username;
                elseif (table[i] == "uid") then
                    endText = endText .. zapped.userid;
                else
                    endText = endText .. table[i];
                end
            end
            return endText
        else
            safeLog("[Error] - Invalid Entity\n", 255, 0, 0, 255)
            return ""
        end
    end

    function on_shutdown()
        audio.stop_playback();
    end

    function on_gameevent(e)
        if (e:get_name() == "cs_win_panel_match" and antiReportbot:get_value()) then
            engine.client_cmd("disconnect")
        end 

        if (e:get_name() == "player_death" and enableKillsay:get_value()) then
            local deadEntity = entitylist.get_entity_from_userid(e:get_int("userid"));
            local killerEntity = entitylist.get_entity_from_userid(e:get_int("attacker"));
            localPlayer = entitylist.get_localplayer();
            local color = consoleColor:get_value();
            local r, g, b, a = color.r, color.g, color.b, color.a;

            if (localPlayer ~= nil) then
                if (killerEntity == localPlayer) then
                    if (not deadEntity:is_enemy() and not includeTeammates:get_value()) then return end
                    if (messageKillsay:get_value() == "") then return end
                    local text;

                    if (filterNames:get_value()) then
                        text = setupString(messageKillsay:get_value(), e);
                    else
                        text = messageKillsay:get_value();
                    end

                    sendMessage(text, deadEntity)
                    safeLog("[Message] - " .. text .. "\n", r, g, b, a)
                end
            end

            if (zappedConsoleLogger:get_value()) then
                safeLog("[Event] - " .. e:get_name() .. "\n", r, g, b, a)
                safeLog("[Killer] - " .. entitylist.get_entity_from_userid(e:get_int("attacker")):get_name() .. "\n", r, g, b, a)
                safeLog("[Killed] - " .. entitylist.get_entity_from_userid(e:get_int("userid")):get_name() .. "\n", r, g, b, a)
                safeLog("[Weapon] - " .. e:get_string("weapon") .. "\n", r, g, b, a)
            end
        end
    end

    function runClantag()
        localPlayer = entitylist.get_localplayer();

        if (localPlayer ~= nil and engine.in_game()) then
            if (enableClantagChanger:get_value()) then
                if (not loaded) then currentTime = globalvars.curtime; loaded = true; end
                    if (globalvars.curtime - currentTime > speedCheck:get_value() / 100) then
                    currentTime = globalvars.curtime;
                    local indices = {};
                    for i = 1, string.len(clantag:get_value()) do
                        table.insert(indices, i - 1);
                    end

                    local tickinterval = globalvars.interval_per_tick;
                    local tickcount = globalvars.tickcount + time_to_ticks(game.latency)
                    local i = tickcount / time_to_ticks(speedCheck:get_value() / 100);
                    i = math.floor(i % #indices)
                    i = indices[i+1]+1

                    utils.set_clan_tag(string.sub(clantag:get_value(), i, i + #indices))
                end
            end
        else
            currentTime = globalvars.curtime;
            loaded = false;
        end
    end

    function runAudio()
        local var = trackList:get_value();

        if (var ~= nil) then
            if (var ~= "") then
                if (var == "Disabled") then
                    if (playing) then
                        playing = false;
                        audio.stop_playback()
                    end
                else
                    if (not playing) then
                        playing = true;
                        audio.play_sound(var)
                    end
                end
            end
        end
    end

    function runAntiFlicker() 
        if (utils.timestamp() - time >= 1) then
            if (not keys.key_down(0x01)) then
                localPlayer = entitylist.get_localplayer();
        
                if (localPlayer ~= nil and engine.in_game()) then
                    values = { game.focused, game.fps, game.latency };

                    if (values[1] ~= nil and values[2] ~= nil and values[3] ~= nil) then
                        if (enableAntiFlicker:get_value()) then
                            controls[2]:set_value(0);
                            local allowed = true;
                            -- Credits nekowo
                            local velocity = vector.new(safeGetProp(localPlayer, "m_vecVelocity[0]", nil, true), safeGetProp(localPlayer, "m_vecVelocity[1]", nil, true), safeGetProp(localPlayer, "m_vecVelocity[2]", nil, true)):length2d();
                                
                            if (checkFocus:get_value()) then allowed = values[1]; end
                            if (checkChoke:get_value() and controls[3]:get_value() ~= 0 or controls[4]:get_value() ~= 0) then allowed = false; end
                            if (checkFPS:get_value() ~= 0) then if (values[2] < checkFPS:get_value()) then allowed = false; end end
                            if (checkPing:get_value() ~= 0) then if (values[3] > checkPing:get_value()) then allowed = false; end end
                            if (checkVelocity:get_value() ~= 0) then if (velocity > checkVelocity:get_value()) then allowed = false; end end
        
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
    end

    local time2 = utils.timestamp();
    function runAntiAuth()
        if (utils.timestamp() - time2 >= 1) then
            if (retardCheck:get_value()) then
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
    
                                time2 = utils.timestamp();
                            end
                        end
                    end
                end
            end
        end
    end

    function drawCrosshair()
        if (engine.in_game()) then
            if (crosshairEnabled:get_value()) then
                local snipers = { "G3SG1", "AWP", "SSG-08", "SCAR-20" }

                local currentWeapon = entitylist.get_player_weapon(localPlayer);
                currentWeapon = currentWeapon:get_name();

                local crosshairClr = crosshairColor:get_value();
                local color2 = crosshairClr;

                local scopedProp = safeGetProp(localPlayer, "m_bIsScoped");
                local rendered = false;

                if (forceWhenUnscoped:get_value() or scopedProp == true) then
                    if (tableContains(snipers, currentWeapon)) then
                        rendered = true;
                    end
                elseif (forceWhenUnscoped:get_value() == false and scopedProp == false) then
                    rendered = true;
                end

                if (rendered) then
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2), (screenSize.y / 2) - (crosshairSize:get_value() + crosshairGap:get_value()), crosshairWidth:get_value(), crosshairSize:get_value(), true, color2, crosshairClr);
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2), (screenSize.y / 2) + crosshairGap:get_value(), crosshairWidth:get_value(), crosshairSize:get_value(), true, crosshairClr, color2);
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2) - crosshairSize:get_value() - crosshairGap:get_value(), (screenSize.y / 2) - (crosshairWidth:get_value() / 2), crosshairSize:get_value(), crosshairWidth:get_value(), false, color2, crosshairClr);
                    renderer.gradient_rect((screenSize.x / 2) + (crosshairWidth:get_value() / 2) + crosshairGap:get_value(), (screenSize.y / 2) - (crosshairWidth:get_value() / 2), crosshairSize:get_value(), crosshairWidth:get_value(), false, crosshairClr, color2);
                end
            end
        end
    end

    function drawShadow(x, y, w, h, size, startOpacity)
        local step = startOpacity / size;
        
        for i = 1, size do
            local newOpacity;
            if (startOpacity - (step * (i - 1)) < 0) then
                newOpacity = 0;
            else
                newOpacity = startOpacity - (step * (i - 1));
            end

            renderer.rect(x - (i - 1), y - (i - 1), w + ((i - 1) * 2), h + ((i - 1) * 2), color.new(0, 0, 0, newOpacity))
        end
    end

    function drawText(x, y, text, font, color, style)
        if (x ~= nil and y ~= nil and text ~= nil) then
            text = tostring(text);
            if (color == nil) then color = defaults[1]; end
            if (font == nil) then font = defaults[2]; end
    
            if (style ~= "c" and style ~= "r" and style ~= "cr" and style ~= "cl") then
                renderer.text(x, y, text, color, font);
            else
                local textSize = renderer.get_text_size(text, font);
    
                if (style == "c") then
                    renderer.text(x - (textSize.x / 2), y - (textSize.y / 2), text, color, font);
                elseif (style == "r") then
                    renderer.text(x - textSize.x, y, text, color, font);
                elseif (style == "cl") then
                    renderer.text(x, y - (textSize.y / 2), text, color, font);
                else
                    renderer.text(x - textSize.x, y - (textSize.y / 2), text, color, font);
                end
            end
        end
    end

    function drawWatermark()
        if (enableWatermark:get_value()) then
            renderer.set_clip(screenSize.x - 260, 10, 250, 21)
            renderer.filled_rect(screenSize.x - 260, 10, 250, 3, colors[2]:get_value());
            renderer.filled_rect(screenSize.x - 260, 14, 250, 18, colors[1]:get_value());
            local text;
            if (renderer.get_text_size("clownemoji.club | v" .. version .. " | " .. zapped.username).x > 230) then
                text = "clownemoji | v" .. version .. " | " .. zapped.username;
            else
                text = "clownemoji.club | v" .. version .. " | " .. zapped.username;
            end

            drawText(screenSize.x - 135, 23, text, font, color.new(255, 255, 255), "c");
            renderer.remove_clip()
        end
    end

    function runNameSpam()
        if (engine.in_game()) then
            localPlayer = entitylist.get_localplayer();
            curTick = globalvars.curtime;
            if (savedTick > curTick) then
                savedTick = globalvars.curtime;
            end

            if (localPlayer ~= nil) then
                if (nameChanged <= 10) then
                    if (enableNameSpam:get_value()) then
                        if (curTick - savedTick >= nameSpamSpeed:get_value() / 1000) then
                            if (boolSwap) then
                                safeSetName(name:get_value())
                                boolSwap = false;
                            else
                                safeSetName("ß·" .. name:get_value())
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
            loaded = false;
        end
    end

    function on_render()
        if (greyLobbyColor:get_value()) then
            engine.client_cmd("cl_color 64 64 64 64");
        end

        drawCrosshair();
        drawWatermark();
        runClantag();
        runAntiFlicker();
        runAntiAuth();
        runAudio();
        runNameSpam();
    end
end