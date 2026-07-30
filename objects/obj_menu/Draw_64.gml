draw_set_font(Project_Font);

// --- INLINE TRUNCATION HELPER FUNCTION ---
// Measures pixel-width of the localized label and appends "..." if it is too wide
var _truncate_label = function(_str, _max_width) {
    if (string_width(_str) <= _max_width) {
        return _str;
    }
    var _ellipsis = "...";
    var _trunc_str = _str;
    while (string_length(_trunc_str) > 0 && string_width(_trunc_str + _ellipsis) > _max_width) {
        _trunc_str = string_delete(_trunc_str, string_length(_trunc_str), 1);
    }
    return _trunc_str + _ellipsis;
};

var gwidth = view_width;
var gheight = view_height + (is_ingame ? 50 : 0);
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);
var _title = "PAUSED";

if (is_ingame) {

    // FIX 1: Localize the Pause title header
    _title = __("menu.title_paused"); 
    draw_set_font(title_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext_transformed_colour((gwidth / 2)-1, 16, _title, 0, 300, 1, 1, 0, c_navy, c_purple, c_orange, c_olive, 1);
    draw_text_ext_transformed_colour(gwidth / 2, 15, _title, 0, 300, 1, 1, 0, c_purple, c_fuchsia, c_yellow, c_orange, 1);
    draw_set_valign(fa_middle);
    draw_set_font(Project_Font);
} else {
    image_speed = 0.3;
    if (page == 0 || page == 1)
    {
        draw_sprite_stretched(spr_box, 0, (gwidth/2)+10, 90, 160, 24);
        
        draw_sprite_ext(spr_menu_title, 0, (gwidth/2)+20, (gheight/2)-12, 1.5, 1.5, 0, c_white, 1);
    }
    draw_set_valign(fa_middle);
    draw_set_font(Project_Font);
}

// FIX 3: In-game exit validation prompt box localization
if (is_ingame && prompt_exit) {
    var prompt_box_w = 300;
    var prompt_box_h = 150;
    var prompt_box_x = (gwidth / 2) - (prompt_box_w / 2);
    var prompt_box_y = (gheight / 2) - (prompt_box_h / 2);
    
    draw_sprite_stretched(spr_box, 0, prompt_box_x, prompt_box_y, prompt_box_w, prompt_box_h);
    
    draw_set_halign(fa_center);
    draw_text_ext(gwidth / 2, gheight / 2.2 - 40, __("menu.prompt_save_query"), 20, 300);
    
    var prompt_labels = ["menu.prompt_save_exit", "menu.prompt_no_save_exit", "menu.prompt_cancel"];
    for (var p = 0; p < 3; p++) {
        var shadow_col = (p == prompt_option) ? c_orange : c_ltgray;
        var col = (p == prompt_option) ? c_yellow : c_white;
        var prefix = (p == prompt_option) ? "> " : "";
        
        var _prompt_display_string = prefix + __(prompt_labels[p]);
        draw_text_color((gwidth / 2)-1, (gheight / 2.2 + 5 + (p * 30))+1, _prompt_display_string, shadow_col, shadow_col, shadow_col, shadow_col, 1);
        draw_text_color(gwidth / 2, gheight / 2.2 + 5 + (p * 30), _prompt_display_string, col, col, col, col, 1);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

var y_buffer = 30;
var start_y, divider_x, menu_left, rtx;

if (is_ingame) {
    var main_box_w = 320; 
    var main_box_h = (ds_height * y_buffer) + (y_buffer); 
    var main_box_x = (gwidth / 2) - (main_box_w / 2);
    var main_box_y = (gheight / 3) - (main_box_h / 3);
    
    //draw_sprite_stretched_ext(spr_box, 0, main_box_x, main_box_y, main_box_w, main_box_h, c_white, 1);
    
    start_y = main_box_y + y_buffer; 
    divider_x = gwidth / 2.1;
    menu_left = main_box_x + 40; 
    rtx = divider_x + 20; 
    
    draw_line(divider_x, main_box_y + 15, divider_x, main_box_y + main_box_h - 15);
} else {
    start_y = (gheight / 2) - (((4 - 1) / 2) * y_buffer);
    menu_left = 50;
    divider_x = gwidth / 2.1;
    rtx = divider_x + 20; 
    
    draw_line(divider_x, start_y - y_buffer, divider_x, start_y + (ds_height * y_buffer));
}

var selected = menu_option[page];
draw_set_halign(fa_left);

var max_label_w = (divider_x - menu_left) - 15;

for (var i = 0; i < ds_height; i++) {
    var y_pos = start_y + (i * y_buffer);
    var element_type = ds_grid[# 1, i];
    var is_selected = (i == selected);
    
    var raw_menu_key = ds_grid[# 0, i]; 
    var raw_localized_label = __(raw_menu_key); 
    
    var localized_menu_label = _truncate_label(raw_localized_label, max_label_w);
    
    var text_x = menu_left + (is_selected ? xo : 0);
    
    // Kept yellow selection colors for text
    var col = is_selected ? c_yellow : c_white;
    var shadow_col = is_selected ? c_orange : c_ltgray;
    
    // --- DRAW PROCEDURAL SLANTED INVERT BANNER ---
    if (is_selected) {
        var _banner_padding_x = 12;
        var _banner_h = 24;
        var _skew = 12;
        
        // Extended total width to handle left offset over icon + right edge padding
        var _banner_w = string_width(localized_menu_label) + 30 + _banner_padding_x;
        
        // Shift left offset to text_x - 30 to start before the icon (text_x - 20)
        var _x1 = text_x - 30;
        var _y1 = y_pos - 10; 
        var _x2 = _x1 + _banner_w;
        var _y2 = _y1 + _banner_h;
        
        // Enable subtractive inverse color blend mode
        gpu_set_blendmode_ext(bm_inv_dest_color, bm_zero);
        
        // Draw solid white polygon (inverts background colors underneath)
        draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_x1 + _skew, _y1, c_white, 1);
            draw_vertex_color(_x1,         _y2, c_white, 1);
            draw_vertex_color(_x2 + _skew, _y1, c_white, 1);
            draw_vertex_color(_x2,         _y2, c_white, 1);
        draw_primitive_end();
        
        // Reset blend mode back to normal
        gpu_set_blendmode(bm_normal);
    }
    
    // Draw option text in yellow
    draw_text_color(text_x-1, y_pos+1, localized_menu_label, shadow_col, shadow_col, shadow_col, shadow_col, 1);
    draw_text_color(text_x, y_pos, localized_menu_label, col, col, col, col, 1);
    
    switch (page)
    {
        case menu_page.main:
            draw_sprite_ext(spr_menu_icons, i, text_x - 20, y_pos - 7, 0.5, 0.5, 0, c_white, 1);
            break;
        
        case menu_page.settings:
            draw_sprite_ext(spr_menu_icons, i+4, text_x -20, y_pos-7, 0.5, 0.5, 0, c_white, 1);
            break;
    }
    
    if (element_type == menu_element_type.script_runner || element_type == menu_element_type.page_transfer) continue;

    switch (element_type) {
        case menu_element_type.shift:
            var val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            var arrows = [val > 0 ? "<" : "", val < array_length(options)-1 ? ">" : ""];
            
            var _shifted_display = arrows[0] + __(options[val]) + arrows[1];
            
            draw_text_color(rtx-1, y_pos+1, _shifted_display, shadow_col, shadow_col, shadow_col, shadow_col, 1);
            draw_text_color(rtx, y_pos, _shifted_display, col, col, col, col, 1);
            break;

        case menu_element_type.slider:
            var current_val = ds_grid[# 3, i];
            var range = ds_grid[# 4, i];
            var slider_width = 100;
            var slider_pos = (current_val - range[0]) / (range[1] - range[0]) * slider_width;
            
            var slider_y = y_pos;
            
            draw_line_width_colour(rtx-1, slider_y+1 , rtx + slider_width-1, slider_y+1, 2, c_ltgray, c_ltgray);
            draw_line_width(rtx, slider_y , rtx + slider_width, slider_y, 2);
            
            var ball_color = is_selected ? c_yellow : c_white;
            
            draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos-1, slider_y+2, 5, 5, 45, c_ltgray, 1);
            draw_sprite_ext(spr_slider_ball, 0, rtx + slider_pos, slider_y+1, 5, 5, 45, ball_color, 1);
            
            draw_text_color(rtx-1 + slider_width + 8, y_pos+1, string(floor(current_val * 100)) + "%", shadow_col, shadow_col, shadow_col, shadow_col, 1);
            draw_text_color(rtx + slider_width + 8, y_pos, string(floor(current_val * 100)) + "%", ball_color, ball_color, ball_color, ball_color, 1);
            break;

        case menu_element_type.toggle:
            var current_val = ds_grid[# 3, i];
            var options = ds_grid[# 4, i];
            
            var active_col = is_selected ? c_yellow : c_white;
            if (inputting && i == menu_option[page]) active_col = c_yellow; 

            var display_string = __(options[current_val]); 
            if (is_selected && inputting) display_string = "<" + display_string + ">";
            
            draw_text_color(rtx-1, y_pos+1, display_string, shadow_col, shadow_col, shadow_col, shadow_col, 1);
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
        var _cam_w = global.view_width;
        var _cam_h = global.view_height;
        draw_rectangle(_cam_x, _cam_y, _cam_x + _cam_w, _cam_x + _cam_h, false);
    }
    
    draw_set_alpha(1); 
    draw_set_color(c_white); 
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);