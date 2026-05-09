draw_self();

if (fade_state != 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    
    draw_set_alpha(1);
}