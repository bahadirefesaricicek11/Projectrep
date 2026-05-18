if obj_item_manager.inv_open == true
{
	draw_set_font(textfont);
	draw_set_valign(fa_top);
    
	common_color = make_color_rgb(51, 204, 255);
	rare_color = make_color_rgb(255, 204, 0);
	epic_color = make_color_rgb(153, 0, 153);

	var _xx = _x;
	var _yy = _y;
	var _sep = sep;
	var _sepx = sepx;

	draw_sprite(spr_inventory_background, 0, 240, 135);
    
	draw_set_halign(fa_center);

	var player_name = string(obj_player.name);
	var max_width = 50;
	var max_scale = 0.25;

	var full_width = string_width(player_name); 

	var target_scale = max_width / full_width;

	var final_scale = min(max_scale, target_scale);

	draw_text_ext_transformed(173, 60, player_name, 0, 50, final_scale, final_scale, 0);

	draw_set_halign(fa_left);
	draw_text_transformed(147, 74, "Strength: " + string( global.player_attack), 0.20,0.20, 0);
	draw_text_transformed(147, 84, "Armor: " + string( global.player_defense), 0.20,0.20, 0);
	
	var statscale = 0.25;
	
	var health_x = 15;
	
	var _htxt = (string(global.player_hp));
	var _hw = (string_width(_htxt)+110)*statscale;
	
	draw_sprite_stretched(spr_stats, 0, health_x-3, 9, _hw, 22);
	draw_sprite(spr_health, 0, health_x, 12);
	draw_text_transformed(health_x+18, 13,string( global.player_hp), statscale, statscale, 0);
	
	var gold_x = 60;
	
	var _gtxt = (string(global.player_gold));
	var _gw = (string_width(_gtxt)+110)*statscale;
	
	draw_sprite_stretched(spr_stats, 0, gold_x-3, 9, _gw, 22);
	draw_sprite(spr_gold_stack, 0, gold_x, 12);
	draw_text_transformed(gold_x+18, 13,string(global.player_gold), statscale, statscale, 0);


	for (var i = 0; i < max_inv_length; i++)
	{
		var xx = 17+ _xx +(i mod rowLength) * 20 +1;
		var yy = -1 + _yy +(i div rowLength) * 20 +1;
		draw_sprite(spr_inventory_slot, 0, xx, yy);
	}
	for (var i = 0; i < array_length(inv); i++)
	{
		var xx = 17+ _xx +(i mod rowLength) * 20 + 2;
		var yy = -1 + _yy +(i div rowLength) * 20 + 2;
		draw_sprite(inv[i].icon, 0, xx, yy);
	}

	draw_sprite(spr_helmet_slot, 0, 316, 59);
	draw_sprite(spr_chestplate_slot, 0, 316, 79);
	draw_sprite(spr_bottom_slot, 0, 316, 99);
	
	draw_sprite(spr_shield_slot, 0, 316, 179);
	draw_sprite(spr_weapon_slot, 0, 316, 199);
	
	if (equipped[0] != undefined) draw_sprite(equipped[0].icon, 0, 317, 60);
	if (equipped[1] != undefined) draw_sprite(equipped[1].icon, 0, 317, 80);
	if (equipped[2] != undefined) draw_sprite(equipped[2].icon, 0, 317, 100);
	if (equipped[3] != undefined) draw_sprite(equipped[3].icon, 0, 317, 180);
	if (equipped[4] != undefined) draw_sprite(equipped[4].icon, 0, 317, 200);
	
	for (var i = 0; i < max_inv_length; i++)
	{
		var xx = 17+ _xx +(i mod rowLength) * 20 +1;
		var yy = -1 + _yy +(i div rowLength) * 20 +1;
		if posx == i
		{
			draw_sprite(spr_inventory_hover, 0, xx+1, yy+1);
			for (var a = 0; a < array_length(inv); a++)
			{
				if posx == a
				{
					var _c = c_white
					if inv[i].rarity == "common"
					{
						_c = common_color;
					}
					else if inv[i].rarity == "rare"
					{
						_c = rare_color;
					}
					else if inv[i].rarity == "epic"
					{
						_c = epic_color;
					}
					
					font_enable_effects(textfont, true, {
						outlineEnable: true,
						outlineColour: c_black,
					});
					draw_text_transformed_colour(name_x+ 3, name_y, inv[a].name, 0.5,0.5, 0, _c,_c,_c,_c, 1);
					draw_text_transformed(info_x, info_y , inv[a].description, 0.25,0.25, 0);
					font_enable_effects(textfont,false)
				}
			}
		}
	}
}