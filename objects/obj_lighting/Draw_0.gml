// 1. CHASE THE CAMERA (Keeps surface aligned perfectly with screen tracking)
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

// 2. SURFACE SECURITY GUARD
if (!surface_exists(lighting_surface)) {
    lighting_surface = surface_create(_cam_w, _cam_h);
}

// 3. TARGET THE CANVAS AND CLEAR WITH AMBIENT MOOD
surface_set_target(lighting_surface);
draw_clear_alpha(current_color, current_alpha);

// 4. ACTIVATE ADD BLEND MODE (Lights will now seamlessly cut into darkness)
gpu_set_blendmode(bm_add);


// ==========================================
// --- DRAW PLAYER LIGHT (PURE GML) ---
// ==========================================
// FIX: Only draw the light if there is actually ambient darkness on screen!
if (current_alpha > 0.01) { 
    if (instance_exists(obj_player)) {
        var _px = obj_player.x - _cam_x;
        var _py = obj_player.y - _cam_y;
        var _p_radius = 64; // Size of player's field of vision
        
        draw_primitive_begin(pr_trianglefan);
        draw_vertex_color(_px, _py, c_white, 0.75); // Radiant center
        
        for (var i = 0; i <= circle_segments; i++) {
            var _angle = (i / circle_segments) * pi * 2;
            var _vx = _px + cos(_angle) * _p_radius;
            var _vy = _py + sin(_angle) * _p_radius;
            draw_vertex_color(_vx, _vy, c_black, 0); // Fades completely to dark edge
        }
        draw_primitive_end();
    }
}


// ==========================================
// --- DRAW MAP ENVIRONMENT LIGHTS ---
// ==========================================
if (instance_exists(obj_environment_light)) {
    with (obj_environment_light) {
        var _lx = x - _cam_x;
        var _ly = y - _cam_y;
        
        // Base characteristics loaded from object parameters
        var _radius = 56 * light_radius;
        var _alpha  = light_strength;
        
        // Organic Cozy Flame Flicker calculation
        if (does_flicker) {
            var _wave = sin((current_time * 0.008) + flicker_offset);
            _radius += _wave * 3.5;  // Slightly pulses size
            _alpha  += _wave * 0.05; // Slightly pulses bright intensity
        }
        
        // Draw the pure-code optimized gradient circle
        draw_primitive_begin(pr_trianglefan);
        draw_vertex_color(_lx, _ly, light_color, _alpha); // Colored Core
        
        for (var i = 0; i <= other.circle_segments; i++) {
            var _angle = (i / other.circle_segments) * pi * 2;
            var _vx = _lx + cos(_angle) * _radius;
            var _vy = _ly + sin(_angle) * _radius;
            draw_vertex_color(_vx, _vy, c_black, 0); // Edge fade
        }
        draw_primitive_end();
    }
}


// 5. RESTORE PIPELINE & RENDER FINAL IMAGE
gpu_set_blendmode(bm_normal);
surface_reset_target();

// Mathematically multiply your color canvas over your sprites/tiles perfectly
gpu_set_blendmode_ext(bm_dest_color, bm_zero);
draw_surface(lighting_surface, _cam_x, _cam_y);
gpu_set_blendmode(bm_normal);