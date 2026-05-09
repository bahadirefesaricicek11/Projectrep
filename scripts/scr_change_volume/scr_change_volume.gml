function scr_change_volume(_val) {
    var ds_grid = menu_pages[page];
    ds_grid[# 3, menu_option[page]] = _val;

    var type = menu_option[page]; 
    
    switch (type) {
        case 0: 
            audio_master_gain(_val);
            break;
        case 1: 
            audio_group_set_gain(audiogroup_sound, _val, 0); 
            break;
        case 2: 
            audio_group_set_gain(audiogroup_music, _val, 0); 
            break;
    }
    
    save_settings();
}