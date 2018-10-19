-- Add a chat command to log the player's current location to the ElunaErrors log

require("Constants")

local function OnChat(event, player, msg, Type, lang)
    if (msg == "_loc") then
        local x, y, z, _ = player:GetLocation()
        local mapId = player:GetMapId()
        local loc = "Loc: " .. mapId .. "," .. string.format("%.2f", x) .. "," .. string.format("%.2f", y) .. "," .. string.format("%.2f", z)
        player:Say(loc, 0)
        PrintError(loc)
    end
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_CHAT, OnChat)