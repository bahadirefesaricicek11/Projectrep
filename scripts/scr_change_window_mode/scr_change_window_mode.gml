function scr_change_window_mode(_val) {
    if (_val == 1) 
	{
        window_set_fullscreen(true);
    } 
    else {
        window_set_fullscreen(false);
        
        window_set_size(960	, 540);
        
        with (obj_menu) {
            alarm[0] = 1;
        }
    }
    
    var _w = global.view_width;
    var _h = global.view_height;
    surface_resize(application_surface, _w, _h);
    
    save_settings();
}