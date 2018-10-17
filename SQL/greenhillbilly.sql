-- Add an NPC for selling Green Hills of Stranglethorn pages
INSERT INTO mangos0.creature_template (`Entry`, `Name`, `SubName`, `MinLevel`, `MaxLevel`, `ModelId1`, `ModelId2`, `ModelId3`, `ModelId4`, `FactionAlliance`, `FactionHorde`, `Scale`, `Family`, `CreatureType`, `InhabitType`, `RegenerateStats`, `RacialLeader`, `NpcFlags`, `UnitFlags`, `DynamicFlags`, `ExtraFlags`, `CreatureTypeFlags`, `SpeedWalk`, `SpeedRun`, `UnitClass`, `Rank`, `HealthMultiplier`, `PowerMultiplier`, `DamageMultiplier`, `DamageVariance`, `ArmorMultiplier`, `ExperienceMultiplier`, `MinLevelHealth`, `MaxLevelHealth`, `MinLevelMana`, `MaxLevelMana`, `MinMeleeDmg`, `MaxMeleeDmg`, `MinRangedDmg`, `MaxRangedDmg`, `Armor`, `MeleeAttackPower`, `RangedAttackPower`, `MeleeBaseAttackTime`, `RangedBaseAttackTime`, `DamageSchool`, `MinLootGold`, `MaxLootGold`, `LootId`, `PickpocketLootId`, `SkinningLootId`, `KillCredit1`, `KillCredit2`, `MechanicImmuneMask`, `SchoolImmuneMask`, `ResistanceHoly`, `ResistanceFire`, `ResistanceNature`, `ResistanceFrost`, `ResistanceShadow`, `ResistanceArcane`, `PetSpellDataId`, `MovementType`, `TrainerType`, `TrainerSpell`, `TrainerClass`, `TrainerRace`, `TrainerTemplateId`, `VendorTemplateId`, `GossipMenuId`, `EquipmentTemplateId`, `Civilian`, `AIName`) 
VALUES (69100,	'Green Hillbilly',	'Great Again',	30,	30,	3277,	0,	0,	0,	35,	35,	0,	0,	7,	3,	1,	0,	16388,	4608,	0,	2,	0,	1,	1.14286,	1,	0,	1.80031,	0,	1,	1,	1,	1,	1172,	1172,	0,	0,	30,	39,	37.3824,	51.4008,	975,	16,	100,	1500,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	8,	1,	'EventAI');

-- change price of green hills pages to 50s instead of 15s
UPDATE mangos0.item_template
SET BuyPrice = 5000
WHERE Entry in (
                2725,
                2728,
                2730,
                2732,
                2734,
                2735,
                2738,
                2740,
                2742,
                2744,
                2745,
                2748,
                2749,
                2750,
                2751
                );


INSERT INTO mangos0.npc_vendor (`entry`, `item`, `maxcount`, `incrtime`, `condition_id`) 
VALUES
(69100,	2725,	0,	0,	0),
(69100,	2728,	0,	0,	0),
(69100,	2730,	0,	0,	0),
(69100,	2732,	0,	0,	0),
(69100,	2734,	0,	0,	0),
(69100,	2735,	0,	0,	0),
(69100,	2738,	0,	0,	0),
(69100,	2740,	0,	0,	0),
(69100,	2742,	0,	0,	0),
(69100,	2744,	0,	0,	0),
(69100,	2745,	0,	0,	0),
(69100,	2748,	0,	0,	0),
(69100,	2749,	0,	0,	0),
(69100,	2750,	0,	0,	0),
(69100,	2751,	0,	0,	0);
