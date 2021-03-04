local test = gui.add_filedropdown("Penis", "C:\\zapped\\lua", ".wav")
local playing = false;

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

function on_render()
    local var = test:get_value();

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

audio.stop_playback()