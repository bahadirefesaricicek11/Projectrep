sprite_index = item.icon
dstnc = distance_to_object(obj_player)
if dstnc < 2 and obj_player.can_move && (InputPressed(INPUT_VERB.ACCEPT)) 
{
	item_add(item);
	instance_destroy();
}