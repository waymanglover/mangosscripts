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
                        1074 -- Orgrimmar 
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
                        1074 -- Orgrimmar 
                      );
                      
-- Set the faction NPC's that have to be killed for quests to be hostile
update mangos0.creature_template 
set FactionAlliance = 14, FactionHorde = 14
where Entry in (
                3128, 
                3129,
                12856
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