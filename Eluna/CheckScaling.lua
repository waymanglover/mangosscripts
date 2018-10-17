-- Add a chat command for checking whether the target creature is scaled,
-- and by how much.

require("Constants")

local function OnChat(event, player, msg, Type, lang)
    if (msg == "_scaling") then
        local scaled = false
        local target = player:GetSelection()
        if not target then
            player:Say("No target", 0)
            return
        end
        local currentMaxHealth = target:GetMaxHealth()
        local origMaxHealth = target:GetData("OrigMaxHealth") or currentMaxHealth
        if origMaxHealth ~= currentMaxHealth then
            player:Say("Target health scaled from " .. origMaxHealth .. " to " .. currentMaxHealth, 0)
            scaled = true
        end            

        local debuff = 17650
        local buff = 28419

        local auraBuff = target:GetAura(buff)
        local auraDebuff = target:GetAura(debuff)
        if auraBuff ~= nil then
            player:Say("Target Buff Stacks (+20% damage): " .. auraBuff:GetStackAmount(), 0)
            scaled = true
        elseif auraDebuff ~= nil then
            player:Say("Target Debuff Stacks (-20% damage): " .. auraDebuff:GetStackAmount(), 0)
            scaled = true
        end
        if not scaled then
            player:Say("Target is not scaled", 0)
        end
    end
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_CHAT, OnChat)