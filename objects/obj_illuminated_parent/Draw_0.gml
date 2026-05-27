// 1. First draw the standard base sprite of the object normally
draw_self();

// 2. Find the nearest light source in the room [cite: 87, 97]
var _nearest_light = noone; // [cite: 89, 91]
var _min_dist = 300;        // Initial fallback search range [cite: 92]

with (obj_light_source) {
    var _dist = point_distance(other.x, other.y, x, y); // [cite: 101, 102]
    if (_dist < _min_dist) {
        _nearest_light = id; // [cite: 106]
        _min_dist = _dist;   // [cite: 108]
    }
}

// 3. If a light is found and it is within range, calculate the rim lighting [cite: 113, 259]
if (_nearest_light != noone && _min_dist <= _nearest_light.light_radius) {
    
    // Get the texture pointer from your normal map sprite [cite: 244]
    // Replace 'spr_character_normal' with your object's matching normal map sprite [cite: 238, 250]
    var _normal_texture = sprite_get_texture(spr_character_normal, image_index); 
    
    shader_set(sh_rim_lighting); // [cite: 208, 243]
    
    // Bind the normal map texture to Sampler Stage 1 [cite: 210, 212]
    texture_set_stage(1, _normal_texture); // [cite: 212]
    shader_set_uniform_i(shader_get_uniform(sh_rim_lighting, "u_NormalMap"), 1); // [cite: 214]
    
    // Pass positioning uniform variables to the shader matrix [cite: 217, 221]
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightPos"), _nearest_light.x, _nearest_light.y); // [cite: 222]
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_PlayerPos"), x, y); // [cite: 224]
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightIntensity"), _nearest_light.light_radius); // [cite: 226]
    
    // Normalize light color components to 0.0 - 1.0 range vectors [cite: 233, 247]
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightColor"),
        color_get_red(_nearest_light.light_color) / 255,   // [cite: 234]
        color_get_green(_nearest_light.light_color) / 255, // [cite: 235]
        color_get_blue(_nearest_light.light_color) / 255   // [cite: 236]
    );
    
    // Use an additive blend to safely overlay the rim glow onto the base sprite
    gpu_set_blendmode(bm_add);
    
    // Draw the normal map overlay frame using the shader logic [cite: 237, 238]
    draw_sprite_ext(spr_character_normal, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    
    gpu_set_blendmode(bm_normal);
    shader_reset(); // [cite: 240, 248]
}