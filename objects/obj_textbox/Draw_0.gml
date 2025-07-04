confirm_key = keyboard_check_pressed(vk_enter) or keyboard_check_pressed(ord("Z")) or gamepad_button_check_pressed(0, gp_face1);
skip_key = keyboard_check_pressed(vk_shift) or keyboard_check_pressed(ord("X")) or gamepad_button_check_pressed(0, gp_face2);

textbox_x	= camera_get_view_x(view_camera[0]) - 25;
textbox_y	= camera_get_view_y(view_camera[0]) + 148;

if(setup == false) {
	setup = true;
	
	obj_player.can_move = false;
	
	draw_set_font(fText);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	
	for (var p = 0; p < page_number; p++) {
		text_length[p] = string_length(text[p]);
		text_x_offset[p] = 44;
	}
}

if draw_char < text_length[page] {
	draw_char+= text_speed;
	draw_char = clamp(draw_char,0, text_length[page]);
}

if confirm_key {
	if draw_char == text_length[page]{
		if page < page_number-1{
			page++
			draw_char = 0;
		}
		else{
			
			if option_number > 0 {
				create_textbox(option_link_id[option_pos]);
			}
			obj_player.can_move = true;
			instance_destroy();
		}
	}
} else if skip_key and draw_char != text_length[page]{
		draw_char = text_length[page];
}


var _txtb_x = textbox_x + text_x_offset[page];
var _txtb_y = textbox_y

txtb_image += txtb_image_spd;
txtb_sprite_w = sprite_get_width(txtb_sprite)
txtb_sprite_h = sprite_get_height(txtb_sprite)

draw_sprite_ext(txtb_sprite,txtb_image, _txtb_x, _txtb_y, textbox_width/txtb_sprite_w, textbox_height/txtb_sprite_h,0, c_white,1);

if draw_char == text_length[page] && page == page_number - 1
{
	
	option_pos += (keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd)|| keyboard_check_pressed(ord("S"))) - (keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu)|| keyboard_check_pressed(ord("W")));
	option_pos = clamp(option_pos, 0, option_number-1);
	
	var _c = c_white;
	
	var _op_space = 21;
	var _op_border = 8;
	for(var op = 0; op < option_number; op++)
	{
		var _o_w = string_width(option[op]) + _op_border*2;
		draw_sprite_ext(txtb_sprite, txtb_image, _txtb_x  + 16, _txtb_y - _op_space*option_number + _op_space*op, _o_w/txtb_sprite_w, (_op_space-1)/txtb_sprite_h, 0, _c, 1);
		
		if option_pos == op
		{
			draw_sprite(spr_textbox_arrow, 0, _txtb_x, _txtb_y - _op_space*option_number + _op_space*op);
		}
		
		
		draw_text_color(_txtb_x + 16 + _op_border, _txtb_y - _op_space*option_number + _op_space*op - 7, option[op], _c,_c,_c,_c, 1);
	}
}

var _drawtext = string_copy(text[page], 1, draw_char);
draw_text_ext(_txtb_x + border, _txtb_y + border, _drawtext,line_sep,line_width);