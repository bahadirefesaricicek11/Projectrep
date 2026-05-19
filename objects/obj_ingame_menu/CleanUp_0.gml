if (instance_exists(obj_player)) {
    obj_player.can_move = true;
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