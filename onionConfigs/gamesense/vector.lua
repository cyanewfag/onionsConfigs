-- require vector3 math lib
require( "vector3" );
 
-- localize
local tostring      = tostring;
local string_format = string.format;
 
-- cheat related
local cl_log                = client.log;
local cl_set_event_callback = client.set_event_callback;
local cl_draw_text          = client.draw_text;
local cl_w2s                = client.world_to_screen;
 
local ent_get_all  = entity.get_all;
local ent_get_prop = entity.get_prop;
 
local glob_curtime = globals.curtime;
 
local function on_paint_callback( ctx )
    local c4;
    local c4_origin;
    local c4_origin_screen;
    local explode_time;
   
    -- wait for C4 to be active
    c4 = ent_get_all( "CPlantedC4" )[ 1 ];
    if( not c4 ) then
        return;
    end
   
    -- get C4 position / screen position
    -- note; notice how you can construct a Vector3 object
    c4_origin        = Vector3( ent_get_prop( c4, "m_vecOrigin" ) );
    c4_origin_screen = Vector3( cl_w2s( ctx, c4_origin:unpack() ) );
 
    -- debug log...
    cl_log( "c4_origin: " .. tostring( c4_origin ) .. " | " .. tostring( c4_origin_screen ) );
   
    -- get time until C4 explodes
    explode_time = ent_get_prop( c4, "m_flC4Blow" ) - glob_curtime();
	if( explode_time <= 0.0 ) then
        return;
    end
   
    -- render some info on the C4
    cl_draw_text( ctx, c4_origin_screen.x, c4_origin_screen.y, 255, 255, 255, 255, "c", 0, "c4" );
    cl_draw_text( ctx, c4_origin_screen.x, c4_origin_screen.y + 18, 255, 255, 255, 255, "c", 0, string_format( "%.1f", explode_time ) );
end
 
cl_set_event_callback( "paint", on_paint_callback );