// 1. Linearly interpolate ambient density
current_alpha = lerp(current_alpha, target_alpha, transition_speed);

// 2. Transform RGB color space independently 
var _cr = color_get_red(current_color);
var _cg = color_get_green(current_color);
var _cb = color_get_blue(current_color);

var _tr = color_get_red(target_color);
var _tg = color_get_green(target_color);
var _tb = color_get_blue(target_color);

var _nr = lerp(_cr, _tr, transition_speed);
var _ng = lerp(_cg, _tg, transition_speed);
var _nb = lerp(_cb, _tb, transition_speed);

current_color = make_color_rgb(_nr, _ng, _nb);

// 3. Absolute Snapping Engine
if (abs(current_alpha - target_alpha) < 0.004) {
    current_alpha = target_alpha;
}
if (current_alpha == 0.0) {
    current_color = c_white;
}

// 4. Update the global animation clock
pulse_timer += 0.05;

depth = -99999;