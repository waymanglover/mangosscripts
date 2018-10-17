-- Add an NPC for teleporting between starting zones
-- Based on DynamicTeleporter.lua (https://raw.githubusercontent.com/ElunaLuaEngine/Scripts/master/Custom/Dynamic%20teleporter.lua)
-- Must run StartingZoneTeleporterNpc.sql to add the NPC
require("Constants")

local UnitEntry = 69001

local T = {
	[1] = { "Horde Starting Zones", 2,
		{"Orc/Troll", 1, -618.518, -4251.67, 38.718, 0},
		{"Undead", 0, 1676.71, 1678.31, 121.67, 2.70526},
		{"Tauren", 1, -2917.58, -257.98, 52.9968, 0},
	},
	[2] = { "Alliance Starting Zones", 2,
		{"Human", 0, -8949.95, -132.493, 83.5312, 0},
		{"Dwarf/Gnome", 0, -6240.32, 331.033, 382.758, 6.17716},
		{"Night Elf", 1, 10311.3, 832.463, 1326.41, 5.69632},
	},
}

local function OnGossipHello(event, player, unit)
    -- Show main menu
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, unit)
end	

local function OnGossipSelect(event, player, unit, sender, intid, code)
    if (sender == 0) then
        -- return to main menu
        OnGossipHello(event, player, unit)
        return
    end

    if (intid == 0) then
        -- Show teleport menu
        for i, v in ipairs(T[sender]) do
            if (i > 2) then
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "Back", 0, 0)
        player:GossipSendMenu(1, unit)
        return
    else
        -- teleport
        local name, map, x, y, z, o = table.unpack(T[sender][intid])
        player:Teleport(map, x, y, z, o)
    end
    
    player:GossipComplete()
end

RegisterCreatureGossipEvent(UnitEntry, GossipEvents.GOSSIP_EVENT_ON_HELLO, OnGossipHello)
RegisterCreatureGossipEvent(UnitEntry, GossipEvents.GOSSIP_EVENT_ON_SELECT, OnGossipSelect)