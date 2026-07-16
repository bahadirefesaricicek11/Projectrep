function scr_change_window_mode(_val) {
    if (_val == 1) 
    {
        // 1. Force GameMaker to use borderless mode instead of exclusive mode
        window_enable_borderless_fullscreen(true);
        
        // 2. Go fullscreen safely
        window_set_fullscreen(true);
    } 
    // Inside your scr_change_window_mode function:
	else {
	    window_set_fullscreen(false);
	    window_set_size(960, 540);
    
	    // Safely trigger the centering alarm whether the menu exists or not
	    if (instance_exists(obj_menu)) {
	        obj_menu.alarm[0] = 1;
	    } else {
	        // Fallback: If the menu isn't around, have the controller center it
	        alarm[0] = 1; 
	    }
	}
    
    // 3. Dynamic surface sizing
    // For crisp pixel art, keep the application surface locked to your base game resolution
    // so GameMaker scales it automatically via the GUI/Backbuffer layer.
    var _w = global.view_width;
    var _h = global.view_height;
    surface_resize(application_surface, _w, _h);
    
    save_settings();
}