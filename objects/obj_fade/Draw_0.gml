// 1. Draw the object normally
draw_self();

// 2. Draw the fade overlay (e.g., a white flash or black fade)
if (is_fading) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_white); // Change to c_black for a dark fade
    
    // Draws a rectangle over the sprite's area
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    
    draw_set_alpha(1); // Always reset alpha so other things draw correctly
}