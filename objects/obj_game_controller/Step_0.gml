if room == rm_init  or room == rm_splash
{
	obj_player.can_move = false;
}

if room == rm_menuRoom or room == rm_nameScreen
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


