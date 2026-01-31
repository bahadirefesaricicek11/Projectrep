if (keyboard_check_pressed(vk_f11) || keyboard_check_pressed(vk_f4)) and window_get_fullscreen() { 
		window_set_fullscreen(false) 
} else if (keyboard_check_pressed(vk_f11) || keyboard_check_pressed(vk_f4)) { 
		window_set_fullscreen(true) 
}

if room == rm_init  or room == rm_splash
{
	obj_player.can_move = false;
}

if room == rm_menuRoom
{
	draw_sprite_tiled(spr_warp_transition, 0, 0, 0);
	obj_player.can_move = false;
	if (! audio_is_playing(msc_menu)) {
		audio_play_sound(msc_menu, 1, false);
	}
} else
{
	audio_stop_all();
}


