local Vector = {};
Vector.__index = Vector;

local Vector2D = {};
Vector2D.__index = Vector2D;

local Colors = {};
Colors.__index = Colors;

local onion = {};

function Color(r, g, b, a)
    if (r == nil or type(r) ~= "number") then r = 0; end
    if (g == nil or type(g) ~= "number") then g = 0; end
    if (b == nil or type(b) ~= "number") then b = 0; end
    if (a == nil or type(a) ~= "number") then a = 255; end

    r = r or 0;
    g = g or 0;
    b = b or 0;
    a = a or 255;

    return setmetatable({ r = r, g = g, b = b, a = a }, Colors);
end

function Vector3(x, y, z)
    if (x == nil or type(x) ~= "number") then x = 0; end
    if (y == nil or type(y) ~= "number") then y = 0; end
    if (z == nil or type(z) ~= "number") then z = 0; end

    x = x or 0;
    y = y or 0;
    z = z or 0;

    return setmetatable({ x = x, y = y, z = z }, Vector);
end

function Vector2(x, y)
    if (x == nil or type(x) ~= "number") then x = 0; end
    if (y == nil or type(y) ~= "number") then y = 0; end

    x = x or 0;
    y = y or 0;

    return setmetatable({ x = x, y = y }, Vector2D);
end

function Vector.__eq(a, b) -- Equal to Vector
    return a.x == b.x and a.y == b.y and a.z == b.z;
end

function Vector2D.__eq(a, b) -- Equal to Vector2D
    return a.x == b.x and a.y == b.y;
end

function Vector.__um(a) -- Unary Minus
    return Vector3(-a.x, -a.y, -a.z);
end

function Vector2D.__um(a) -- Unary Minus
    return Vector2(-a.x, -a.y);
end

function Vector.__add(a, b) -- Add Vectors
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector3(a.x + b, a.y + b, a.z + b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector3(a + b.x, a + b.y, a + b.z);
    end
end

function Vector2D.__add(a, b) -- Add Vector2Ds
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector2(a.x + b.x, a.y + b.y);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector2(a.x + b, a.y + b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector2(a + b.x, a + b.y);
    end
end

function Vector.__sub(a, b) -- Subtract Vectors
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector3(a.x - b, a.y - b, a.z - b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector3(a - b.x, a - b.y, a - b.z);
    end
end

function Vector2D.__sub(a, b) -- Subtract Vector2Ds
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector2(a.x - b.x, a.y - b.y);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector2(a.x - b, a.y - b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector2(a - b.x, a - b.y);
    end
end

function Vector.__mul(a, b) -- Multiply Vectors
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector3(a.x * b.x, a.y * b.y, a.z * b.z);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector3(a.x * b, a.y * b, a.z * b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector3(a * b.x, a * b.y, a * b.z);
    end
end

function Vector2D.__mul(a, b) -- Multiply Vector2Ds
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector2(a.x * b.x, a.y * b.y);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector2(a.x * b, a.y * b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector2(a * b.x, a * b.y);
    end
end

function Vector.__div(a, b) -- Divide Vectors
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector3(a.x / b.x, a.y / b.y, a.z / b.z);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector3(a.x / b, a.y / b, a.z / b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector3(a / b.x, a / b.y, a / b.z);
    end
end

function Vector2D.__div(a, b) -- Divide Vector2Ds
    if( type(a) == "table" and type(b) == "table" ) then
        return Vector2(a.x / b.x, a.y / b.y);
    elseif( type(a) == "table" and type(b) == "number" ) then
        return Vector2(a.x / b, a.y / b);
    elseif( type(a) == "number" and type(b) == "table" ) then
        return Vector2(a / b.x, a / b.y);
    end
end

function Colors:get() -- Return all Color Values
    return self.r, self.g, self.b, self.a;
end

function Colors:r() -- Returns Color Red Value
    return self.r;
end

function Colors:g() -- Returns Color Green Value
    return self.g;
end

function Colors:b() -- Returns Color Blue Value
    return self.b;
end

function Colors:a() -- Returns Color Alpha Value
    return self.a;
end

function Colors:string() -- Color String
    return self.r .. ", " .. self.g .. ", " .. self.b .. ", " .. self.a;
end

function Vector:string() -- Vector String
    return self.x .. ", " .. self.y .. ", " .. self.z;
end

function Vector2D:string() -- Vector2D String
    return self.x .. ", " .. self.y;
end

function Colors:print() -- Print Color Values to console
    print(self.r .. ", " .. self.g .. ", " .. self.b .. ", " .. self.a);
end

function Vector:print() -- Print Vector Values to console
    print(self.x .. ", " .. self.y .. ", " .. self.z);
end

function Vector2D:print() -- Print Vector2D Values to console
    print(self.x .. ", " .. self.y);
end

function Vector:clear() -- Clear all Vector Values
    self.x, self.y, self.z = 0, 0, 0;
end

function Vector2D:clear() -- Clear all Vector2D Values
    self.x, self.y = 0, 0;
end

function Vector:unpack() -- Clear all Vector Values
    return self.x, self.y, self.z;
end

function Vector2D:unpack() -- Clear all Vector2D Values
    return self.x, self.y;
end

function Vector:length2D() -- Length of Vector x and y values, wikipedia.org/wiki/Pythagorean_theorem
    return math.sqrt((self.x * self.x) + (self.y * self.y));
end

function Vector2D:length() -- Length of Vector2D x and y values, wikipedia.org/wiki/Pythagorean_theorem
    return math.sqrt((self.x * self.x) + (self.y * self.y));
end

function Vector:length() -- Length of Vector x, y, and z values, wikipedia.org/wiki/Pythagorean_theorem
    return math.sqrt((self.x * self.x) + (self.y * self.y) + (self.z * self.z));
end

function Vector:dot(vec) -- Dot product from Vector and another Vector
    return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z);
end

function Vector2D:dot(vec) -- Dot product from Vector2D and another Vector2D
    return (self.x * vec.x) + (self.y * vec.y);
end

function Vector:cross(vec) -- Cross product from Vector and another Vector
    return Vector3((self.y * vec.z) - (self.z * other.y), (self.z * vec.x) - (self.x * other.z), (self.x * vec.y) - (self.y * other.x));
end

function Vector:distTo(vec) -- Length from Vector to another Vector
    return (vec - self):length();
end

function Vector2D:distTo(vec) -- Length from Vector2D to another Vector2D
    return (vec - self):length();
end

function Vector:isZero(tolerance) -- Bool if values are within tolerance
    if (self.x < tolerance and self.x > -tolerance and self.y < tolerance and self.y > -tolerance and self.z < tolerance and self.z > -tolerance) then
        return true;
    end

    return false;
end

function Vector2D:isZero(tolerance) -- Bool if values are within tolerance
    if (self.x < tolerance and self.x > -tolerance and self.y < tolerance and self.y > -tolerance) then
        return true;
    end

    return false;
end

function Vector:normalize() -- Normalize Vector values and return length
    local length = self:length();
    if (length <= 0) then return 0; end

    self.x = self.x / length;
    self.y = self.y / length;
    self.z = self.z / length;

    return length;
end

function Vector2D:normalize() -- Normalize Vector2D values and return length
    local length = self:length();
    if (length <= 0) then return 0; end

    self.x = self.x / length;
    self.y = self.y / length;

    return length;
end

function trace(vector1, vector2, entity)
    local fraction, entHit = client.trace_line(entity, vector1.x, vector1.y, vector1.z, vector2.x, vector2.y, vector2.z)
    local endVector = Vector3(vector1.x + ((vector2.x - vector1.x) * fraction), vector1.y + ((vector2.y - vector1.y) * fraction), vector1.z + ((vector2.z - vector1.z) * fraction));
    local hit = false;
    
    if (fraction < 1) then
        hit = true;
    end
    
    return setmetatable({ fraction = fraction, entHit = entHit, endVector = endVector, hit = hit }, onion);
end

function degreesToRadians(degree)
    return setmetatable({ radian = degree * math.pi / 180.0 }, onion);
end

function fromAngle(angleX, angleY)
    return setmetatable({ angle = math.cos(degreesToRadians(angleX)) * math.cos(degreesToRadians(angleY)), math.cos(degreesToRadians(angleX)) * math.sin(degreesToRadians(angleY)), -1 * math.sin(degreesToRadians(angleX)) }, onion);
end

function getAimTrace()
    local localPlayer = entity.get_local_player();

    if (localPlayer) then
        local eyeX, eyeY, eyeZ = client.eye_position();
        local pitch, yaw = client.camera_angles();
        local sinPitch = math.sin(math.rad(pitch));
        local cosPitch = math.cos(math.rad(pitch));
        local sinYaw = math.sin(math.rad(yaw));
        local cosYaw = math.cos(math.rad(yaw));
        
        local dirVector = Vector3(cosPitch * cosYaw, cosPitch * sinYaw, -sinPitch);
        local trace = trace(Vector3(eyeX, eyeY, eyeZ), Vector3(eyeX + (dirVector.x * 8192), eyeY + (dirVector.y * 8192), eyeZ + (dirVector.z * 8192)), localPlayer);

        local endX, endY, endZ = eyeX + (dirVector.x * (8192 * trace[1] + 128)), eyeY + (dirVector.y * (8192 * trace[1] + 128)), eyeZ + (dirVector.z * (8192 * trace[1] + 128));

        local worldX, worldY = renderer.world_to_screen(endX, endY, endZ);
        return setmetatable({ position = Vector2(worldX, worldY), origin = Vector3(endX, endY, endZ) }, onion);
    end

    return setmetatable({ position = nil, origin = nil }, onion);
end

function draw3DCircle(origin, radius, radius2, color, percent, outline, rotated)
    local localPlayer = entity.get_local_player();

    if (localPlayer) then
        local prevScreenPosX, prevScreenPosY = 0, 0;
        local prevScreenPos2X, prevScreenPos2Y = 0, 0;
        local step = math.pi * 2 / 72;
        if (rotated == nil) then rotated = 0; end
        local addedRotation = (math.pi * 2 * radius) / (360 / rotated);

        local screenPosX, screenPosY = 0, 0;
        local screenPos2X, screenPos2Y = 0, 0;
        local screenX, screenY = renderer.world_to_screen(origin.x, origin.y, origin.z);

        for rotation = 0, (math.pi * 2) * (percent / 100), step do
            local posX, posY, posZ = radius * math.cos(rotation + addedRotation) + origin.x, radius * math.sin(rotation + addedRotation) + origin.y, origin.z;
            local pos2X, pos2Y, pos2Z = radius2 * math.cos(rotation + addedRotation) + origin.x, radius2 * math.sin(rotation + addedRotation) + origin.y, origin.z;
            screenPosX, screenPosY = renderer.world_to_screen(posX, posY, posZ);
            screenPos2X, screenPos2Y = renderer.world_to_screen(pos2X, pos2Y, pos2Z);

            if (prevScreenPosX ~= 0 and prevScreenPosY ~= 0) then
                renderer.triangle(screenPos2X, screenPos2Y, prevScreenPos2X, prevScreenPos2Y, prevScreenPosX, prevScreenPosY, color.r, color.g, color.b, color.a)
                renderer.triangle(screenPos2X, screenPos2Y, screenPosX, screenPosY, prevScreenPosX, prevScreenPosY, color.r, color.g, color.b, color.a)

                if (outline) then
                    renderer.line(screenPosX, screenPosY, prevScreenPosX, prevScreenPosY, color.r, color.g, color.b, 255);
                    renderer.line(screenPos2X, screenPos2Y, prevScreenPos2X, prevScreenPos2Y, color.r, color.g, color.b, 255);
                end
            end

            prevScreenPosX, prevScreenPosY = screenPosX, screenPosY;
            prevScreenPos2X, prevScreenPos2Y = screenPos2X, screenPos2Y;
        end
    end
end

setmetatable(onion, {__index = onyo});
return onion;