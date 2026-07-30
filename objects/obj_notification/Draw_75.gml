draw_set_alpha(1); 
draw_set_color(c_white);

draw_set_font(Project_Font);

var _gui_w = display_get_gui_width();
var _margin = 6;       // Distance from screen edges
var _box_w = 96;       // Box width matching compact pixel text
var _box_h = 14;       // Box height

// Lock coordinates to the top right, modified by our animation offset
var _draw_x = _gui_w - _box_w - _margin + x_offset;
var _draw_y = _margin;

// Apply the dynamic alpha fade
draw_set_alpha(alpha);

// 1. Draw the geometric "boxed-in" layout border
draw_set_color(c_black);
draw_rectangle(_draw_x, _draw_y, _draw_x + _box_w, _draw_y + _box_h, false); // Background
draw_set_color(c_white);
draw_rectangle(_draw_x, _draw_y, _draw_x + _box_w, _draw_y + _box_h, true);  // Border outline

// 2. Center-align and render the notification text
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

// If you use a custom UI font, assign it here:
// draw_set_font(fnt_ui_small); 

draw_text_ext_transformed(floor(_draw_x + (_box_w / 2)), floor((_box_h / 2)), text, 0, 350, 0.50,0.50,0);

// 3. Reset draw rules so we don't mess up other UI elements
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);