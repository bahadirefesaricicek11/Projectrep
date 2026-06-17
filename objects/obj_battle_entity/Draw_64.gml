if (global.state != GAME_STATE.BATTLE) exit;
if (!variable_instance_exists(id, "stats") || stats == undefined) exit;

// Force alignment values to balance inside the top horizontal 384x110 banner matrix space
var _render_x = 240 + (x * 0.1); 
var _render_y = 100; // Position entities neatly inside the upper background window row

// Draw Enemy Shape Placeholder
draw_set_color(c_red);
draw_circle(_render_x, _render_y, 10, false);

// Text labels and individual miniature HP healthbars tracking metrics
draw_set_font(Project_Font);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(_render_x, _render_y - 24, string(stats.name));
draw_set_halign(fa_left);

// 3. Mini HP Track Bar Component Layout
var _bar_w = 45;
var _bar_h = 4;
var _bx = _render_x - (_bar_w / 2);
var _by = _render_y - 18;

draw_set_color(c_black);
draw_rectangle(_bx - 1, _by - 1, _bx + _bar_w + 1, _by + _bar_h + 1, false);

var _hp_percent = clamp(stats.hp / stats.max_hp, 0, 1);
draw_set_color(c_red);
draw_rectangle(_bx, _by, _bx + (_bar_w * _hp_percent), _by + _bar_h, false);

draw_set_halign(fa_left);