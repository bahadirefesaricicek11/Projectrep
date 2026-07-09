/// @description Render Enemy Naturally in World Space

// Capture screenshake offsets safely if controller exists
var _sx = 0;
var _sy = 0;

if (instance_exists(obj_battle_controller)) {
    var _amt = obj_battle_controller.screenshake_amount;
    if (_amt > 0) {
        _sx = random_range(-_amt, _amt);
        _sy = random_range(-_amt, _amt);
    }
}

// Draw the enemy sprite at its real room position plus screenshake vectors
if (sprite_exists(sprite_index)) {
    draw_sprite_ext(
        sprite_index, 
        image_index, 
        x + _sx, 
        y + _sy, 
        image_xscale, 
        image_yscale, 
        image_angle, 
        image_blend, 
        image_alpha
    );
}