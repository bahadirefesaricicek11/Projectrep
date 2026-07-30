var _gwidth  = display_get_gui_width();
var _gheight = display_get_gui_height();

var _cell_x = 0;

draw_clear(c_black);
// Draw with 2 extra cells of padding outside the view bounds to hide edge clipping
for (var _xx = -cell_w * 2; _xx < _gwidth + cell_w * 2; _xx += cell_w) {
    var _cell_y = 0;
    for (var _yy = -cell_h * 2; _yy < _gheight + cell_h * 2; _yy += cell_h) {
        
        // Pure checkerboard math based strictly on loop grid positions
        var _current_color = ((_cell_x + _cell_y) % 2 == 0) ? color_light : color_blue;
        
        var _draw_x = _xx + bg_scroll_x;
        var _draw_y = _yy + bg_scroll_y;
        
        draw_set_color(_current_color);
        draw_set_alpha(alpha);
        
        // Draw flush rectangular bounds
        draw_rectangle(_draw_x, _draw_y, _draw_x + cell_w - 1, _draw_y + cell_h - 1, false);
        
        _cell_y++;
    }
    _cell_x++;
}

// Always reset globally altered draw states immediately
draw_set_color(c_white);
draw_set_alpha(1.0);