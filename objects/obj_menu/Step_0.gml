// =================================================================
// 1. IN-GAME EXIT PROMPT (Special Overlay)
// =================================================================
if (is_ingame && prompt_exit) {
    // Scroll background
    bg_scroll_x += 1;
    bg_scroll_y += 1; 
    
    if (bg_scroll_x >= 56) bg_scroll_x = 0;
    if (bg_scroll_y >= 72) bg_scroll_y = 0;
    
    var input_up_p    = InputPressed(INPUT_VERB.UP);
    var input_down_p  = InputPressed(INPUT_VERB.DOWN);
    var input_enter_p = InputPressed(INPUT_VERB.ACCEPT);
    var input_back_p  = InputPressed(INPUT_VERB.CANCEL) || InputPressed(INPUT_VERB.PAUSE);
    
    var prompt_nav = input_down_p - input_up_p;
    if (prompt_nav != 0) {
        audio_play_sound(snd_menu_move, 0, false);
        prompt_option = (prompt_option + prompt_nav + 3) % 3;
    }
    
    if (input_back_p) prompt_exit = false;
    
    if (input_enter_p) {
        switch (prompt_option) {
            case 0: // Save and Quit
                save_game(); 
                global.state = GAME_STATE.TITLE_SCREEN;
                room_goto(rm_menuRoom); 
                break;
                
            case 1: // Quit Without Saving
                global.state = GAME_STATE.TITLE_SCREEN;
                room_goto(rm_menuRoom);
                break;
                
            case 2: // Cancel
                prompt_exit = false;
                break;
        }
    }
    exit; // Prevent main menu processing while exit prompt is up
}

// =================================================================
// 2. CORE MENU NAVIGATION SETUP
// =================================================================
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

if (menu_option[page] != previous_menu_option) {
    xo = 0;
}
previous_menu_option = menu_option[page];
xo = lerp(xo, -15, lerpAmt);

// Gather Inputs
var input_up_p    = InputPressed(INPUT_VERB.UP);
var input_down_p  = InputPressed(INPUT_VERB.DOWN);
var input_right_p = InputPressed(INPUT_VERB.RIGHT);
var input_left_p  = InputPressed(INPUT_VERB.LEFT);
var input_right_c = InputCheck(INPUT_VERB.RIGHT);
var input_left_c  = InputCheck(INPUT_VERB.LEFT);
var input_enter_p = InputPressed(INPUT_VERB.ACCEPT);
var input_back_p  = InputPressed(INPUT_VERB.CANCEL) || InputPressed(INPUT_VERB.PAUSE);

// Play selection tick sound
if ((input_down_p || input_up_p) && !inputting) {
    audio_play_sound(snd_menu_move, 0, false);
}

// =================================================================
// 3. EDITING VALUE MODE (Sliders, Shifters, Toggles)
// =================================================================
if (inputting) {
    var _type = ds_grid[# 1, menu_option[page]];
    var _current_val = ds_grid[# 3, menu_option[page]];
    var _target_script = ds_grid[# 2, menu_option[page]];

    switch (_type) {
        case menu_element_type.shift:
            var hinput = input_right_p - input_left_p;
            if (hinput != 0) {
                var _options_array = ds_grid[# 4, menu_option[page]];
                // Safely clamp within the bounds of the options array
                var _new_val = clamp(_current_val + hinput, 0, array_length(_options_array) - 1);
                ds_grid[# 3, menu_option[page]] = _new_val;
                
                // Fire configuration change callback instantly
                if (script_exists(_target_script) || is_method(_target_script)) {
                    if (is_method(_target_script)) _target_script(_new_val);
                    else script_execute(_target_script, _new_val);
                }
                audio_play_sound(snd_menu_move, 0, false);
            }
            break;
            
        case menu_element_type.slider:
            var hinput = input_right_c - input_left_c;
            if (hinput != 0) {
                var _new_val = clamp(_current_val + (hinput * 0.01), 0, 1);
                ds_grid[# 3, menu_option[page]] = _new_val;
                
                if (script_exists(_target_script) || is_method(_target_script)) {
                    if (is_method(_target_script)) _target_script(_new_val);
                    else script_execute(_target_script, _new_val);
                }
            }
            break;
            
        case menu_element_type.toggle:
            var hinput = input_right_p - input_left_p;
            if (hinput != 0) {
                // Keep toggle clean and simple: binary flip
                var _new_val = 1 - _current_val;
                ds_grid[# 3, menu_option[page]] = _new_val;
                
                if (script_exists(_target_script) || is_method(_target_script)) {
                    if (is_method(_target_script)) _target_script(_new_val);
                    else script_execute(_target_script, _new_val);
                }
                audio_play_sound(snd_menu_move, 0, false);
            }
            break;
    }
    
    // Pressing Back or Enter exits value editing mode safely
    if (input_back_p || input_enter_p) {
        inputting = false;
        audio_play_sound(snd_menu_move, 0, false);
        
        io_clear();
        keyboard_clear(vk_enter);
    }
}

// =================================================================
// 4. MAIN NAVIGATIONAL MODE
// =================================================================
else {
    var nav_input = input_down_p - input_up_p;
    if (nav_input != 0) {
        menu_option[page] = (menu_option[page] + nav_input + ds_height) % ds_height;
    }

    // Select Option
    if (input_enter_p) {
        switch (ds_grid[# 1, menu_option[page]]) {
            case menu_element_type.script_runner:
                script_execute(ds_grid[# 2, menu_option[page]]);
                break;
            case menu_element_type.page_transfer:
                page = ds_grid[# 2, menu_option[page]]; 
                break;
            case menu_element_type.shift:
            case menu_element_type.slider:
            case menu_element_type.toggle:
                inputting = true;
                break;
        }
    }
    
    // Cancel/Go Back Check
    if (input_back_p) {
        var _parent = menu_parent[page];
        
        if (_parent != -1) {
            // Safe: We are deep in settings/submenus. Go back up one level.
            audio_play_sound(snd_menu_move, 0, false);
            page = _parent; 
        } 
        else {
            // We are at the root level! State Machine handles context here:
            if (is_ingame) {
                // --- IN-GAME BEHAVIOR ---
                global.state = GAME_STATE.PLAYING;
                
                // Keep input cooldown active so player doesn't instantly re-pause
                if (instance_exists(obj_player)) {
                    obj_player.menu_cooldown = true;
                }
                
                instance_destroy();
            } 
            else {
                // --- TITLE SCREEN BEHAVIOR ---
                // If they press escape/back at the root of the title screen menu,
                // we safely do nothing (or you can trigger an exit-game prompt!)
                global.state = GAME_STATE.TITLE_SCREEN;
            }
        }
    }
}

// =================================================================
// 5. VISUAL TRANSITIONS
// =================================================================
if (fade_active) {
    fade_alpha -= fade_speed;
    if (fade_alpha <= 0) {
        fade_alpha = 0;
        fade_active = false;
    }
}