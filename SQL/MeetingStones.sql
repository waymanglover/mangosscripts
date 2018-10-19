-- Modify meeting stones to work more like live (summon target to you)
update mangos0.gameobject_template
set type = 22,     -- Spellcaster
    data0 = 23598, -- Ritual of Summoning 
                   -- This is the Ritual of Summoning spell used by summoning stones,
                   -- for some reason it's already in the game but unused.
    data1 = 0,     -- Charges (0 = Unlimited)
    data2 = 0      -- Requires being in party with gameobject spawner
                   -- This is set to 1 for mage portals and lightwells,
                   -- think setting it to 1 might break summoning stones 
where type = 23;   -- Meeting Stone