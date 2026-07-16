sprite_index = item.icon;
name_key = item.name_key;

dstnc = distance_to_object(obj_player)
if dstnc < 2 && obj_player.can_move && (InputPressed(INPUT_VERB.ACCEPT)) 
{
	var _target_item = instance_nearest(obj_player.x, obj_player.y, obj_item_ingame);
	global.item_found = _target_item.item;
	global.item_found_name = __(_target_item.name_key);
	startDialogue("item_found");
	image_index = 2;
	instance_destroy();
}

depth = -bbox_bottom;