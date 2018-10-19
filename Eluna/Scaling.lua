-- Shared code for scaling creature health/damage

-- Apply a stack of the buff/debuff depending on the percentage of players 
-- we are below the expected player count.
-- Ex: Instance expects 10 players, but there's 6 players in the instance
--     If perMissingApplyStack = 0.267 -> (1 - 6/10) / 0.267
--                                        (0.4) / 0.267 = 1.498 (rounded down to 2)
-- 0.267 means instances expecting 5 people would cap at 2 stacks, but
-- allows for an extra stack if a small group runs a 10/20/40-man dungeon/raid.
local perMissingApplyStack = 0.267
local buff = 28419 -- 20% damage increase and increased size (hope this doesn't break things!)
local debuff = 17650 -- 20% damage decrease

local function AdjustHealth(creature, expectedPlayerCount, playerCount)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    local origMaxHealth = creature:GetData("OrigMaxHealth")
    if not origMaxHealth then
        origMaxHealth = creature:GetMaxHealth()
        creature:SetData("OrigMaxHealth", origMaxHealth)
    else        
        PrintDebug("Got OrigMaxHealth for " .. creature:GetName() .. " from creature data: " ..  origMaxHealth)
    end
    local newMaxHealth = math.ceil(origMaxHealth * (playerCount / expectedPlayerCount))
    if (newMaxHealth ~= creature:GetMaxHealth()) then 
        creature:SetMaxHealth(newMaxHealth) 
        PrintDebug("Adjusted " .. creature:GetName() .. " from " ..  origMaxHealth .. " to " .. newMaxHealth)
    end
end

local function AdjustDamage(creature, expectedPlayerCount, playerCount)
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    local stacksToApply = math.floor(math.abs(1 - playerCount/expectedPlayerCount) / perMissingApplyStack)
    if stacksToApply <= 0 then
        PrintDebug("Removing/skipping scaling for " .. creature:GetName() .. ". stacksToApply: " .. stacksToApply)
        creature:RemoveAura(buff)
        creature:RemoveAura(debuff)
        return 
    end
    local auraToApply
    if playerCount <= expectedPlayerCount then
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
function AdjustCreature(creature, expectedPlayerCount, playerCount, maximumHealthScaling)
    local playerCountForHealthScaling = math.max(playerCount, maximumHealthScaling)
    if playerCount == expectedPlayerCount then return end
    AdjustDamage(creature, expectedPlayerCount, playerCount)
    if playerCountForHealthScaling == expectedPlayerCount then return end
    AdjustHealth(creature, expectedPlayerCount, math.max(playerCount, maximumHealthScaling))
end

function AdjustMap(map, expectedPlayerCount, playerCount, maximumHealthScaling)
    if playerCount == expectedPlayerCount then return end
    local mapId = map:GetMapId()
    local instanceId = map:GetInstanceId()
    local creatures = map:GetData("Creatures")
    if not creatures then 
        PrintDebug("No creatures set for map " .. mapId .. " instance " .. instanceId)
        return 
    end
    for guid,_ in pairs(creatures) do
        local creature = map:GetWorldObject(guid)
        if creature then
            AdjustCreature(creature, expectedPlayerCount, playerCount, maximumHealthScaling)
        end
    end
end