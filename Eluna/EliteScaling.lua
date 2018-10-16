require("Constants")
require("Scaling")

-- Do not scale NPCs in these factions
local factionBlacklist = {
    [35] = true, -- Friendly
    [1514] = true, -- Silverwing Sentinels (WSG A)
    [1515] = true, -- Warsong Outriders (WSG H)
    [1577] = true, -- The League of Arathor (AB A)
    [1599] = true, 
    [412] = true, -- The Defilers (AB H)
    [1598] = true, 
    [1216] = true, -- Stormpike Guard (AV A)
    [1334] = true, 
    [1214] = true, -- Frostwolf Clan (AV H)
    [1335] = true, 
    [1194] = true, -- Battleground Neutral
    [11102] = true, -- Argent Dawn
    [1625] = true, 
    [794] = true, 
    [994] = true, -- Cenarion Circle
    [635] = true, 
    [1254] = true, 
    [1574] = true, -- Zandalar Tribe
    [695] = true, -- Hydraxian Waterlords
    [471] = true, -- Ravenholdt
    [474] = true, -- Gadgetzan
    [69] = true, -- Ratchet
    [114] = true, -- Treasure
    [1555] = true, -- Darkmoon Faire
    [250] = true, -- Escortee
    [495] = true, 
}

-- TODO: Change this up ex: for outdoor raid bosses
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

    PrintDebug(creature:GetName() .. " entered combat!")
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
    AdjustCreature(creature, expectedPlayerCount, playerCount, maximumHealthScaling)
end

local blacklistedFactions
local first = true
for factionId, _ in pairs(factionBlacklist) do
    if first then 
        blacklistedFactions = factionId
        first = false
    else
        blacklistedFactions = factionId .. ", " .. blacklistedFactions
    end
end

local query = "select distinct c.id from mangos0.creature as c " ..
              "join mangos0.creature_template as ct " ..
              "on c.Id = ct.Entry " ..
              "where `rank` between 1 and 3 " .. -- TODO: Add to constants
              "and map in (" .. WorldMaps.EASTERN_KINGDOMS .. "," .. WorldMaps.KALIMDOR .. ") " ..
              "and FactionAlliance not in (" .. blacklistedFactions .. ")"
PrintDebug("Elite creature query: " .. query)
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