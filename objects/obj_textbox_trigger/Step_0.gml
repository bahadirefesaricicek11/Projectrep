if place_meeting(x,y,obj_player) and obj_player.can_move {
	
	create_textbox(text_id);
	obj_player.image_speed = 0;
	instance_destroy()
}