require("Constants")

local function OnChat(event, player, msg, Type, lang)
    if (msg:lower() == "gethealth") then
        local target = player:GetSelection()
        if target == nil then 
            player:Say("No selection :(", 0)
        else
            player:Say(target:GetHealth() .. "/" .. target:GetMaxHealth(), 0)
        end
    end
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_CHAT, OnChat)