if (keyboard_check_pressed(vk_f4) || keyboard_check_pressed(vk_f11)) {
    
    if (window_get_fullscreen()) { 
        
        window_set_fullscreen(false);
        
        // Reset the window to your exact 3x border layout size (416 * 3 = 1248, 256 * 3 = 768)
        window_set_size(1248, 768);
        
        // Trigger Alarm 0 on the next frame to center the window cleanly
        alarm[0] = 1; 
    }
    else {
        // SWITCH TO FULLSCREEN MODE
        window_set_fullscreen(true);
    }
}