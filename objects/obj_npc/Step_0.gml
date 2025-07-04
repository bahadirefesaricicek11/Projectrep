if place_meeting(x,y,obj_player) and obj_player.can_move && (keyboard_check_pressed(vk_enter) or keyboard_check_pressed(ord("Z")) or gamepad_button_check_pressed(0, gp_face1)) {
	
	create_textbox(text_id);
	obj_player.image_speed = 0;
}

depth = -bbox_bottom;