// 1. Draw the torch base normally
draw_self();

// 2. Look for the NEAREST light source that is NOT this torch itself
var _nearest_light = noone;
var _min_dist = 300;

with (obj_light_source) {
    if (id == other.id) continue; // SKIP ITSELF so the torch doesn't light itself up weirdly
    
    var _dist = point_distance(other.x, other.y, x, y);
    if (_dist < _min_dist) {
        _nearest_light = id;
        _min_dist = _dist;
    }
}

// 3. If ANOTHER light is close by, apply the rim lighting to the torch handle
if (_nearest_light != noone && _min_dist <= _nearest_light.light_radius) {
    var _normal_texture = sprite_get_texture(spr_torch_normal, image_index); 
    
    shader_set(sh_rim_lighting);
    texture_set_stage(1, _normal_texture);
    shader_set_uniform_i(shader_get_uniform(sh_rim_lighting, "u_NormalMap"), 1);
    
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightPos"), _nearest_light.x, _nearest_light.y);
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_PlayerPos"), x, y);
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightIntensity"), _nearest_light.light_radius);
    shader_set_uniform_f(shader_get_uniform(sh_rim_lighting, "u_LightColor"),
        color_get_red(_nearest_light.light_color) / 255,
        color_get_green(_nearest_light.light_color) / 255,
        color_get_blue(_nearest_light.light_color) / 255
    );
    
    gpu_set_blendmode(bm_add);
    // Draw the normal map overlay ONLY for the handle/base
    draw_sprite_ext(spr_torch_normal, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    gpu_set_blendmode(bm_normal);
    
    shader_reset();
}

// 4. Finally, draw the flame on top (Always bright, never affected by shaders)
gpu_set_blendmode(bm_add);
draw_sprite(spr_torch_normal, image_index, x, y);
gpu_set_blendmode(bm_normal);