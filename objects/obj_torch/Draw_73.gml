// Check if the torch should be active based on game time 
if (x >= camera_get_view_x(view_camera[0]) - radius && x <= camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) + radius) {
    // Note: The PDF includes a time check function 'is_active_at_time' 
    
    // Calculate the blended light color based on your intensity slider 
    var _blended_light = merge_color(c_light, c_black, 1.0 - intensity); 
    
    // Set blend mode to additive so light pools stack smoothly together
    gpu_set_blendmode(bm_add);
    
    // Draw the main outer light falloff circle fading to black [cite: 76, 80]
    draw_circle_color(x, y, radius, _blended_light, c_black, 0); 
    
    // Draw the intense inner core circle (radius / 3) for a hot center 
    draw_circle_color(x, y, radius / 3, _blended_light, c_black, 0); 
    
    gpu_set_blendmode(bm_normal);
}