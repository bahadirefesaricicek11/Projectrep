dstnc = distance_to_object(obj_player)

if dstnc < 2 and obj_player.can_move && (InputPressed(INPUT_VERB.ACCEPT)) 
{
	startDialogue("Save 1");
	obj_player.image_speed = 0;
}
