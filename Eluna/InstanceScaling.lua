require("Constants")
require("Scaling")

-- TODO: Confirm these esp. BRD/Strat/Scholo
local instanceExpectedPlayerCountTable = {
    [RaidMaps.ONYXIAS_LAIR] = 40,
    [RaidMaps.NAXXRAMAS] = 40,
    [RaidMaps.AHNQIRAJ_TEMPLE] = 40,
    [RaidMaps.BLACKWING_LAIR] = 40,
    [RaidMaps.MOLTEN_CORE] = 40,
    [RaidMaps.ZULGURUB] = 20,
    [RaidMaps.RUINS_OF_AHNQIRAJ] = 20,
    [DungeonMaps.BLACKROCK_SPIRE] = 10,
    [DungeonMaps.STRATHOLME] = 5,
    [DungeonMaps.SCHOLOMANCE] = 5,
    [DungeonMaps.BLACKROCK_DEPTHS] = 5,
    [DungeonMaps.SHADOWFANG_KEEP] = 5, 
    [DungeonMaps.RAGEFIRE_CHASM] = 5,
    [DungeonMaps.MARAUDON] = 5,
    [DungeonMaps.SCARLET_MONASTERY] = 5,
    [DungeonMaps.RAZORFEN_DOWNS] = 5,
    [DungeonMaps.SUNKEN_TEMPLE] = 5,
    [DungeonMaps.GNOMEREGAN] = 5,
    [DungeonMaps.ULDAMAN] = 5,
    [DungeonMaps.BLACKFATHOM_DEEPS] = 5,
    [DungeonMaps.RAZORFEN_KRAUL] = 5,
    [DungeonMaps.WAILING_CAVERNS] = 5,
    [DungeonMaps.DEADMINES] = 5,
    [DungeonMaps.STORMWIND_STOCKADE] = 5,
    [DungeonMaps.SHADOWFANG_KEEP] = 5,
    [DungeonMaps.DIRE_MAUL] = 5,
    [DungeonMaps.ZULFARRAK] = 5,
}

local function OnAdd(event, creature)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    if instanceExpectedPlayerCountTable[mapId] then
        local creatures = map:GetData("Creatures") or {}
        -- Using creatures table as a set. True value just means it exists (not nil)
        creatures[creature:GetGUID()] = true
        map:SetData("Creatures", creatures)
        local playerCount = map:GetPlayerCount() or 0
        AdjustCreature(creature, instanceExpectedPlayerCountTable[mapId], playerCount)
    end
end

local function OnPlayerEnterLeave(event, map, player)
    local mapId = map:GetMapId()
    if instanceExpectedPlayerCountTable[mapId] then
        local playerCount = map:GetPlayerCount() or 0
        AdjustMap(map, instanceExpectedPlayerCountTable[mapId], playerCount)
    end
end

local function OnEnterCombat(event, creature, target)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    if instanceExpectedPlayerCountTable[mapId] then
        PrintDebug("Creature entered combat! " .. creature:GetName())
        local playerCount = map:GetPlayerCount() or 0
        AdjustCreature(creature, instanceExpectedPlayerCountTable[mapId], playerCount)
    end
end

local instances
local first = true
for mapId, _ in pairs(instanceExpectedPlayerCountTable) do
    if first then 
        instances = mapId
        first = false
    else
        instances = mapId .. ", " .. instances
    end
end

local query = "SELECT DISTINCT id FROM creature WHERE map IN (" .. instances .. ")"
PrintDebug("Instance creature query: " .. query)
local Q = WorldDBQuery(query)
if Q then
    repeat
        local id = Q:GetUInt32(0)
        RegisterCreatureEvent(id, CreatureEvents.CREATURE_EVENT_ON_ADD, OnAdd);
        RegisterCreatureEvent(id, CreatureEvents.CREATURE_EVENT_ON_ENTER_COMBAT, OnEnterCombat);
        PrintDebug("Registered creature ID " .. id)
    until not Q:NextRow()
else
    PrintDebug("No creatures :(")
end

RegisterServerEvent(ServerEvents.MAP_EVENT_ON_PLAYER_ENTER, OnPlayerEnterLeave)
RegisterServerEvent(ServerEvents.MAP_EVENT_ON_PLAYER_LEAVE, OnPlayerEnterLeave)