function scr_change_window_mode(_val) {
    // 1 = Fullscreen, 0 = Windowed
    if (_val == 1) {
        // SWITCH TO FULLSCREEN
        window_set_fullscreen(true);
    } 
    else {
        // SWITCH TO WINDOWED
        window_set_fullscreen(false);
        
        // Use your exact window size formulas from the F11 script
        window_set_size(1248, 768);
        
        // Trigger the centering alarm on your menu object (or whatever controller handles it)
        with (obj_menu) {
            alarm[0] = 1;
        }
        with (obj_ingame_menu) {
            alarm[0] = 1;
        }
    }
    
    // Maintain GUI scale consistency 
    var _w = global.view_width;
    var _h = global.view_height;
    surface_resize(application_surface, _w, _h);
    display_set_gui_size(_w, _h);
    
    // Save to configuration file
    save_settings();
}