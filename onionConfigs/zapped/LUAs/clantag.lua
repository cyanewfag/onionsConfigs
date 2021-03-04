utils.log("Clownemoji.club Synced Clantags | Welcome back, " .. zapped.username .. " | Script made by @neplo and @onion \n", color.new(110,221,255));

-- Controls
local enableAntiFlicker = gui.add_checkbox("Clantag Changer", true);
local clantag = gui.add_textbox("Clantag", "clownemoji");
local speedCheck = gui.add_slider("Speed (ms)", 5, 500, 35);

-- Misc Variables
local localPlayer = entitylist.get_localplayer();
local currentTime = globalvars.curtime;
local loaded = false;

local function time_to_ticks(time)
	return math.floor(time / globalvars.interval_per_tick + .5)
end

function on_render()
    localPlayer = entitylist.get_localplayer();

    if (localPlayer ~= nil and engine.in_game()) then
        if (enableAntiFlicker:get_value()) then
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