if (is_ingame && prompt_exit) {
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
            case 0:
				save_game(); 
				global.state = GAME_STATE.TITLE_SCREEN;
				room_goto(rm_menuRoom); 
				break;
				
            case 1: 
				global.state = GAME_STATE.TITLE_SCREEN;
				room_goto(rm_menuRoom);
				break;
				
            case 2:
				prompt_exit = false;
				break;
        }
    }
    exit;
}

var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

if (menu_option[page] != previous_menu_option) {
    xo = 0;
}
previous_menu_option = menu_option[page];
xo = lerp(xo, -15, lerpAmt);

var input_up_p    = InputPressed(INPUT_VERB.UP);
var input_down_p  = InputPressed(INPUT_VERB.DOWN);
var input_right_p = InputPressed(INPUT_VERB.RIGHT);
var input_left_p  = InputPressed(INPUT_VERB.LEFT);
var input_right_c = InputCheck(INPUT_VERB.RIGHT);
var input_left_c  = InputCheck(INPUT_VERB.LEFT);
var input_enter_p = InputPressed(INPUT_VERB.ACCEPT);
var input_back_p  = InputPressed(INPUT_VERB.CANCEL) || InputPressed(INPUT_VERB.PAUSE);

if ((input_down_p || input_up_p) && !inputting) {
    audio_play_sound(snd_menu_move, 0, false);
}

if (inputting) {
    switch (ds_grid[# 1, menu_option[page]]) {
        case menu_element_type.shift:
            var hinput = input_right_p - input_left_p;
            if (hinput != 0) {
                ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]] + hinput, 0, array_length(ds_grid[# 4, menu_option[page]]) - 1);
            }
            break;
            
        case menu_element_type.slider:
            var hinput = input_right_c - input_left_c;
            if (hinput != 0) {
                ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]] + (hinput * 0.01), 0, 1);
                script_execute(ds_grid[# 2, menu_option[page]], ds_grid[# 3, menu_option[page]]);
            }
            break;
            
		case menu_element_type.toggle:
            var hinput = input_right_p - input_left_p;
            if (hinput != 0) {
                ds_grid[# 3, menu_option[page]] = 1 - ds_grid[# 3, menu_option[page]];
                audio_play_sound(snd_menu_move, 0, false);
            }
            
            if (input_enter_p) {
                var current_setting_val = ds_grid[# 3, menu_option[page]];
                var target_script = ds_grid[# 2, menu_option[page]]; // Reads the specific function pointer
                
                // Dynamically execute whatever script belongs to this row
                if (script_exists(target_script) || is_method(target_script)) {
                    script_execute(target_script, current_setting_val);
                }
                
                inputting = false;
                io_clear();
                keyboard_clear(vk_enter);
            }
            break;
    }
    
    if (input_back_p || input_enter_p) {
        inputting = false;
        audio_play_sound(snd_menu_move, 0, false);
    }
} 
else {
    var nav_input = input_down_p - input_up_p;
    if (nav_input != 0) {
        menu_option[page] = (menu_option[page] + nav_input + ds_height) % ds_height;
    }

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
    
    if (input_back_p) {
        var _parent = menu_parent[page];
        if (_parent != -1) {
            audio_play_sound(snd_menu_move, 0, false);
            page = _parent; 
        } else {
            if (is_ingame) {
                global.state = GAME_STATE.PLAYING;
                
                // Tell the player to ignore the pause button on this frame
                if (instance_exists(obj_player)) {
                    obj_player.menu_cooldown = true;
                }
                
                instance_destroy();
            }
        }
    }
}

if (fade_active) {
    fade_alpha -= fade_speed;
    if (fade_alpha <= 0) {
        fade_alpha = 0;
        fade_active = false;
    }
}