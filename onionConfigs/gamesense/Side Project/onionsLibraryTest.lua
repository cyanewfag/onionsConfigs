require( "onionsLibrary" );

local localPlayer = entity.get_local_player();
local playerResource = entity.get_player_resource();
local gameRules = entity.get_game_rules();
local scrW, scrH = client.screen_size();

client.set_event_callback("paint", function()
    localPlayer = entity.get_local_player();
    playerResource = entity.get_player_resource();
    gameRules = entity.get_game_rules();

    if (localPlayer) then
        local originX, originY, originZ = entity.get_origin(localPlayer);
        local traced = client.trace_line(localPlayer, originX, originY, originZ, originX, originY, originZ - 20);
        local originScrX, originScrY = renderer.world_to_screen(originX, originY, originZ);
        local newScrX, newScrY = renderer.world_to_screen(originX, originY, originZ - (20 * traced));
        local gangsterTrace = trace(Vector3(originX, originY, originZ), Vector3(originX, originY, originZ - 10000), localPlayer);
        local percent = (originZ - gangsterTrace.endVector.z) / 52;
        if (percent > 1) then percent = 1; end
        if (percent < 0.05) then percent = 0; end

        renderer.line(originScrX, originScrY, newScrX, newScrY, 255, 255, 255, 255);
        
        draw3DCircle(Vector3(originX, originY, originZ - (20 * traced)), 25, 0, Color(255, 255, 255, 150), 100, true)
        draw3DCircle(Vector3(originX, originY, originZ - (20 * traced)), 25, 20, Color(0, 255, 0, 150), 100 * percent, true)
    end
end)