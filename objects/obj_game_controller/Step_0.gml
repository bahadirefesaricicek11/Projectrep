if InputPressed(INPUT_VERB.FULLSCREEN) {
    // If it's currently fullscreen (true / 1), pass 0 to turn it off.
    // If it's currently windowed (false / 0), pass 1 to turn it on.
    var _target_mode = window_get_fullscreen() ? 0 : 1;
    
    scr_change_window_mode(_target_mode);
}




if (global.state == GAME_STATE.CARD_SELECTION) {
	
}
else if (global.state == GAME_STATE.BATTLE) {
	play_music(msc_battle_theme);
}