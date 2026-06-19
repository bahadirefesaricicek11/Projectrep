/// @function fx_damage_popup(x, y, text, color)
/// @description Spawns a floating, high-visibility combat text pop-up.
function fx_damage_popup(_x, _y, _text, _color = c_white) {
    if (!instance_exists(obj_particle_manager)) {
        instance_create_depth(0, 0, 0, obj_particle_manager);
    }
    
    with (obj_particle_manager) {
        var _life = 35; // How many frames the number stays on screen
        
        var _p = {
            is_text: true,
            text: string(_text),
            x: _x + random_range(-4, 4), // Small horizontal variance so stacked numbers don't overlay perfectly
            y: _y - 8,                   // Spawn slightly above the target's center point
            hsp: random_range(-0.5, 0.5),
            vsp: -2.5,                   // Initial fast upward burst velocity
            color: _color,
            scale: 0.65,                 // Matches your low-res retro UI scaling factor
            alpha_max: 1.0,
            alpha: 1.0,
            life_max: _life,
            life: _life
        };
        
        array_push(particles, _p);
    }
}

/// @function create_popup_number(x, y, amount, color)
function create_popup_number(_x, _y, _amount, _color) {
    // Ensure tracking array is initialized safely on the battle controller
    if (!variable_instance_exists(obj_battle_controller, "popup_numbers")) {
        obj_battle_controller.popup_numbers = [];
    }
    
    // Push structural instance into runtime array
    array_push(obj_battle_controller.popup_numbers, {
        xx: _x,
        yy: _y - 12, // Offset above target's center frame
        text: string(_amount),
        color: _color,
        max_life: 45, // Total frame count lifetime
        life: 45
    });
}