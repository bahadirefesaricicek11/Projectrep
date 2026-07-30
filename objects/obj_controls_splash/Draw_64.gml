// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1);

var _string = __("menu.tutorial");

draw_set_halign(fa_center);
draw_set_valign(fa_middle); // Recommended: Align vertical middle to center easily
draw_set_font(Bitmap_Font);

draw_sprite(spr_tutorial, 0, 0, 0);

// --- CALCULATION FIX ---
var _scale = 0.5;
var _padding_x = 12; // Extra width on the sides so text doesn't touch edges
var _padding_y = 6;  // Extra height top/bottom

// Calculate actual drawn pixel width and height
var _text_pixel_w = string_width(_string) * _scale;
var _text_pixel_h = string_height(_string) * _scale;

// Calculate box dimensions
var _box_w = _text_pixel_w + (_padding_x * 2);
var _box_h = _text_pixel_h + (_padding_y * 2);

// Center point
var _center_x = (384 / 2) + 8;
var _center_y = (216 / 2);

// Calculate top-left for stretch box (since spr_box draws from top-left)
var _box_x = _center_x - (_box_w / 2);
var _box_y = _center_y - (_box_h / 2);

// Draw the dynamic box
draw_sprite_stretched_ext(spr_box, 0, _box_x, _box_y, _box_w, _box_h, c_white, alpha);

// Draw the text
draw_text_transformed_colour(_center_x, _center_y, _string, _scale, _scale, 0, c_white, c_white, c_white, c_white, alpha);

// Reset alignment & font
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(Project_Font);