function Item_Trigger(event, player, item)
    player:Teleport(1, 16226.2, 16257, 13.3, 1)
    player:RemoveItem(69201, 1)
  end
  
  RegisterItemEvent(69201, 2, Item_Trigger)