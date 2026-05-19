draw_set_font(Project_Font);
var gwidth = global.view_width;
var gheight = global.view_height+50;
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

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

if (prompt_exit) {
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
var main_box_w = 420; 
var main_box_h = (ds_height * y_buffer) + (y_buffer * 1.5); 
var main_box_x = (gwidth / 2) - (main_box_w / 2);
var main_box_y = (gheight / 2) - (main_box_h / 2);

var start_y = main_box_y + y_buffer; 
var divider_x = gwidth / 2;
var menu_left = main_box_x + 40; 
var rtx = divider_x + 20; 

draw_sprite_stretched(spr_box, 0, main_box_x, main_box_y, main_box_w, main_box_h);

var selected = menu_option[page];
draw_set_halign(fa_left);

for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var is_selected = (i == selected);
    
    var text_x = menu_left + (is_selected ? xo : 0);
    var col = is_selected ? c_yellow : c_white;
    
    draw_text_color(text_x, y_pos, ds_grid[# 0, i], col, col, col, col, 1);
}

draw_line(divider_x, main_box_y + 15, divider_x, main_box_y + main_box_h - 15);

for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var element_type = ds_grid[# 1, i];
    
    if (element_type == menu_element_type.script_runner || element_type == menu_element_type.page_transfer) continue;
        
    var is_selected = (i == selected);
    var col = is_selected ? c_yellow : c_white;

    switch (element_type) {
        case menu_element_type.shift:
            var val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            var arrows = [
                val > 0 ? "<< " : "",
                val < array_length(options) - 1 ? " >>" : ""
            ];
            draw_text_color(rtx, y_pos, arrows[0] + options[val] + arrows[1], col, col, col, col, 1);
            break;

        case menu_element_type.slider:
            var current_val = ds_grid[# 3, i];
            var range = ds_grid[# 4, i];
            var slider_width = 100;
            var slider_pos = (current_val - range[0]) / (range[1] - range[0]) * slider_width;
            
            draw_line_width(rtx, y_pos - 3, rtx + slider_width, y_pos - 3, 2);
            
            var ball_color = is_selected ? c_yellow : c_white;
            draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos, y_pos - 2, 5, 5, 45, ball_color, 1);
            draw_text_color(rtx + slider_width + 8, y_pos, string(floor(current_val * 100)) + "%", ball_color, ball_color, ball_color, ball_color, 1);
            break;

        case menu_element_type.toggle:
            current_val = ds_grid[# 3, i];
            if (inputting && i == menu_option[page]) col = c_yellow;

            var on_col = (current_val == 1) ? col : c_gray;
            var off_col = (current_val == 0) ? col : c_gray;
            
            draw_text_color(rtx, y_pos, "ON", on_col, on_col, on_col, on_col, 1);
            draw_text_color(rtx + 32, y_pos, "OFF", off_col, off_col, off_col, off_col, 1);
            break;
    }
}

if (fade_alpha > 0) {
    draw_set_color(c_black);
    draw_set_alpha(fade_alpha);
    draw_rectangle(0, 0, gwidth, gheight, false);
    draw_set_alpha(1); 
    draw_set_color(c_white); 
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);