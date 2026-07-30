// Advance the scroll tracking
bg_scroll_x += scroll_speed;
bg_scroll_y += scroll_speed;

// Wrap cleanly at twice the cell size so colors don't abruptly swap when resetting
if (bg_scroll_x >= (cell_w * 2)) bg_scroll_x -= (cell_w * 2);
if (bg_scroll_y >= (cell_h * 2)) bg_scroll_y -= (cell_h * 2);