/// @description Render Sprite with Controller Screenshake

// Find the battle controller to steal its screenshake offsets
var _sx = 0;
var _sy = 0;
if (instance_exists(obj_battle_controller)) {
    _sx = obj_battle_controller.screenshake_amount > 0 ? random_range(-obj_battle_controller.screenshake_amount, obj_battle_controller.screenshake_amount) : 0;
    _sy = obj_battle_controller.screenshake_amount > 0 ? random_range(-obj_battle_controller.screenshake_amount, obj_battle_controller.screenshake_amount) : 0;
}

// Draw the sprite at its actual room position plus screenshake
draw_sprite_ext(sprite_index, image_index, x + _sx, y + _sy, image_xscale, image_yscale, image_angle, image_blend, image_alpha);