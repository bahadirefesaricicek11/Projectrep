// If this was the in-game pause menu, restore the playing state!
if (is_ingame) {
    global.state = GAME_STATE.PLAYING;
    
    if (instance_exists(obj_player)) {
        obj_player.can_move = true;
    }
}
// obj_menu - Destroy Event

// Only return to PLAYING if this was actually paused from gameplay!
if (is_pause_menu) {
    global.state = GAME_STATE.PLAYING;
} else {
    global.state = GAME_STATE.TITLE_SCREEN;
}

if (variable_instance_exists(id, "menu_pages")) {
    for (var i = 0; i < array_length(menu_pages); i++) {
        if (ds_exists(menu_pages[i], ds_type_grid)) {
            ds_grid_destroy(menu_pages[i]);
        }
    }
    menu_pages = []; 
}

if (font_exists(title_font)) {
    font_delete(title_font);
}

gc_collect();