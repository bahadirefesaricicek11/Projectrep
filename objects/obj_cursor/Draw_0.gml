// Only draw when visible (blinking effect)
if (blink_timer < blink_speed / 2) {
    // Draw Undertale-style heart cursor
    draw_set_color(c_red);
    draw_rectangle(x - 8, y - 8, x + 8, y + 8, false);
    
    // Optional: Add a pointing effect
    draw_set_color(c_white);
    draw_line(x, y + 8, x, y + 20);
    draw_line(x, y + 20, x + 5, y + 15);
}