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
