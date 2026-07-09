dstnc = distance_to_object(obj_player)
if dstnc < 2 && obj_player.can_move && (InputPressed(INPUT_VERB.ACCEPT)) 
{
	startDialogue("gold");
	image_index = 2;
	if (amount != 0)
	{
		instance_destroy();
	}
}

depth = -bbox_bottom;