-- Modify an item to teleport the user to GM Island

require("Constants")

local itemId = 69201

function OnUse(event, player, item)
  player:Teleport(1, 16226.2, 16257, 13.3, 1)
  player:RemoveItem(itemId, 1)
end

RegisterItemEvent(itemId, ItemEvents.ITEM_EVENT_ON_USE, OnUse)