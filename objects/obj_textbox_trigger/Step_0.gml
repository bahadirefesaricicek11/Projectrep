if place_meeting(x,y,obj_player) and obj_player.can_move {
	startDialogue(text_id);
	obj_player.can_move = false;
	obj_player.image_speed = 0;
}