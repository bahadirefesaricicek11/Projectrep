if (keyboard_check_pressed(vk_f11) || keyboard_check_pressed(vk_f4)) and window_get_fullscreen() { 
		window_set_fullscreen(false) 
} else if (keyboard_check_pressed(vk_f11) || keyboard_check_pressed(vk_f4)) { 
		window_set_fullscreen(true) 
}


if room == rm_init
{
	obj_player.can_move = false;
}



if(instance_exists(obj_menu))
{
	obj_player.can_move = false;
}

if room == rm_side_screen 
{
	obj_player.can_move = false;
	if (! audio_is_playing(menutheme)) {
		audio_play_sound(menutheme, 1, false);
	}
} else
{
	audio_stop_all();
}


