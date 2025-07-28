if (!global.game_pause) exit;

// Setup
draw_set_font(Project_Font);
var gwidth = global.view_width;
var gheight = global.view_height;
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

// Layout
var menu_left = 50;
var title_right = 50;
var title_top = 90;
var y_buffer = 32;
var start_y = (gheight / 2) - (((ds_height - 1) / 2) * y_buffer);
var divider_x = menu_left + 150;
var rtx = divider_x + 16; // Right-side elements start position
var _x = 0;

// Background
var c = c_black;
image_speed = 0.25;
draw_sprite_ext(bg_menu, -1, 0,0, 1*1.3,1*1.3,0,c_white,1)

// Title (Right-Top)
draw_set_font(title_font);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_text_color(gwidth - title_right, title_top, "PROJECT", c_orange, c_yellow, c_white, c_white, 1);
draw_set_valign(fa_middle);
draw_set_font(Project_Font);

// Menu Items (Left Side)
draw_set_halign(fa_left);
var selected = menu_option[page];

for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var element_type = ds_grid[# 1, i];
    var is_selected = (i == selected);
    
    var text_x = menu_left + (is_selected ? xo : 0);
    var col = is_selected ? c_yellow : c_white
    
    draw_text_color(text_x, y_pos, ds_grid[# 0, i], col, col, col, col, 1);
}

// Divider Line
draw_line(divider_x, start_y - y_buffer, divider_x, start_y + (ds_height * y_buffer));

// Interactive Elements (Right Side)
draw_set_halign(fa_left);
for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var element_type = ds_grid[# 1, i];
    
    // Skip text elements and non-interactive items
    if (element_type == menu_element_type.script_runner || 
        element_type == menu_element_type.page_transfer) continue;
        
    var is_selected = (i == selected);
    var col = is_selected ? c_yellow : c_white;

    switch (element_type) {
        case menu_element_type.shift:
            var val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            var arrows = [
                val > 0 ? "<< " : "",
                val < array_length(options)-1 ? " >>" : ""
            ];
            draw_text_color(rtx, y_pos, arrows[0] + options[val] + arrows[1], col, col, col, col, 1);
            break;

        case menu_element_type.slider:
            var current_val = ds_grid[# 3, i];
            var range = ds_grid[# 4, i];
            var slider_width = 100; // Increased width for better precision
            var slider_pos = (current_val - range[0]) / (range[1] - range[0]) * slider_width;
            
            // Draw slider track
            draw_line_width(rtx, y_pos-3, rtx + slider_width, y_pos-3, 2);
            
            // Draw slider handle aligned with the menu text
            if (is_selected) {
                draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos, y_pos-2, 5, 5, 45, c_yellow, 1);
                // Draw value text next to slider
                draw_text_color(rtx + slider_width + 8, y_pos, string(floor(current_val * 100)) + "%", c_yellow, c_yellow, c_yellow, c_yellow, 1);
            } else {
                draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos, y_pos-2, 5, 5, 45, c_white, 1);
                // Draw value text next to slider
                draw_text_color(rtx + slider_width + 8, y_pos, string(floor(current_val * 100)) + "%", c_white, c_white, c_white, c_white, 1);
            }
            break;

        case menu_element_type.toggle:
            current_val = ds_grid[# 3, i];
            col = c_white;
            if (inputting and i == menu_option[page]) {
                c = c_yellow;
            }

            var on_col = (current_val == 1) ? col : c_gray;
            var off_col = (current_val == 0) ? col : c_gray;
            
            draw_text_color(rtx, y_pos, "ON", on_col, on_col, on_col, on_col, 1);
            draw_text_color(rtx + 32, y_pos, "OFF", off_col, off_col, off_col, off_col, 1);
            break;
    }
}

// Reset alignments
draw_set_halign(fa_left);
draw_set_valign(fa_top);