
if (!variable_instance_exists(id, "bg_scroll_x")) {
	bg_scroll_x = 0;
	bg_scroll_y = 0;
}

// Move by 1 whole pixel per frame
bg_scroll_x += 1;
bg_scroll_y += 1; 

var cell_w = 16; 
var cell_h = 16; 

// Reset exactly at 2 full cells so colors match perfectly when wrapping
if (bg_scroll_x >= (cell_w * 2)) bg_scroll_x = 0;
if (bg_scroll_y >= (cell_h * 2)) bg_scroll_y = 0;

var color1 = make_color_rgb(222, 222, 222);  // Light Gray
var color2 = make_color_rgb(145, 166, 205);   // Yellow

var cell_x = 0;
// Start drawing off-screen by 2 cells to give padding for the movement
for (var xx = -cell_w * 2; xx < gwidth + cell_w * 2; xx += cell_w) {
	var cell_y = 0;
	for (var yy = -cell_h * 2; yy < gheight + cell_h * 2; yy += cell_h) {
		// Pure checkerboard math based strictly on loop grid position
		var current_color = ((cell_x + cell_y) % 2 == 0) ? color1 : color2;
		var draw_x = xx + bg_scroll_x;
		var draw_y = yy + bg_scroll_y;
            
		draw_set_color(current_color);
		draw_set_alpha(0.5);
            
		// Draw perfectly flush boxes
		draw_rectangle(draw_x, draw_y, draw_x + cell_w - 1, draw_y + cell_h - 1, false);
            
		cell_y++;
	}
	cell_x++;
}
    
// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);