-- Scale world elite creature damage/health based on party size

require("Constants")
require("Scaling")

-- Special handling for world boss scaling
local overrideExpectedPlayerCount = {
    [2723] = 40, -- Lord Kazzak
    [52349] = 40, -- Azuregos
    [50012] = 40, -- Emeriss
    [52350] = 40, -- Lethon
    [32343] = 40, -- Ysondre
    [4256] = 40, -- Taerar
}

local overrideMaximumHealthScaling = {
    [2723] = 5, -- Lord Kazzak
    [52349] = 5, -- Azuregos
    [50012] = 5, -- Emeriss
    [52350] = 5, -- Lethon
    [32343] = 5, -- Ysondre
    [4256] = 5, -- Taerar
}

local expectedPlayerCount = 5
-- We'll at most scale health down to this player count.
local maximumHealthScaling = 2

local function OnEnterCombat(event, creature, target)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    if mapId ~= WorldMaps.EASTERN_KINGDOMS and mapId ~= WorldMaps.KALIMDOR then
        return
    end

    -- If the target is a pet, get the pet's owner instead
    local owner = target:GetOwner()
    if owner then target = owner end

    -- If the unit's not a player...
    if target:GetTypeId() ~= 4 then -- TODO: Add to constants
        PrintDebug(creature:GetName() .. " entered combat but target is not a player")
        return
    end

    PrintDebug(creature:GetName() .. " entered combat with a player!")
    local playerCount = 0
    local group = target:GetGroup()
    if group then
        local members = group:GetMembers()
        if members then
            local creatureZone = creature:GetZoneId()
            for _, player in ipairs(members) do
                if player:GetZoneId() == creatureZone then 
                    playerCount = playerCount + 1 
                end
            end
        else 
            PrintDebug("Nil group when scaling " .. creature:GetName() .. " for " .. target:GetName())
            playerCount = 1
        end
    else
        playerCount = 1
    end
    PrintDebug("Player count based on " .. creature:GetName() .. " target's group: " .. playerCount)

    local creatureGuid = creature:GetGUIDLow()
    if overrideExpectedPlayerCount[creatureGuid] then
        AdjustCreature(creature, overrideExpectedPlayerCount[creatureGuid], playerCount, overrideMaximumHealthScaling[creatureGuid])
    else
        AdjustCreature(creature, expectedPlayerCount, playerCount, maximumHealthScaling)
    end
end

local query = "SELECT DISTINCT id FROM world_elite_creatures"
local Q = WorldDBQuery(query)
if Q then
    repeat
        local id = Q:GetUInt32(0)
        RegisterCreatureEvent(id, CreatureEvents.CREATURE_EVENT_ON_ENTER_COMBAT, OnEnterCombat);
        PrintDebug("Registered creature ID " .. id)
    until not Q:NextRow()
else
    PrintDebug("No creatures :(")
end