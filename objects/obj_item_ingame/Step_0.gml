sprite_index = item.icon

var _accept = InputPressed(INPUT_VERB.ACCEPT);

dstnc = distance_to_object(obj_player);

if dstnc < 15 && obj_item_manager.inv_full == false && obj_player.can_move && _accept
{
	item_add(item);
	instance_destroy();
}

depth = -bbox_bottom;
