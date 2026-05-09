var move_h = InputPressed(INPUT_VERB.RIGHT) -InputPressed(INPUT_VERB.LEFT);
var move_v = InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP);
var accept = InputPressed(INPUT_VERB.ACCEPT)

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

// Selection
if (accept) {
    var char = keys[cursor_y][cursor_x];
    if (char == "BACK") {
        final_name = string_delete(final_name, string_length(final_name), 1);
    } else if (char == "DONE") {
        if (string_length(final_name) > 0) {
				obj_player.name = final_name;
				room_goto(rm_introCutscene);
				scr_text();
			};
    } else if (string_length(final_name) < max_len) {
        final_name += char;
    }
}