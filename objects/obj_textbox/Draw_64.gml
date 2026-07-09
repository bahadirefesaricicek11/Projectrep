if(has_background == true)
{
    draw_sprite_stretched(background, 0, x, y, width, height);
}

var draw_text_x = x;
var draw_text_y = y;
var draw_text_width = text_width;

var finished = text_progress == text_length;

// Portrait
if (sprite_exists(portrait_sprite)) {
    draw_text_width -= portrait_width + portrait_x + padding;
    
    var draw_portrait_x = x + portrait_x;
    var draw_portrait_y = y + portrait_y;
    var draw_portrait_xscale = 1;
    
    draw_text_x += portrait_width + portrait_x + padding;
    
    draw_sprite(spr_portrait, 0, draw_portrait_x - 6, draw_portrait_y- 5);
    
    var subimg = 0;
    if (!finished)
        subimg = (text_progress / text_speed) * (sprite_get_speed(portrait_sprite) / game_get_speed(gamespeed_fps));
        
    draw_sprite_ext(portrait_sprite, subimg,
        draw_portrait_x, draw_portrait_y+1,
        draw_portrait_xscale, 1, 0, c_white, 1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(text_font);
draw_set_color(text_color);

// Note: If your custom 'type' function uses draw_text_transformed internally, 
// you will need to change the scale inside that function to roughly 0.55 or 0.60.
type(draw_text_x + text_x, draw_text_y + text_y, text, text_progress, draw_text_width);

var cursWidth = sprite_get_width(spr_option_arrow);

if (finished && option_count > 0) {
    draw_set_valign(fa_middle);
    draw_set_color(option_text_color);
    for (var i = 0; i < option_count; i++) {
        var opt_x = x + option_x;
        var opt_y = y + option_y - (option_count - i - 1) * option_spacing;
        
        if (i == current_option) {
            opt_x += option_selection_indent;
            draw_sprite(spr_option_arrow, 0, opt_x + (cursorLevitate - cursWidth / 12), opt_y + selectLerp);
        }
        
        // REDUCED SCALE: Dropped from 0.75 down to 0.55 so the choices fit inside the new resolution
        var choice_scale = 0.50; 
        var txw = (string_width(options[i].text) + 30) * choice_scale;
        
        draw_sprite_stretched(option_background, 0, opt_x, opt_y - option_height / 2, txw, option_height);
        draw_text_transformed(opt_x + option_text_x, opt_y + option_text_y, options[i].text, choice_scale, choice_scale, 0);
    }
}