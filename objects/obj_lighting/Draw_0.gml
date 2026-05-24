// 1. LOCATE GAME VIEW PARAMETERS
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

// 2. PERFORMANCE EARLY EXIT (Skip processing completely if the room is fully day-lit)
if (current_alpha <= 0.0) exit;

// 3. SECURE VRAM CANVAS
if (!surface_exists(lighting_surface)) {
    lighting_surface = surface_create(_cam_w, _cam_h);
}

// 4. INITIALIZE SURFACE TARGET AND DRAW BASE COAT
surface_set_target(lighting_surface);
draw_clear_alpha(current_color, current_alpha);

// 5. ENGAGE ADDITIVE BLEND MODE FOR COLOR MIXING
gpu_set_blendmode(bm_add);


// =========================================================================
// --- PLAYER EMISSION PIPELINE ---
// =========================================================================
if (instance_exists(obj_player)) {
    var _px = obj_player.x - _cam_x;
    var _py = obj_player.y - _cam_y;
    
    // Feature A: Soft body illumination (so feet are never completely hidden)
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_px, _py, c_white, 0.35);
    for (var i = 0; i <= circle_segments; i++) {
        var _ang = (i / circle_segments) * pi * 2;
        draw_vertex_color(_px + cos(_ang) * 24, _py + sin(_ang) * 24, c_black, 0);
    }
    draw_primitive_end();
    
    // Feature B: Forward directional field-of-view beam
    var _p_dir = 0;
    if (variable_instance_exists(obj_player, "direction")) _p_dir = obj_player.direction;
    if (variable_instance_exists(obj_player, "facing_angle")) _p_dir = obj_player.facing_angle;
    
    var _p_fov   = 65;  // Width arc of the player flashlight beam
    var _p_range = 110; // Reach of player vision
    
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_px, _py, make_color_rgb(255, 248, 220), 0.55); // Warm yellow-white core
    for (var i = 0; i <= 16; i++) {
        var _ang = dcos(_p_dir - _p_fov / 2 + (i / 16) * _p_fov);
        var _ang_sin = dsin(_p_dir - _p_fov / 2 + (i / 16) * _p_fov);
        draw_vertex_color(_px + _ang * _p_range, _py + _ang_sin * _p_range, c_black, 0);
    }
    draw_primitive_end();
}


// =========================================================================
// --- MAP ENVIRONMENT LIGHT ENGINE ---
// =========================================================================
if (instance_exists(obj_environment_light)) {
    with (obj_environment_light) {
        
        // AUTOMATIC SPRITE CENTERING CALCULATOR
        var _offset_x = 0;
        var _offset_y = 0;
        
        if (sprite_exists(sprite_index)) {
            var _x_origin = sprite_get_xoffset(sprite_index);
            var _y_origin = sprite_get_yoffset(sprite_index);
            
            _offset_x = (sprite_get_width(sprite_index) / 2) - _x_origin;
            _offset_y = (sprite_get_height(sprite_index) / 2) - _y_origin;
        }
        
        // Calculate drawing coordinates relative to the screen frame boundary
        var _lx = (x + _offset_x) - _cam_x;
        var _ly = (y + _offset_y) - _cam_y;
        
        // Extract basic parameters from the individual instance config
        var _radius = 56 * light_radius;
        var _alpha  = light_strength;
        
        // --- ANIMATION REFINERY ENGINE ---
        if (variable_instance_exists(id, "light_behavior")) {
            switch (light_behavior) {
                
                case "fire": // Organic crackling flame animation
                    var _n1 = sin((current_time * 0.007) + flicker_offset);
                    var _n2 = cos((current_time * 0.015) - flicker_offset * 0.5);
                    _radius += (_n1 + _n2) * 2.5;
                    _alpha  += (_n1 * 0.04) + (_n2 * 0.02);
                    break;
                    
                case "pulse": // Smooth breathing rhythmic glow
                    var _p_wave = sin(other.pulse_timer * 1.5);
                    _radius += _p_wave * 6.0;
                    _alpha  += _p_wave * 0.08;
                    break;
                    
                case "neon": // Random stuttering voltage drops
                    if (random(100) > 97) {
                        _alpha *= random_range(0.1, 0.4); 
                    }
                    break;
            }
        }
        
        // Keep rendering math values locked within baseline boundaries
        _alpha = clamp(_alpha, 0.0, 1.0);
        _radius = max(_radius, 1.0);

        // --- THE SHAPE DESK ---
        var _shape = "circle";
        if (variable_instance_exists(id, "light_shape")) _shape = light_shape;
        
        var _angle = 0;
        if (variable_instance_exists(id, "light_angle")) _angle = light_angle;

        switch (_shape) {
            
            case "circle": // Omnidirectional Point Light
                draw_primitive_begin(pr_trianglefan);
                draw_vertex_color(_lx, _ly, light_color, _alpha);
                for (var i = 0; i <= other.circle_segments; i++) {
                    var _ang = (i / other.circle_segments) * pi * 2;
                    draw_vertex_color(_lx + cos(_ang) * _radius, _ly + sin(_ang) * _radius, c_black, 0);
                }
                draw_primitive_end();
                break;
                
            case "cone": // Projective spotlights / Flashlight beams
                var _fov = 50; 
                if (variable_instance_exists(id, "light_fov")) _fov = light_fov;
                
                draw_primitive_begin(pr_trianglefan);
                draw_vertex_color(_lx, _ly, light_color, _alpha);
                for (var i = 0; i <= 16; i++) {
                    var _ang = dcos(_angle - _fov / 2 + (i / 16) * _fov);
                    var _ang_sin = dsin(_angle - _fov / 2 + (i / 16) * _fov);
                    draw_vertex_color(_lx + _ang * _radius, _ly + _ang_sin * _radius, c_black, 0);
                }
                draw_primitive_end();
                break;
                
            case "window": // Volumetric sun/moon window bars
                var _len = _radius * 1.8;
                var _wid = _radius * 0.55;
                
                var _dx = dcos(_angle);
                var _dy = dsin(_angle);
                var _nx = -_dy; 
                var _ny = _dx;
                
                draw_primitive_begin(pr_trianglestrip);
                // Source edge vertices (Window opening frame)
                draw_vertex_color(_lx - _nx * _wid, _ly - _ny * _wid, light_color, _alpha);
                draw_vertex_color(_lx + _nx * _wid, _ly + _ny * _wid, light_color, _alpha);
                
                // Destination edge vertices (Floor dispersion layer)
                draw_vertex_color(_lx + _dx * _len - _nx * _wid * 1.4, _ly + _dy * _len - _ny * _wid * 1.4, c_black, 0);
                draw_vertex_color(_lx + _dx * _len + _nx * _wid * 1.4, _ly + _dy * _len + _ny * _wid * 1.4, c_black, 0);
                draw_primitive_end();
                break;
        }
    }
}


// 6. PIPELINE RESTORATION AND OUTPUT RENDER
gpu_set_blendmode(bm_normal);
surface_reset_target();

// Run matrix multiplication arithmetic to lay ambient color mask over background graphics
gpu_set_blendmode_ext(bm_dest_color, bm_zero);
draw_surface(lighting_surface, _cam_x, _cam_y);
gpu_set_blendmode(bm_normal);