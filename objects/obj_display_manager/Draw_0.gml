var _sw    = window_get_width();
var _sh    = window_get_height();
var _scale = min(_sw / 384, _sh / 216);
var _w     = floor(384 * _scale);
var _h     = floor(216 * _scale);
var _x     = floor((_sw - _w) / 2);
var _y     = floor((_sh - _h) / 2);

// Black letterbox bars
draw_set_color(c_black);
draw_rectangle(0, 0, _sw, _sh, false);

// Draw game scaled up
draw_surface_stretched(application_surface, _x, _y, _w, _h);

display_set_gui_size(384, 216);