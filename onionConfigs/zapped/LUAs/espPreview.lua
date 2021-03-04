local colors = { gui.find("accent"):get_value(), gui.find("main"), gui.find("title_bar"):get_value(), gui.find("controls"):get_value(), color.new(255, 255, 255, 255) };
local username = zapped.username;
local watermarkFont = renderer.create_font("Comic Sans MS", 25, true);
local watermarkFont2 = renderer.create_font("Comic Sans MS", 15, true);

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

function zappedWindow(onMenu, name, x, y, w, h)
    renderer.filled_rect(x, y, w, h, colors[2]:get_value());
    renderer.filled_rect(x, y, w, 34, colors[3]);
    renderer.filled_rect(x, y + h - 15, w, 15, colors[3]);
    renderer.logo(x + 3, y + 3, 29, 29, colors[5])
    drawText(x + 40, y + 17, "ZAPPED.CC", watermarkFont, colors[5], "cl")
    drawText(x + w - 10, y + 17, name, watermarkFont, colors[5], "cr")
    drawText(x + 10, y + h - 8, username, watermarkFont2, colors[5], "cl")
    local time = utils.format_timestamp(utils.timestamp() + utils.timezone_adjust(), "%I") .. ":" .. utils.format_timestamp(utils.timestamp() + utils.timezone_adjust(), "%M") .. ":" .. utils.format_timestamp(utils.timestamp() + utils.timezone_adjust(), "%S");
    drawText(x + w - 10, y + h - 8, tostring(time) .. " - Beta Build", watermarkFont2, colors[5], "cr")
end

function on_render()
    zappedWindow(true, "CONSOLE", 10, 10, 350, 200);
end