draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Calculate the center of the grid
var grid_offset_x = ((grid_width - 1) * spacing_x) / 2;
var start_x = (room_width / 2) - grid_offset_x;
var start_y = (room_height / 3); 


draw_set_color(c_white);
draw_text_transformed(room_width / 2, start_y - 50, "NAME: " + final_name, 1.5, 1.5, 0);

for (var yy = 0; yy < grid_height; yy++) {
    for (var xx = 0; xx < grid_width; xx++) {
        var key_text = keys[yy][xx];
        if (key_text == " ") continue; 

        var dx = start_x + (xx * spacing_x);
        var dy = start_y + (yy * spacing_y);
		var is_hovered = (cursor_x == xx && cursor_y == yy);
		
		if (key_text == "BACK") {
            draw_sprite_ext(spr_back_button, 0, dx-10, dy - 10, 1, 1, 0, is_hovered ? c_red : c_white, 1);
        } 
        else if (key_text == "DONE") {
            draw_sprite_ext(spr_done_button, 0, dx -5, dy - 10, 1, 1, 0, is_hovered ? c_lime : c_white, 1);
        } 
        else {
            draw_set_color(is_hovered ? c_yellow : c_white);
            draw_text(dx, dy, key_text);
			
			if (is_hovered) {
			draw_set_colour(c_yellow);
			var soul_x = start_x + (visual_x * spacing_x) - 24;
			var soul_y = start_y + (visual_y * spacing_y);
            draw_sprite(spr_cursor,-1,soul_x, soul_y-11.5); 
	        } else {
	            draw_set_color(c_white);
	        }
        }
    }
}