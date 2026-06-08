var _light_asset = obj_torch; 

var _nearest_light = noone;
var _min_dist = 500;

if (instance_exists(_light_asset)) {
    with (_light_asset) {
        var _dist = point_distance(other.x, other.y, x, y);
        if (_dist < _min_dist) {
            _nearest_light = id;
            _min_dist = _dist;
        }
    }
}

// =========================================================================
// 3. CALCULATE AND DRAW THE CAST SHADOW
// =========================================================================
if (_nearest_light != noone) {
    // Calculate direction pointing directly AWAY from the torch (Section 2.2)
    var _dir_to_light = point_direction(_nearest_light.x, _nearest_light.y, x, y);
    
    // Calculate shadow length based on the framework formula: C / (distance * 0.1 + 1)
    var _shadow_length = clamp(500 / (_min_dist * 0.1 + 1), 10, 120); 
    
    // Convert pixel length into a scale factor relative to the sprite height
    var _sprite_height = sprite_get_height(sprite_index);
    var _shadow_scale_y = (_sprite_height > 0) ? (_shadow_length / _sprite_height) : 1.0;

    // Set transparency for a realistic shadow overlay
    var _shadow_alpha = 0.4; 

    // Draw the player's silhouette flat on the ground casting away from the light source
    draw_sprite_ext(
        sprite_index, 
        image_index, 
        x, 
        y, 
        image_xscale,       // Match player facing direction
        _shadow_scale_y,    // Scale shadow length dynamically based on distance
        _dir_to_light - 90, // Rotate the shadow away from the torch
        c_black,            // Draw as a solid black silhouette
        _shadow_alpha       // Transparent shadow opacity
    );
}

// =========================================================================
// 4. DRAW THE PLAYER SPRITE ON TOP
// =========================================================================
draw_self();

// =========================================================================
// 5. RUN RIM LIGHTING SHADER
// =========================================================================
if (_nearest_light != noone) {
    // Safety checks: look for properties or supply default values to prevent crashes
    var _radius = variable_instance_exists(_nearest_light, "radius") ? _nearest_light.radius : 200;
    var _color  = variable_instance_exists(_nearest_light, "c_light") ? _nearest_light.c_light : c_white;

    if (_min_dist <= _radius) {
        var _normal_texture = sprite_get_texture(spr_player_normal, image_index); 
        
        shader_set(sh_rim_lighting);
        texture_set_stage(1, _normal_texture);
        
        shader_set_uniform_i(shader_get_uniform(sh_rim_lighting, "u_NormalMap"), 1);
        shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightPos"), _nearest_light.x, _nearest_light.y);
        shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_PlayerPos"), x, y);
        shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightIntensity"), _radius);
        
        // Normalize color channels to 0.0 - 1.0 vectors for the GLSL shader
        var _r = color_get_red(_color) / 255.0;
        var _g = color_get_green(_color) / 255.0;
        var _b = color_get_blue(_color) / 255.0;
        shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightColor"), _r, _g, _b);
        
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(spr_player_normal, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
        gpu_set_blendmode(bm_normal);
        
        shader_reset();
    }
}
