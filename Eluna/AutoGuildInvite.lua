-- Automatically add players to a given guild on login

require("Constants")

local guildName = "TestGuild"
local addAtGuildRank = 4

local function OnLogin(event, player)
    local currentGuild = player:GetGuildName()
    if currentGuild then return end
    local accountName = player:GetAccountName()
    if not accountName then
        PrintError("No account name. Skipping guild invite.")
        return
    end
    if string.find(accountName,"rndbot") ~= nil then return end
    local guild = GetGuildByName(guildName)
    if not guild then
        PrintError("Unable to find guild " .. guildName)
        return
    end
    guild:AddMember(player, addAtGuildRank)
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_LOGIN, OnLogin)