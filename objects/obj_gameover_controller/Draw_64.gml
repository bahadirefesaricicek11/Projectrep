/// @description Draw UI Layout Elements

// --- 1. DRAW ROTATING CONFETTI OVER THE GUI ---
var _c_count = array_length(confetti_list);
for (var _i = 0; _i < _c_count; _i++) {
    var _c = confetti_list[_i];
    
    if (sprite_exists(spr_confetti)) {
        draw_sprite_ext(spr_confetti, 0, _c.x, _c.y, _c.scale_x, 1.0, _c.angle, _c.color, 1.0);
    } else {
        draw_set_color(_c.color);
        draw_rectangle(_c.x - 3, _c.y - 4, _c.x + 3, _c.y + 4, false);
    }
}

// --- 2. DRAW ANIMATED FLOATING GOOFY SPRITE ---
if (sprite_exists(goofy)) {
    // Pass 'goofy_frame' instead of a static number to let the frames cycle
    draw_sprite_ext(goofy, goofy_frame, current_goofy_x, current_goofy_y, 1.0, 1.0, 0, c_white, 1.0);
}

// --- 3. DRAW SELECTION PROMPT ---
if (choice_active) {
    draw_set_font(Project_Font); 
    draw_set_valign(fa_middle);
    draw_set_halign(fa_center);
    
    var _center_x = display_get_gui_width() / 2;
    var _prompt_y = display_get_gui_height() / 2 + 10;
    
    var _left_btn_x  = _center_x - 60;
    var _right_btn_x = _center_x + 60;
    var _btn_y       = _prompt_y + 15;
    
    var _cont_color = (menu_choice == 0) ? c_yellow : c_gray;
    var _give_color = (menu_choice == 1) ? c_yellow : c_gray;
    
    draw_set_color(_cont_color);
    draw_text(_left_btn_x, _btn_y, "CONTINUE");
    
    draw_set_color(_give_color);
    draw_text(_right_btn_x, _btn_y, "GIVE UP"); 

    // Render the smooth lerping cursor sprite
    if (sprite_exists(spr_cursor)) {
        draw_sprite_ext(spr_cursor, 0, cursor_x, cursor_y, 1.0, 1.0, 0, c_white, 1.0);
    }
}

// Reset baseline draw metrics
draw_set_color(c_white);