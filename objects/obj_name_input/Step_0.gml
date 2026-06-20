move_h = InputPressed(INPUT_VERB.RIGHT) - InputPressed(INPUT_VERB.LEFT); 
move_v = InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP); 
accept = InputPressed(INPUT_VERB.ACCEPT);
_delete = InputPressed(INPUT_VERB.DELETE);
back = InputPressed(INPUT_VERB.CANCEL); 


if (!prompt_exit) {
    if (move_h != 0 || move_v != 0) { 
        cursor_x += move_h; 
        cursor_y += move_v; 
         
        if (move_h || move_v || -move_v || -move_h) { 
            audio_play_sound(snd_menu_move, 0, false); 
        } 

        if (cursor_x < 0) cursor_x = grid_width - 1; 
        if (cursor_x >= grid_width) cursor_x = 0; 
        if (cursor_y < 0) cursor_y = grid_height - 1; 
        if (cursor_y >= grid_height) cursor_y = 0; 

        while (keys[cursor_y][cursor_x] == " ") { 
            if (move_h != 0) cursor_x = (cursor_x + move_h + grid_width) % grid_width; 
            else if (move_v != 0) cursor_y = (cursor_y + move_v + grid_height) % grid_height; 
            else break;  
        } 
    } 

    // Visual smoothing 
    visual_x = lerp(visual_x, cursor_x, 0.25); 
    visual_y = lerp(visual_y, cursor_y, 0.25); 


	if (_delete) { 
		final_name = string_delete(final_name, string_length(final_name), 1); 
    }
    // Selection 
    if (accept) { 
        var char = keys[cursor_y][cursor_x]; 
        if (char == "BACK") { 
            final_name = string_delete(final_name, string_length(final_name), 1); 
        } else if (char == "DONE") { 
            if (string_length(final_name) > 0) { 
                global.player_name = final_name; 
                room_goto(rm_introCutscene); 
                scr_text(); 
            }; 
        } else if (string_length(final_name) < max_len) { 
            final_name += char; 
        } 
    } 

    if (back) { 
        prompt_exit = true;
        prompt_option = 1;
        audio_play_sound(snd_menu_move, 0, false);
    }
} 
else {
    if (move_h != 0) {
        prompt_option = (prompt_option == 0) ? 1 : 0;
        audio_play_sound(snd_menu_move, 0, false);
    }
    
    if (accept) {
        if (prompt_option == 0) {
            room_goto(rm_menuRoom);
        } else {
            prompt_exit = false;
        }
    }
    
    if (back) {
        prompt_exit = false;
    }
}