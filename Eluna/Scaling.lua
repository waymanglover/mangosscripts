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
    local newMaxHealth = math.max(math.ceil(origMaxHealth * (playerCount / expectedPlayerCount)), 100)
    if (newMaxHealth ~= creature:GetMaxHealth()) then 
        creature:SetMaxHealth(newMaxHealth) 
        PrintDebug("Adjusted " .. creature:GetName() .. " from " ..  origMaxHealth .. " to " .. newMaxHealth)
    end
end

local function AdjustDamage(creature, expectedPlayerCount, playerCount)
    -- Apply a stack of the buff/debuff for each perMissingApplyStack players 
    -- we are below the expected player count.
    -- Ex: Instance expects 10 players, but there's 5 players in the instance
    --     If perMissingApplyStack = 2 -> (10 - 5) / 2 = 2.5, round down to 2
    local perMissingApplyStack = 2

    local buff = 28419 -- 20% damage increase and increased size (hope this doesn't break things!)
    local debuff = 17650 -- 20% damage decrease
    local map = creature:GetMap()
    local mapId = map:GetMapId()
    local stacksToApply = math.floor(math.abs((expectedPlayerCount - playerCount) / perMissingApplyStack))
    if stacksToApply <= 0 then
        PrintDebug("Removing/skipping scaling. stacksToApply: " .. stacksToApply)
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
function AdjustCreature(creature, expectedPlayerCount, playerCount)
    AdjustHealth(creature, expectedPlayerCount, playerCount)
    AdjustDamage(creature, expectedPlayerCount, playerCount)
end

function AdjustMap(map, expectedPlayerCount, playerCount)
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
            AdjustCreature(creature, expectedPlayerCount, playerCount)
        end
    end
end