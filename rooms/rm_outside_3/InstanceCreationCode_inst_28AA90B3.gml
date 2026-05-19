if place_meeting(x,y,obj_player) and obj_player.can_move {
	layer_sequence_create("Instances",0,0 , seq_slime_boss);
	obj_player.can_move = false;
	obj_player.image_speed = 0;
}