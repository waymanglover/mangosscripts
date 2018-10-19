-- TODO: Share more code with GetWorldEliteCreatures.sql
-- These queries can take a long time to run.
DROP TABLE IF EXISTS dungeons;
CREATE TEMPORARY TABLE dungeons (map smallint(5));
INSERT INTO dungeons VALUES (389); -- RAGEFIRE_CHASM
INSERT INTO dungeons VALUES (349); -- MARAUDON
INSERT INTO dungeons VALUES (329); -- STRATHOLME
INSERT INTO dungeons VALUES (289); -- SCHOLOMANCE
INSERT INTO dungeons VALUES (230); -- BLACKROCK_DEPTHS
INSERT INTO dungeons VALUES (229); -- BLACKROCK_SPIRE
INSERT INTO dungeons VALUES (189); -- SCARLET_MONASTERY
INSERT INTO dungeons VALUES (129); -- RAZORFEN_DOWNS
INSERT INTO dungeons VALUES (109); -- SUNKEN_TEMPLE
INSERT INTO dungeons VALUES (90); -- GNOMEREGAN
INSERT INTO dungeons VALUES (70); -- ULDAMAN
INSERT INTO dungeons VALUES (48); -- BLACKFATHOM_DEEPS
INSERT INTO dungeons VALUES (47); -- RAZORFEN_KRAUL
INSERT INTO dungeons VALUES (43); -- WAILING_CAVERNS
INSERT INTO dungeons VALUES (36); -- DEADMINES
INSERT INTO dungeons VALUES (34); -- STORMWIND_STOCKADE
INSERT INTO dungeons VALUES (33); -- SHADOWFANG_KEEP
INSERT INTO dungeons VALUES (429); -- DIRE_MAUL
INSERT INTO dungeons VALUES (209); -- ZULFARRAK
INSERT INTO dungeons VALUES (309); -- ZULGURUB
INSERT INTO dungeons VALUES (249); -- ONYXIAS_LAIR
INSERT INTO dungeons VALUES (533); -- NAXXRAMAS
INSERT INTO dungeons VALUES (531); -- AHNQIRAJ_TEMPLE
INSERT INTO dungeons VALUES (509); -- RUINS_OF_AHNQIRAJ
INSERT INTO dungeons VALUES (469); -- BLACKWING_LAIR
INSERT INTO dungeons VALUES (409); -- MOLTEN_CORE

DROP TABLE IF EXISTS instance_creatures;
CREATE TABLE instance_creatures (id mediumint(8));

-- Handle locks that spawn enemies, ex: Zul'Farak temple event
-- Lock -> Item -> Spell -> Event -> Spawn Enemies
-- Note that mangos0 doesn't have a spell or lock table by default.
-- These would have to be exported from the DBC files.
INSERT INTO instance_creatures (id)
SELECT DISTINCT ds.datalong AS creatureId 
FROM gameobject_template AS gt
JOIN gameobject AS g
ON g.id = gt.entry
JOIN dungeons AS d
ON g.map = d.map
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
WHERE ds.command = 10; -- SCRIPT_COMMAND_TEMP_SUMMON_CREATURE

-- GameObjects that directly start events
INSERT INTO instance_creatures (id)
SELECT DISTINCT ds.datalong AS creatureId
FROM mangos0.gameobject_template AS gt
JOIN gameobject AS g
ON gt.entry = g.id
JOIN dungeons AS d
ON g.map = d.map
JOIN db_scripts ds
ON (gt.type = 3 -- Chest
AND gt.data6 = ds.id)
OR (gt.type = 10 -- Goober (Generic?)
AND gt.data2 = ds.id)
WHERE ds.command = 10; -- SCRIPT_COMMAND_TEMP_SUMMON_CREATURE

-- GameObjects that cast spells
INSERT INTO instance_creatures (id)
select distinct ct.entry as id
from gameobject_template gt
join gameobject go
on gt.entry = go.id
JOIN dungeons AS d
ON go.map = d.map
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
and s.EffectMiscValue_3 = ct.entry);

-- Regular creatures (spawned on map create)
INSERT INTO instance_creatures (id)
SELECT DISTINCT c.id 
FROM creature AS c
JOIN dungeons AS d
ON c.map = d.map;

-- Get any creatures spawned by other instance creatures
-- TODO: Could make this a more complicated join instead of union.
-- Not sure which is better tbh.
INSERT INTO instance_creatures (id)
SELECT DISTINCT action1_param1 AS id
FROM instance_creatures ic
JOIN creature_ai_scripts cai
ON ic.id = cai.creature_id
WHERE action1_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
) 
UNION
SELECT DISTINCT action2_param1 AS id
FROM instance_creatures ic
JOIN creature_ai_scripts cai
ON ic.id = cai.creature_id
WHERE action2_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
) 
UNION
SELECT DISTINCT action3_param1 AS id
FROM instance_creatures ic
JOIN creature_ai_scripts cai
ON ic.id = cai.creature_id
WHERE action3_type in 
(
    12, -- ACTION_T_SUMMON
    32, -- ACTION_T_SUMMON_ID
    49  -- ACTION_T_SUMMON_UNIQUE
);

-- Creatures summoned by spells cast by other instance creatures
INSERT INTO instance_creatures (id)
SELECT DISTINCT ct.entry
FROM instance_creatures AS ic
JOIN creature_ai_scripts AS cai
ON ic.id = cai.creature_id
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

SELECT DISTINCT id FROM instance_creatures ORDER BY id ASC;