-- Allow characters of either faction to quest/play with whatever faction they want.
-- Set NPCs assigned to a player faction to be friendly to both factions
update mangos0.creature_template
set FactionHorde = 35, FactionAlliance = 35 -- Friendly
where FactionHorde in ( 
                        11, -- Stormwind 
                        1575, -- Stormwind 
                        12, -- Stormwind 
                        123, -- Stormwind 
                        1078, -- Stormwind 
                        23, -- Gnomeregan Exiles 
                        64, -- Gnomeregan Exiles 
                        875, -- Gnomeregan Exiles 
                        1594, -- Darnassus 
                        1600, -- Darnassus 
                        79, -- Darnassus 
                        80, -- Darnassus 
                        124, -- Darnassus 
                        1076, -- Darnassus 
                        1097, -- Darnassus 
                        55, -- Ironforge 
                        1611, -- Ironforge 
                        57, -- Ironforge 
                        1618, -- Ironforge 
                        122, -- Ironforge 
                        894, -- Theramore
                        1096, -- Theramore
                        694, -- Wildhammer Clan
                        1054, -- Wildhammer Clan
                        1055, -- Wildhammer Clan
                        96, -- Southshore Mayor
                        84, -- Alliance Generic
                        1154, -- Undercity 
                        68, -- Undercity 
                        71, -- Undercity 
                        98, -- Undercity 
                        118, -- Undercity 
                        1134, -- Undercity 
                        104, -- Thunder Bluff 
                        105, -- Thunder Bluff 
                        995, -- Thunder Bluff 
                        126, -- Darkspear Trolls 
                        876, -- Darkspear Trolls 
                        877, -- Darkspear Trolls 
                        1174, -- Orgrimmar 
                        1595, -- Orgrimmar 
                        29, -- Orgrimmar 
                        1612, -- Orgrimmar 
                        65, -- Orgrimmar 
                        1619, -- Orgrimmar 
                        85, -- Orgrimmar 
                        125, -- Orgrimmar 
                        1074, -- Orgrimmar
                        83 -- Horde Generic
                      )
or FactionAlliance in ( 
                        11, -- Stormwind 
                        1575, -- Stormwind 
                        12, -- Stormwind 
                        123, -- Stormwind 
                        1078, -- Stormwind 
                        23, -- Gnomeregan Exiles 
                        64, -- Gnomeregan Exiles 
                        875, -- Gnomeregan Exiles 
                        1594, -- Darnassus 
                        1600, -- Darnassus 
                        79, -- Darnassus 
                        80, -- Darnassus 
                        124, -- Darnassus 
                        1076, -- Darnassus 
                        1097, -- Darnassus 
                        55, -- Ironforge 
                        1611, -- Ironforge 
                        57, -- Ironforge 
                        1618, -- Ironforge 
                        122, -- Ironforge 
                        894, -- Theramore
                        1096, -- Theramore
                        694, -- Wildhammer Clan
                        1054, -- Wildhammer Clan
                        1055, -- Wildhammer Clan
                        96, -- Southshore Mayor
                        84, -- Alliance Generic
                        1154, -- Undercity 
                        68, -- Undercity 
                        71, -- Undercity 
                        98, -- Undercity 
                        118, -- Undercity 
                        1134, -- Undercity 
                        104, -- Thunder Bluff 
                        105, -- Thunder Bluff 
                        995, -- Thunder Bluff 
                        126, -- Darkspear Trolls 
                        876, -- Darkspear Trolls 
                        877, -- Darkspear Trolls 
                        1174, -- Orgrimmar 
                        1595, -- Orgrimmar 
                        29, -- Orgrimmar 
                        1612, -- Orgrimmar 
                        65, -- Orgrimmar 
                        1619, -- Orgrimmar 
                        85, -- Orgrimmar 
                        125, -- Orgrimmar 
                        1074, -- Orgrimmar
                        83 -- Horde Generic
                      )
or Entry in (
    13842 -- Frostwolf Ambassador (AV)
);
                      
-- Set the faction NPC's that have to be killed for quests to be hostile
update mangos0.creature_template 
set FactionAlliance = 14, FactionHorde = 14
where Entry in (
                3128, 
                3129,
                12856,
                12676, -- Sharptalon
                12677, -- Shadumbra
                12678, -- Ursangous
                )
or FactionAlliance in (
    88 -- Hillsbrad Militia
);

-- Let players complete quests from either faction
update mangos0.quest_template
set RequiredRaces = 0
where RequiredRaces in (
                        77, -- Alliance
                        178 -- Horde
                       );
                       
-- Let players use graveyards from either faction
update mangos0.game_graveyard_zone set faction = 0;

-- Let players use objects (mailboxes, wanted posters, etc.) from either faction
update mangos0.gameobject_template
set faction = 31 -- Friendly
where faction in 
(
	84, -- Alliance Generic
	210, -- Alliance Generic
	534, -- Alliance Generic
	1315, -- Alliance Generic
	126, -- Darkspear Trolls
	876, -- Darkspear Trolls
	877, -- Darkspear Trolls
	79, -- Darnassus
	80, -- Darnassus
	124, -- Darnassus
	1076, -- Darnassus
	1097, -- Darnassus
	1594, -- Darnassus
	1600, -- Darnassus
	23, -- Gnomeregan Exiles
	64, -- Gnomeregan Exiles
	875, -- Gnomeregan Exiles
	83, -- Horde Generic
	106, -- Horde Generic
	714, -- Horde Generic
	1034, -- Horde Generic
	1314, -- Horde Generic
	55, -- Ironforge
	57, -- Ironforge
	122, -- Ironforge
	1611, -- Ironforge
	1618, -- Ironforge
	29, -- Orgrimmar
	65, -- Orgrimmar
	85, -- Orgrimmar
	125, -- Orgrimmar
	1074, -- Orgrimmar
	1174, -- Orgrimmar
	1595, -- Orgrimmar
	1612, -- Orgrimmar
	1619, -- Orgrimmar
	11, -- Stormwind
	12, -- Stormwind
	123, -- Stormwind
	1078, -- Stormwind
	1575, -- Stormwind
	149, -- Theramore
	150, -- Theramore
	151, -- Theramore
	894, -- Theramore
	1075, -- Theramore
	1077, -- Theramore
	1096, -- Theramore
	104, -- Thunder Bluff
	105, -- Thunder Bluff
	995, -- Thunder Bluff
	68, -- Undercity
	71, -- Undercity
	98, -- Undercity
	118, -- Undercity
	1134, -- Undercity
	1154, -- Undercity
	694, -- Wildhammer Clan
	1054, -- Wildhammer Clan
	1055 -- Wildhammer Clan
);