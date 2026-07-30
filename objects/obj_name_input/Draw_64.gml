draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var grid_offset_x = ((grid_width - 1) * spacing_x) / 2;

var gwidth = global.view_width;
var gheight =global.view_height;

var start_x = (gwidth / 2) - grid_offset_x;
var start_y = (gheight / 3);

var _scale_factor = 0.75;


draw_set_alpha(1);
draw_set_color(c_white);

draw_sprite_stretched(spr_box, 0, start_x-25, 20, 260, 190);
var _text = __("menu.name_screen_label");
draw_text_transformed(gwidth / 2, start_y - 35,  _text + final_name, 1.5, 1.5, 0);


for (var yy = 0; yy < grid_height; yy++) {
    for (var xx = 0; xx < grid_width; xx++) {
        var key_text = keys[yy][xx];
        if (key_text == " ") continue; 

        var dx = start_x + (xx * spacing_x);
        var dy = start_y + (yy * spacing_y);
        var is_hovered = (cursor_x == xx && cursor_y == yy);
        
        if (key_text == "BACK") {
            draw_sprite_ext(spr_back_button, 0, dx - 12, dy - 8, 1, 1, 0, is_hovered ? c_red : c_white, 1);
        } 
        else if (key_text == "DONE") {
            draw_sprite_ext(spr_done_button, 0, dx - 8, dy - 8, 1, 1, 0, is_hovered ? c_lime : c_white, 1);
        } 
        else {
            draw_set_color(is_hovered ? c_yellow : c_white);
            draw_text(dx, dy, key_text);
            
            if (is_hovered) {
                draw_set_colour(c_yellow);
                var soul_x = start_x + (visual_x * spacing_x) - 7;
                var soul_y = start_y + (visual_y * spacing_y) - 6;
                draw_sprite(spr_cursor, -1, soul_x, soul_y); 
            } else {
                draw_set_color(c_white);
            }
        }
    }
}

if (prompt_exit) {
    var box_w = 240; 
    var box_h = 110;  
    var box_x = (gwidth / 2) - (box_w / 2);
    var box_y = (gheight / 2) - (box_h / 2);
    
    draw_sprite_stretched(spr_box, 0, box_x, box_y, box_w, box_h);
    
    draw_set_halign(fa_center); 
    draw_set_valign(fa_middle);
    
    // 1. Localize the main query text using index 0 of your array
    var exit_dialogue = ["menu.name_screen_go_back_query", "menu.name_screen_go_back", "menu.name_screen_cancel"];
    draw_text_ext(gwidth / 2, box_y + 32, __(exit_dialogue[0]), 22, 220);
    
    // 2. Draw "Go Back" option (Index 1)
    draw_set_color(prompt_option == 0 ? c_yellow : c_white);
    draw_text(gwidth / 2 - 40, box_y + 87, __(exit_dialogue[1]));

    // 3. Draw "Cancel" option (Index 2)
    draw_set_color(prompt_option == 1 ? c_yellow : c_white);
    draw_text(gwidth / 2 + 40, box_y + 87, __(exit_dialogue[2]));
    
    draw_set_color(c_white);
}