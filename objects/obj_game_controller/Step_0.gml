if InputPressed(INPUT_VERB.FULLSCREEN) {
    
    if (window_get_fullscreen() == true) { 
        
        window_set_fullscreen(false);
        
		window_set_size(960	, 540);
        
        alarm[0] = 1; 
    }
    else {
        window_set_fullscreen(true);
    }
}




if (global.state == GAME_STATE.CARD_SELECTION) {
	
}
else if (global.state == GAME_STATE.BATTLE) {
	play_music(msc_battle_theme);
}