function scr_change_language(value_index) {
    global.setting_language = value_index;
    
    switch(value_index) {
        case 0:
            load_locale("en");
            break;
        case 1:
            load_locale("tr");
            break;
    }
	
     save_settings();
}