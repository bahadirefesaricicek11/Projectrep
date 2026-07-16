/// @desc Updates the gamepad button prompt style from the options menu and persists the choice
/// @arg {real} val The new style index (0 = Xbox Col. BG, 1 = Xbox Col. Text, 2 = Xbox Standard, 3 = PS Colored, 4 = PS Standard)
function scr_change_prompt_gp_style(_val) {
    global.prompt_gamepad_style = _val;
    save_settings(); 
}

/// @desc Updates the preferred keyboard movement prompts (WASD vs Arrows)
/// @arg {real} val
function scr_change_prompt_kbd_move(_val) { 
    global.prompt_kbd_movement = _val; 
    save_settings(); 
}

/// @desc Updates the preferred keyboard action prompts (ZXC vs Space/Shift/Ctrl)
/// @arg {real} val
function scr_change_prompt_kbd_act(_val) { 
    global.prompt_kbd_action = _val; 
    save_settings(); 
}

/// @desc Toggles the global button hint overlay visibility and rebuilds menu pages if needed
/// @arg {real} val (0 for hidden, 1 for visible)
function scr_change_button_hints(_val) {
    global.show_button_hints = _val;
    save_settings(); 
    
    // Safely update the graphics menu dimensions if we're altering elements in real-time
    if (instance_exists(obj_menu)) {
        with (obj_menu) {
            rebuild_graphics_menu();
            var _grid_h = ds_grid_height(ds_menu_graphics);
            // Clamp menu cursor position within bounds of the newly resized grid
            if (menu_option[page] >= _grid_h) {
                menu_option[page] = _grid_h - 1;
            }
        }
    }
}