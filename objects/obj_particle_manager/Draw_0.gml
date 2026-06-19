/// @description Render Particles & Numbers
var _count = array_length(particles);

for (var _i = 0; _i < _count; _i++) {
    var _p = particles[_i];
    
    // BRANCH A: Handle Damage Numbers / Text Pop-ups
    if (variable_struct_exists(_p, "is_text") && _p.is_text) {
        draw_set_font(battle_font);
        draw_set_halign(fa_center);
        draw_set_alpha(_p.alpha);
        
        // 1. Draw Drop Shadow (Black outline behind the text for readability)
        draw_set_color(c_black);
        draw_text_transformed(_p.x + 1, _p.y + 1, _p.text, _p.scale, _p.scale, 0);
        
        // 2. Draw Main Text Color
        draw_set_color(_p.color);
        draw_text_transformed(_p.x, _p.y, _p.text, _p.scale, _p.scale, 0);
        
        continue; // Move to next particle
    }
    
    // BRANCH B: Handle Standard Sprite Particles
    if (sprite_exists(_p.sprite)) {
        draw_sprite_ext(_p.sprite, _p.img, _p.x, _p.y, _p.scale * _p.scale_x_dir, _p.scale, _p.rot, _p.color, _p.alpha);
    }
}

draw_set_alpha(1.0);
draw_set_color(c_white);