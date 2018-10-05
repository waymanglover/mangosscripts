require("Constants")

local function OnLogin(event, player)
    local guild = GetGuildByName("TestGuild")
    local currentGuild = player:GetGuildName()
    local accountName = player:GetAccountName()
    local isBot = string.find(accountName,"rndbot") ~= nil
    if (currentGuild == nil and not isBot) then
        guild:AddMember(player, 4) -- Default lowest rank (higher value = lower rank)
    end
end

RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_LOGIN, OnLogin)