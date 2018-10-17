-- Add a chat command to log the player's current location to the ElunaErrors log

require("Constants")

local function OnChat(event, player, msg, Type, lang)
    if (msg == "_loc") then
        local x, y, z, _ = player:GetLocation()
        local mapId = player:GetMapId()
        local loc = "Loc: " .. mapId .. "," .. x .. "," .. y .. "," .. z
        player:Say(loc, 0)
        PrintError(loc)
    end
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_CHAT, OnChat)