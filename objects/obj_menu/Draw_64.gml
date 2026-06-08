draw_set_font(Project_Font);

var gwidth = global.view_width;
var gheight = global.view_height + (is_ingame ? 50 : 0);
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

if (is_ingame) {
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(0, 0, gwidth, gheight, false);
    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_set_font(title_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_color(gwidth / 2, 25, "PAUSED", c_purple, c_fuchsia, c_yellow, c_orange, 1);
    draw_set_valign(fa_middle);
    draw_set_font(Project_Font);
} else {
	image_speed = 0.3;
    draw_sprite_ext(bg_menu, -1, 0, 0, 1*1.3, 1*1.3, 0, c_white, 1);
    draw_set_font(title_font);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_text_color(gwidth - 50, 90 * 1.3, "PROJECT", c_orange, c_yellow, c_white, c_white, 1);
    draw_set_valign(fa_middle);
    draw_set_font(Project_Font);
}

if (is_ingame && prompt_exit) {
    var prompt_box_w = 400;
    var prompt_box_h = 200;
    var prompt_box_x = (gwidth / 2) - (prompt_box_w / 2);
    var prompt_box_y = (gheight / 2) - (prompt_box_h / 2);
    
    draw_sprite_stretched(spr_box, 0, prompt_box_x, prompt_box_y, prompt_box_w, prompt_box_h);
    
    draw_set_halign(fa_center);
    draw_text(gwidth / 2, gheight / 2 - 40, "Save before returning to Main Menu?");
    
    var prompt_labels = ["Save & Exit", "Exit Without Saving", "Cancel"];
    for (var p = 0; p < 3; p++) {
        var col = (p == prompt_option) ? c_yellow : c_white;
        var prefix = (p == prompt_option) ? "> " : "";
        draw_text_color(gwidth / 2, gheight / 2 + 10 + (p * 30), prefix + prompt_labels[p], col, col, col, col, 1);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

var y_buffer = 32;
var start_y, divider_x, menu_left, rtx;

if (is_ingame) {
    var main_box_w = 420; 
    var main_box_h = (ds_height * y_buffer) + (y_buffer * 1.5); 
    var main_box_x = (gwidth / 2) - (main_box_w / 2);
    var main_box_y = (gheight / 2) - (main_box_h / 2);
    
    draw_sprite_stretched(spr_box, 0, main_box_x, main_box_y, main_box_w, main_box_h);
    
    start_y = main_box_y + y_buffer; 
    divider_x = gwidth / 2;
    menu_left = main_box_x + 40; 
    rtx = divider_x + 20; 
    
    draw_line(divider_x, main_box_y + 15, divider_x, main_box_y + main_box_h - 15);
} else {
    start_y = (gheight / 2) - (((ds_height - 1) / 2) * y_buffer);
    menu_left = 50;
    divider_x = menu_left + 150;
    rtx = divider_x + 16;
    
    draw_line(divider_x, start_y - y_buffer, divider_x, start_y + (ds_height * y_buffer));
}

var selected = menu_option[page];
draw_set_halign(fa_left);

for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var element_type = ds_grid[# 1, i];
    var is_selected = (i == selected);
    
    // Left-side Text
    var text_x = menu_left + (is_selected ? xo : 0);
    var col = is_selected ? c_yellow : c_white;
    draw_text_color(text_x, y_pos, ds_grid[# 0, i], col, col, col, col, 1);
    
    // Right-side Elements
    if (element_type == menu_element_type.script_runner || element_type == menu_element_type.page_transfer) continue;

    switch (element_type) {
        case menu_element_type.shift:
            var val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            var arrows = [val > 0 ? "<< " : "", val < array_length(options)-1 ? " >>" : ""];
            draw_text_color(rtx, y_pos, arrows[0] + options[val] + arrows[1], col, col, col, col, 1);
            break;

        case menu_element_type.slider:
            var current_val = ds_grid[# 3, i];
            var range = ds_grid[# 4, i];
            var slider_width = 100;
            var slider_pos = (current_val - range[0]) / (range[1] - range[0]) * slider_width;
            
            draw_line_width(rtx, y_pos-3, rtx + slider_width, y_pos-3, 2);
            
            var ball_color = is_selected ? c_yellow : c_white;
            draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos, y_pos-2, 5, 5, 45, ball_color, 1);
            draw_text_color(rtx + slider_width + 8, y_pos, string(floor(current_val * 100)) + "%", ball_color, ball_color, ball_color, ball_color, 1);
            break;

       case menu_element_type.toggle:
            var current_val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            
            var active_col = is_selected ? c_yellow : c_white;
            if (inputting && i == menu_option[page]) active_col = c_yellow; 
            
            var display_string = options[current_val];
            if (is_selected && inputting) display_string = "< " + display_string + " >";
            
            draw_text_color(rtx, y_pos, display_string, active_col, active_col, active_col, active_col, 1);
            break;
    }
}

if (fade_alpha > 0) {
    draw_set_color(c_black);
    draw_set_alpha(fade_alpha);

    if (is_ingame) {
        draw_rectangle(0, 0, gwidth, gheight, false);
    } else {
        var _cam_x = camera_get_view_x(view_camera[0]);
        var _cam_y = camera_get_view_y(view_camera[0]);
        var _cam_w = camera_get_view_width(view_camera[0]);
        var _cam_h = camera_get_view_height(view_camera[0]);
        draw_rectangle(_cam_x, _cam_y, _cam_x + _cam_w*1.3, _cam_y + _cam_h*1.3, false);
    }
    
    draw_set_alpha(1); 
    draw_set_color(c_white); 
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);