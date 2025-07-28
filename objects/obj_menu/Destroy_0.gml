// Full cleanup procedure
if (variable_instance_exists(id, "menu_pages")) {
    // Destroy all grid references
    for (var i = 0; i < array_length(menu_pages); i++) {
        if (ds_exists(menu_pages[i], ds_type_grid)) {
            ds_grid_destroy(menu_pages[i]);
        }
    }
    menu_pages = []; // Clear array
}

// Destroy individual grid variables
var grids_to_destroy = [
    ds_menu_main, ds_menu_settings, ds_menu_audio,
    ds_menu_graphics, ds_menu_controls, ds_menu_quit
];

for (var i = 0; i < array_length(grids_to_destroy); i++) {
    if (ds_exists(grids_to_destroy[i], ds_type_grid)) {
        ds_grid_destroy(grids_to_destroy[i]);
    }
}

// Clean up fonts
if (font_exists(title_font)) {
    font_delete(title_font);
}

// Force garbage collection (debug only)
garbage_collect();
show_debug_message("Menu cleanup complete. Memory: " + string(debug_get_memory_usage()));