-- TODO: Share more code with GetInstanceCreatures.sql
-- These queries can take a long time to run.
DROP TABLE IF EXISTS world_maps;
CREATE TEMPORARY TABLE world_maps (map smallint(5));
INSERT INTO world_maps VALUES (0); -- EASTERN_KINGDOMS
INSERT INTO world_maps VALUES (1); -- KALIMDOR

-- Do not scale NPCs in these factions
DROP TABLE IF EXISTS blacklisted_factions;
CREATE TEMPORARY TABLE blacklisted_factions (id smallint(5));
INSERT INTO blacklisted_factions VALUES (35); -- Friendly
INSERT INTO blacklisted_factions VALUES (1514); -- Silverwing Sentinels (WSG A);
INSERT INTO blacklisted_factions VALUES (1515); -- Warsong Outriders (WSG H);
INSERT INTO blacklisted_factions VALUES (1577); -- The League of Arathor (AB A);
INSERT INTO blacklisted_factions VALUES (1599); -- The League of Arathor (AB A);
INSERT INTO blacklisted_factions VALUES (412); -- The Defilers (AB H);
INSERT INTO blacklisted_factions VALUES (1598); -- The Defilers (AB H);
INSERT INTO blacklisted_factions VALUES (1216); -- Stormpike Guard (AV A);
INSERT INTO blacklisted_factions VALUES (1334); -- Stormpike Guard (AV A);
INSERT INTO blacklisted_factions VALUES (1214); -- Frostwolf Clan (AV H);
INSERT INTO blacklisted_factions VALUES (1335); -- Frostwolf Clan (AV H);
INSERT INTO blacklisted_factions VALUES (1194); -- Battleground Neutral
INSERT INTO blacklisted_factions VALUES (11102); -- Argent Dawn
INSERT INTO blacklisted_factions VALUES (1625); -- Argent Dawn
INSERT INTO blacklisted_factions VALUES (794); -- Argent Dawn
INSERT INTO blacklisted_factions VALUES (994); -- Cenarion Circle
INSERT INTO blacklisted_factions VALUES (635); -- Cenarion Circle
INSERT INTO blacklisted_factions VALUES (1254); -- Cenarion Circle
INSERT INTO blacklisted_factions VALUES (1574); -- Zandalar Tribe
INSERT INTO blacklisted_factions VALUES (695); -- Hydraxian Waterlords
INSERT INTO blacklisted_factions VALUES (471); -- Ravenholdt
INSERT INTO blacklisted_factions VALUES (474); -- Gadgetzan
INSERT INTO blacklisted_factions VALUES (69); -- Ratchet
INSERT INTO blacklisted_factions VALUES (114); -- Treasure
INSERT INTO blacklisted_factions VALUES (1555); -- Darkmoon Faire
INSERT INTO blacklisted_factions VALUES (250); -- Escortee
INSERT INTO blacklisted_factions VALUES (495); -- Escortee

DROP TABLE IF EXISTS world_elite_creatures;
CREATE TABLE world_elite_creatures (id mediumint(8));

-- Handle locks that spawn enemies, ex: Zul'Farak temple event
-- Lock -> Item -> Spell -> Event -> Spawn Enemies
-- Note that mangos0 doesn't have a spell or lock table by default.
-- These would have to be exported from the DBC files.
INSERT INTO world_elite_creatures (id)
SELECT DISTINCT ds.datalong AS creatureId 
FROM gameobject_template AS gt
JOIN gameobject AS g
ON g.id = gt.entry
JOIN world_maps AS wm
ON g.map = wm.map
JOIN locks l
ON (gt.type = 0 -- Door/Cage
AND l.id = gt.data1)
JOIN item_template AS it
ON (l.Type_1 = 1 -- Opened by item
AND l.Index_1 = it.Entry)
OR (l.Type_2 = 1 
AND l.Index_2 = it.Entry)
OR (l.Type_3 = 1 
AND l.Index_3 = it.Entry)
OR (l.Type_4 = 1 
AND l.Index_4 = it.Entry)
OR (l.Type_5 = 1 
AND l.Index_5 = it.Entry)
OR (l.Type_6 = 1 
AND l.Index_6 = it.Entry)
OR (l.Type_7 = 1 
AND l.Index_7 = it.Entry)
OR (l.Type_8 = 1 
AND l.Index_8 = it.Entry)
JOIN spell AS s
ON it.spellid_1 = s.id
OR it.spellid_2 = s.id
OR it.spellid_3 = s.id
OR it.spellid_4 = s.id
OR it.spellid_5 = s.id
JOIN db_scripts AS ds
ON (s.Effect_1 = 61 -- Start Event
AND s.EffectMiscValue_1 = ds.id)
OR (s.Effect_2 = 61 -- Start Event
AND s.EffectMiscValue_2 = ds.id)
OR (s.Effect_3 = 61 -- Start Event
AND s.EffectMiscValue_3 = ds.id)
JOIN creature_template AS ct 
ON ds.datalong = ct.entry
LEFT JOIN blacklisted_factions AS bf
ON ct.FactionAlliance = bf.id
WHERE ds.command = 10 -- SCRIPT_COMMAND_TEMP_SUMMON_CREATURE
AND `rank` between 1 and 3
AND bf.id is null;

-- GameObjects that directly start events
INSERT INTO world_elite_creatures (id)
SELECT DISTINCT ds.datalong AS creatureId
FROM mangos0.gameobject_template AS gt
JOIN gameobject AS g
ON gt.entry = g.id
JOIN world_maps AS wm
ON g.map = wm.map
JOIN db_scripts ds
ON (gt.type = 3 -- Chest
AND gt.data6 = ds.id)
OR (gt.type = 10 -- Goober (Generic?)
AND gt.data2 = ds.id)
JOIN creature_template AS ct 
ON ds.datalong = ct.entry
LEFT JOIN blacklisted_factions AS bf
ON ct.FactionAlliance = bf.id
WHERE ds.command = 10 -- SCRIPT_COMMAND_TEMP_SUMMON_CREATURE
AND `rank` between 1 and 3
AND bf.id is null;

-- GameObjects that cast spells
INSERT INTO world_elite_creatures (id)
select distinct ct.entry as id
from gameobject_template gt
join gameobject go
on gt.entry = go.id
JOIN world_maps AS wm
ON go.map = wm.map
join spell s
on (gt.type = 6 -- Trap
and gt.data3 = s.id)
or (gt.type = 10 -- Goober (Generic?)
and gt.data10 = s.id)
or (gt.type = 18 -- Ritual
and gt.data1 = s.id)
or (gt.type = 22 -- Spellcaster
and gt.data0 = s.id)
join creature_template ct
on (s.Effect_1 in 
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
and s.EffectMiscValue_1 = ct.entry)
or (s.Effect_2 in
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
and s.EffectMiscValue_2 = ct.entry)
or (s.Effect_3 in
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
and s.EffectMiscValue_3 = ct.entry)
LEFT JOIN blacklisted_factions AS bf
ON ct.FactionAlliance = bf.id
WHERE `rank` between 1 and 3
AND bf.id is null;

-- Regular creatures (spawned on map create)
INSERT INTO world_elite_creatures (id)
SELECT DISTINCT c.id 
FROM creature AS c
JOIN world_maps AS wm
ON c.map = wm.map
JOIN creature_template AS ct
ON c.id = ct.entry
LEFT JOIN blacklisted_factions AS bf
ON ct.FactionAlliance = bf.id
WHERE `rank` between 1 and 3
AND bf.id is null;

-- Get any creatures spawned by other world elite creatures
-- TODO: Could make this a more complicated join instead of union.
-- Not sure which is better tbh.
INSERT INTO world_elite_creatures (id)
SELECT DISTINCT action1_param1 AS id
FROM world_elite_creatures wec
JOIN creature_ai_scripts cai
ON wec.id = cai.creature_id
WHERE action1_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
) 
UNION
SELECT DISTINCT action2_param1 AS id
FROM world_elite_creatures wec
JOIN creature_ai_scripts cai
ON wec.id = cai.creature_id
WHERE action2_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
) 
UNION
SELECT DISTINCT action3_param1 AS id
FROM world_elite_creatures wec
JOIN creature_ai_scripts cai
ON wec.id = cai.creature_id
WHERE action3_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
);

-- Creatures summoned by spells cast by other world elite creatures
INSERT INTO world_elite_creatures (id)
SELECT DISTINCT ct.entry
FROM world_elite_creatures AS wec
JOIN creature_ai_scripts AS cai
ON wec.id = cai.creature_id
JOIN spell AS s
ON (cai.action1_type = 11
AND cai.action1_param1 = s.id)
OR (cai.action2_type = 11
AND cai.action2_param1 = s.id)
OR (cai.action3_type = 11
AND cai.action3_param1 = s.id)
JOIN creature_template AS ct
ON (s.Effect_1 IN 
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
AND s.EffectMiscValue_1 = ct.entry)
OR (s.Effect_2 IN
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
AND s.EffectMiscValue_2 = ct.entry)
OR (s.Effect_3 IN
        (
            28, -- Summon
            41, -- Summon Wild
            42, -- Summon Guardian
            56, -- Summon Pet
            74, -- Summon Totem
            87, -- Summon Totem (Slot 1)
            88, -- Summon Totem (Slot 2)
            89, -- Summon Totem (Slot 3)
            90, -- Summon Totem (Slot 4)
            112 -- Summon Demon
        )
AND s.EffectMiscValue_3 = ct.entry);

SELECT DISTINCT id FROM world_elite_creatures ORDER BY id ASC;