// 1. Smoothly transition the ambient darkness intensity
current_alpha = lerp(current_alpha, target_alpha, transition_speed);

// 2. Isolate and transition individual RGB color channels
var _cur_r = color_get_red(current_color);
var _cur_g = color_get_green(current_color);
var _cur_b = color_get_blue(current_color);

var _tar_r = color_get_red(target_color);
var _tar_g = color_get_green(target_color);
var _tar_b = color_get_blue(target_color);

var _new_r = lerp(_cur_r, _tar_r, transition_speed);
var _new_g = lerp(_cur_g, _tar_g, transition_speed);
var _new_b = lerp(_cur_b, _tar_b, transition_speed);

// Pack channels back into a single GameMaker color variable
current_color = make_color_rgb(_new_r, _new_g, _new_b);

// 1. Existing transition code (keep your lerp lines above this)
// ... (your current color and alpha lerp math) ...


// 2. THE FIX: Snap values if they are microscopic, preventing lingering darkness
if (abs(current_alpha - target_alpha) < 0.005) {
    current_alpha = target_alpha;
}

if (current_alpha == 0.0) {
    current_color = c_white; // Reset completely to clear white daylight
}


depth = -99999;