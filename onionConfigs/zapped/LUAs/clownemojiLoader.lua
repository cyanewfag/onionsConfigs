local scrSize = engine.screen_size();
local keyTable = { {0xBF, "/"}, {0x20, " "}, {0x30, "0"}, {0x31, "1"}, {0x32, "2"}, {0x33, "3"}, {0x34, "4"}, {0x35, "5"}, {0x36, "6"}, {0x37, "7"}, {0x38, "8"}, {0x39, "9"}, {0x41, "A"}, {0x42, "B"}, {0x43, "C"}, {0x44, "D"}, {0x45, "E"}, {0x46, "F"}, {0x47, "G"}, {0x48, "H"}, {0x49, "I"}, {0x4A, "J"}, {0x4B, "K"}, {0x4C, "L"}, {0x4D, "M"}, {0x4E, "N"}, {0x4F, "O"}, {0x50, "P"}, {0x51, "Q"}, {0x52, "R"}, {0x53, "S"}, {0x54, "T"}, {0x55, "U"}, {0x56, "V"}, {0x57, "W"}, {0x58, "X"}, {0x59, "Y"}, {0x5A, "Z"} };
local mouseVars = { false, 0, 0, false, 0, 0, "", false, 0, 0 };
local forms = {{"Login Form", 300, 250, (scrSize.x / 2) - 150, (scrSize.y / 2) - 200, {}}, {"LUA Table", 750, 350, (scrSize.x / 2) - 375, (scrSize.y / 2) - 175, {}}};
local colors = {color.new(38, 38, 38), color.new(48, 48, 48), color.new(189, 137, 255), color.new(58, 58, 58), color.new(68, 68, 68)};
local fonts = { renderer.create_font("Arial", 12, true) };
local defaults = { color.new(255, 255, 255), renderer.create_font("Arial", 12, true) }
local selectedIndex = 0;
local selectedForm = "";
local login = { false, "", "" };
local luaTable = { 0, false, "" };

-- Misc Functions
function round(x, n) -- Credits toma91
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function textSplit(inputstr, sep) -- Credits Adrian Mole and user973713
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
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

function tableContains(table, value)
    for i = 1, #table do
        if (table[i][1] == value) then
            return true;
        end
    end

    return false;
end

function findTableIndex(table, value)
    for i = 1, #table do
        if (table[i][1] == value) then
            return i;
        end
    end

    return 0;
end

-- Custom Drawing Functions
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

function drawRoundedRect(x, y, w, h, r, color)
    if (x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        if (color == nil) then color = defaults[1]; end
        if (color == nil) then r = 0; end

        renderer.filled_circle(x + r, y + r, r, color);
        renderer.filled_circle(x + r, y + h - r, r, color);
        renderer.filled_circle(x + w - r, y + r, r, color);
        renderer.filled_circle(x + w - r, y + h - r, r, color);
        renderer.filled_rect(x + r, y, w - (r * 2), h, color)
        renderer.filled_rect(x, y + r, w, h - (r * 2), color)
    end
end

function drawRectShadow(x, y, w, h, rectColor, r)
    if (x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        local curAlpha = rectColor.a;

        if (curAlpha >= r) then
            local alphaStep = round(curAlpha / r, 0);

            for i = 1, r do
                renderer.rect(x - i, y - i, w + (i * 2), h + (i * 2), rectColor);
                local red, g, b, a = rectColor.r, rectColor.g, rectColor.b, round(rectColor.a - alphaStep, 0);

                if (i ~= r - 1) then
                    rectColor = color.new(red, g, b, a);
                else
                    rectColor = color.new(red, g, b, a);
                end
            end
        end
    end
end

-- Handlers
function mouseHandler()
    if (game.focused) then
        local mousePos = keys.get_mouse()
        mouseVars[2], mouseVars[3] = mousePos.x, mousePos.y;

        if (keys.key_down(0x01)) then
            if (keys.key_pressed(0x01)) then
                mouseVars[8], mouseVars[9], mouseVars[10] = true, mouseVars[2], mouseVars[3];
                selectedIndex = 0;
            else
                mouseVars[8], mouseVars[9], mouseVars[10] = false, 0, 0;
            end

            if (not mouseVars[1]) then
                mouseVars[1] = true;

                for i = 1, #forms do
                    if (mouseVars[2] >= forms[i][4] and mouseVars[2] <= forms[i][4] + forms[i][2] and mouseVars[3] >= forms[i][5] and mouseVars[3] <= forms[i][5] + forms[i][3]) then
                        mouseVars[4], mouseVars[5], mouseVars[6], mouseVars[7] = true, forms[i][4] - mouseVars[2], forms[i][5] - mouseVars[3], forms[i][1];
                    end
                end
            end

            if (mouseVars[4]) then
                for i = 1, #forms do
                    if (forms[i][1] == mouseVars[7]) then
                        forms[i][4], forms[i][5] = mouseVars[2] + mouseVars[5], mouseVars[3] + mouseVars[6];
                    end
                end
            end
        else
            mouseVars[1], mouseVars[4], mouseVars[8] = false, false, false;
        end
    end
end

function loginHandler(variables)
    if (#variables == 3) then
        local username = variables[1];
        local password = variables[2];
        local cheat = variables[3];

        if (http.get("https://clownemoji.club/cheat/api.php?user=" .. username .. "&pass=" .. password .. "&cheat=" .. cheat .. "&auth=1") == "true") then
            return true;
        else
            return false;
        end
    else
        return false;
    end
end

function textHandler()
    if (selectedIndex ~= 0 and selectedForm ~= "") then
        local text = "";
        local formsIndex;
        local index;

        for i = 1, #forms do
            if (forms[i][1] == selectedForm) then
                formsIndex = i;
                index = selectedIndex;
            end
        end

        for i = 1, #keyTable do
            if (keys.key_pressed(keyTable[i][1])) then
                if (not keys.key_down(0x10)) then
                    text = text .. string.lower(keyTable[i][2]);
                else
                    text = text .. keyTable[i][2];
                end
            end
        end

        forms[formsIndex][6][index][2] = forms[formsIndex][6][index][2] .. text;

        if (keys.key_pressed(0x08)) then
            if (#forms[formsIndex][6][index][2] ~= 0) then
                forms[formsIndex][6][index][2] = forms[formsIndex][6][index][2]:sub(1, #forms[formsIndex][6][index][2] - 1)
            end
        end
    end
end

function drawHandler(name, on)
    for i = 1, #forms do
        if (forms[i][1] == name) then
            if (on) then
                renderer.set_clip(forms[i][4], forms[i][5], forms[i][2], forms[i][3])
            else
                renderer.remove_clip();
            end
        end
    end
end

function luaTableHandler(name)
    if (not luaTable[2]) then
        local values = http.get("https://clownemoji.club/cheat/api.php?user=" .. login[2] .. "&pass=" .. login[3] .. "&cheat=zapped&auth=2");
        luaTable[3] = values;
        luaTable[2] = true;
        safeLog(values)
    else
        for i = 1, #forms do
            if (forms[i][1] == name) then
                local usedY = 0;
                local value = textSplit(luaTable[3], "/");
                if (value ~= nil) then
                    if (#value > 0) then
                        for f = 1, #value do
                            if (value[f] ~= "") then
                                renderer.filled_rect(forms[i][4] + 10, forms[i][5] + 52 + usedY, forms[i][2] - 20, 26, colors[2]);
                                renderer.rect(forms[i][4] + 10, forms[i][5] + 52 + usedY, forms[i][2] - 20, 26, colors[4]);
                                drawText(forms[i][4] + 16, forms[i][5] + 65 + usedY, value[f], nil, nil, "cl")
                                usedY = usedY + 32
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Controls
function drawForm(name)
    for i = 1, #forms do
        if (forms[i][1] == name) then
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], forms[i][3], colors[1]);
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], 32, colors[2]);
            renderer.gradient_rect(forms[i][4], forms[i][5] + 22, forms[i][2], 12, true, colors[2], colors[1]);
            renderer.rect(forms[i][4], forms[i][5], forms[i][2], forms[i][3], colors[2]);
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], 2, colors[3]);
            drawText(forms[i][4] + (forms[i][2] / 2), forms[i][5] + 14, name, nil, nil, "c")

            return {forms[i][4], forms[i][5], forms[i][2], forms[i][3]}
        end
    end
end

function addTextbox(parentName, varname, x, y, w, h, centered)
    if (varname ~= nil and x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        local index;
        local formsIndex;
        if (parentName ~= nil) then
            for i = 1, #forms do
                if (forms[i][1] == parentName) then
                    if (varname ~= nil) then
                        if (not tableContains(forms[i][6], varname)) then
                            table.insert(forms[i][6], {varname, ""})
                        end
                    end

                    index = findTableIndex(forms[i][6], varname);
                    formsIndex = i;

                    x, y = x + forms[i][4], y + forms[i][5];

                    if (centered) then
                        x = (forms[i][4] + (forms[i][2] / 2)) - (w / 2)
                    end
                end
            end
        end

        renderer.set_clip(x, y, w + 1, h + 1);
        if (mouseVars[2] >= x and mouseVars[2] <= x + w and mouseVars[3] >= y and mouseVars[3] <= y + h) then
            if (selectedIndex ~= index) then
                renderer.filled_rect(x, y, w, h, colors[2]);
                renderer.rect(x, y, w, h, colors[4]);
            end

            if (keys.key_pressed(0x01)) then
                selectedForm = parentName;
                selectedIndex = index;
            end
        end

        if (selectedIndex == index) then
            renderer.filled_rect(x, y, w, h, colors[2]);
            renderer.rect(x, y, w, h, colors[4]);
        else
            renderer.filled_rect(x, y, w, h, colors[1]);
            renderer.rect(x, y, w, h, colors[2]);
        end

        drawText(x + (w / 2), y + (h / 2), forms[formsIndex][6][index][2], nil, nil, "c")
        renderer.remove_clip();
        return forms[formsIndex][6][index][2];
    end
end

function addButton(parentName, text, x, y, w, h, centered, func, varname, variables)
    if (func ~= nil and x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        if (text == nil) then text = ""; end text = tostring(text);
        if (parentName ~= nil) then
            for i = 1, #forms do
                if (forms[i][1] == parentName) then
                    if (varname ~= nil) then
                        if (not tableContains(forms[i][6], varname)) then
                            table.insert(forms[i][6], {varname})
                        end
                    end

                    x, y = x + forms[i][4], y + forms[i][5];
                    
                    if (centered) then
                        x = (forms[i][4] + (forms[i][2] / 2)) - (w / 2)
                    end
                end
            end
        end

        if (mouseVars[2] >= x and mouseVars[2] <= x + w and mouseVars[3] >= y and mouseVars[3] <= y + h) then
            if (keys.key_down(0x01)) then
                renderer.filled_rect(x, y, w, h, colors[4]);
                renderer.rect(x, y, w, h, colors[5]);
            else
                renderer.filled_rect(x, y, w, h, colors[2]);
                renderer.rect(x, y, w, h, colors[4]);
            end

            if (keys.key_pressed(0x01)) then
                selectedIndex = 0;
                local returnValue = func(variables);

                if (returnValue ~= nil) then
                    return returnValue;
                end
            end
        else
            renderer.filled_rect(x, y, w, h, colors[1]);
            renderer.rect(x, y, w, h, colors[2]);
        end

        drawText(x + (w / 2), y + (h / 2), text, nil, nil, "c")
    end
end

-- Callbacks
function on_render()
    -- Handlers
    mouseHandler();
    textHandler();

    if (not login[1]) then
        -- Login Form
        drawHandler("Login Form", true);
        drawForm("Login Form");
        drawHandler("Login Form", false);
        local username = addTextbox("Login Form", "var_login_username", 35, 75, 125, 35, true)
        local password = addTextbox("Login Form", "var_login_password", 35, 120, 125, 35, true)
        local value = addButton("Login Form", "Login", 35, 165, 125, 35, true, loginHandler, nil, {username, password, "zapped"});
        
        if (value == true) then
            login = { true, username, password };
        end
    else
        if (game.focused) then
            drawHandler("LUA Table", true);
            local rectTable = drawForm("LUA Table");
            luaTableHandler("LUA Table");
            drawHandler("LUA Table", false);
        end
    end
end