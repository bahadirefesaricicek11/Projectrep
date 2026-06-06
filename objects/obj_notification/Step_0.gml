// Basic animation state machine
if (fade_stage == 0) {
    // Slide and fade in smoothly
    x_offset = lerp(x_offset, 0, 0.2);
    alpha = lerp(alpha, 1, 0.2);
    if (x_offset < 0.5) {
        x_offset = 0;
        alpha = 1;
        fade_stage = 1;
    }
} 
else if (fade_stage == 1) {
    // Hold visible on screen
    timer--;
    if (timer <= 0) fade_stage = 2;
} 
else if (fade_stage == 2) {
    // Slide out and fade away
    x_offset = lerp(x_offset, 80, 0.15);
    alpha = lerp(alpha, 0, 0.15);
    if (alpha < 0.05) {
        instance_destroy(); // Remove completely when invisible
    }
}