require("Constants")

-- TODO: Confirm these esp. BRD/Strat/Scholo
local instanceExpectedPlayersTable = {
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

function TableToString(table, indent)
    if not table then return "Nil" end
    if not indent then indent = 0 end
    local string = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(table) do
      string = string .. string.rep(" ", indent)
      if (type(k) == "number") then
        string = string .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        string = string  .. k ..  "= "  
      else 
        -- Assume guid / uint64
        string = string .. "[" .. GetGUIDLow(k) .. "] = "
      end
      if (type(v) == "number") then
        string = string .. v .. ",\r\n"
      elseif (type(v) == "string") then
        string = string .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        string = string .. TableToString(v, indent + 2) .. ",\r\n"
      else
        string = string .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    string = string .. string.rep(" ", indent-2) .. "}"
    return string
end

function DumpTable(table)
    PrintDebug(TableToString(table))
end

local function AdjustHealth(creature)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    local playerCount = map:GetPlayerCount() or 0
    local origMaxHealth = creature:GetData("OrigMaxHealth")
    if not origMaxHealth then
        origMaxHealth = creature:GetMaxHealth()
        creature:SetData("OrigMaxHealth", origMaxHealth)
    else        
        PrintDebug("Got OrigMaxHealth for " .. creature:GetName() .. " from creature data: " ..  origMaxHealth)
    end
    local newMaxHealth = math.max(math.ceil(origMaxHealth * (playerCount / instanceExpectedPlayersTable[mapId])), 100)
    if (newMaxHealth ~= creature:GetMaxHealth()) then 
        creature:SetMaxHealth(newMaxHealth) 
        PrintDebug("Adjusted " .. creature:GetName() .. " from " ..  origMaxHealth .. " to " .. newMaxHealth)
    end
end

local function AdjustDamage(creature)
    -- Apply a stack of the buff/debuff for each perMissingApplyStack players 
    -- we are below the expected player count.
    -- Ex: Instance expects 10 players, but there's 5 players in the instance
    --     If perMissingApplyStack = 2 -> (10 - 5) / 2 = 2.5, round down to 2
    local perMissingApplyStack = 2

    local buff = 28419 -- 20% damage increase and increased size (hope this doesn't break things!)
    local debuff = 17650 -- 20% damage decrease
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    local playerCount = map:GetPlayerCount() or 0
    local stacksToApply = math.floor(math.abs((instanceExpectedPlayersTable[mapId] - playerCount) / perMissingApplyStack))
    if stacksToApply <= 0 then
        PrintDebug("Removing/skipping scaling. stacksToApply: " .. stacksToApply)
        creature:RemoveAura(buff)
        creature:RemoveAura(debuff)
        return 
    end
    local auraToApply
    if playerCount <= instanceExpectedPlayersTable[mapId] then
        auraToApply = debuff
        creature:RemoveAura(buff)
    else
        auraToApply = buff
        creature:RemoveAura(debuff)
    end
    PrintDebug("Applying " .. stacksToApply .. " stacks of aura " .. auraToApply .. " to " .. creature:GetName())
    creature:AddAura(auraToApply, creature)
    local aura = creature:GetAura(auraToApply)
    if not aura then 
        PrintError("Failed to apply aura " .. auraToApply .. " for " .. creature:GetName() .. " GUID: " .. creature:GetGUIDLow())
        return
    end
    aura:SetDuration(-1) -- Forever
    if stacksToApply > 1 then aura:SetStackAmount(stacksToApply) end
end

-- This almost certainly won't handle everything right
-- ...but it should cover the vast majority.
local function AdjustCreature(creature)
    AdjustHealth(creature)
    AdjustDamage(creature)
end

local function AdjustMap(map)
    local mapId = map:GetMapId()
    local instanceId = map:GetInstanceId()
    local creatures = map:GetData("Creatures")
    if not creatures then 
        PrintDebug("No creatures set for map " .. mapId .. " instance " .. instanceId)
        return 
    end
    for guid,_ in pairs(creatures) do
        local creature = map:GetWorldObject(guid)
        if creature ~= nil then
            AdjustCreature(creature)
        end
    end
end

local function OnAdd(event, creature)
    local map = creature:GetMap()
    if instanceExpectedPlayersTable[map:GetMapId()] then
        local mapId = map:GetMapId()
        local instanceId = map:GetInstanceId()
        local creatures = map:GetData("Creatures") or {}
        -- Using creatures table as a set. True value just means it exists (not nil)
        creatures[creature:GetGUID()] = true
        map:SetData("Creatures", creatures)
        AdjustCreature(creature)
    end
end

local function OnPlayerEnterLeave(event, map, player)
    if instanceExpectedPlayersTable[map:GetMapId()] then
        AdjustMap(map)
    end
end

local dungeons
local first = true
for dungeonId, _ in pairs(instanceExpectedPlayersTable) do
    if first then 
        dungeons = dungeonId
        first = false
    else
        dungeons = dungeonId .. ", " .. dungeons
    end
end

local query = "SELECT DISTINCT id FROM creature WHERE map IN (" .. dungeons .. ")"
PrintDebug("Instance creature query: " .. query)
local Q = WorldDBQuery(query)
if Q then
    repeat
        local id = Q:GetUInt32(0)
        RegisterCreatureEvent(id, CreatureEvents.CREATURE_EVENT_ON_ADD, OnAdd);
        PrintDebug("Registered creature ID " .. id)
    until not Q:NextRow()
else
    PrintDebug("No creatures :(")
end

RegisterServerEvent(ServerEvents.MAP_EVENT_ON_PLAYER_ENTER, OnPlayerEnterLeave)
RegisterServerEvent(ServerEvents.MAP_EVENT_ON_PLAYER_LEAVE, OnPlayerEnterLeave)