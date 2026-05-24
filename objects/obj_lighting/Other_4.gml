/// Room Start Event in obj_lighting
switch (room) {
    case rm_outside:
        target_color = c_white; // Soft earthy green tint
        target_alpha = 0.0; // Light shade overlay
        break;
    case rm_outside_2:
        target_color = make_color_rgb(30, 80, 40); // Soft earthy green tint
        target_alpha = 0.4; // Light shade overlay
        break;
        
    case rm_house:
        target_color = make_color_rgb(70, 10, 90); // Moody cyber purple
        target_alpha = 0.85; // Very dark dungeon setting
        break;
        
    case rm_outside_3:
        target_color = c_white; 
        target_alpha = 0.0; // Completely transparent (standard full daylight)
        break;
}