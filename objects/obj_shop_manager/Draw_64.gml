draw_sprite(background, 0, 0, 0);

draw_set_font(textfont);
draw_set_halign(fa_left)
draw_set_valign(fa_top);

var _xx = 0;
var statscale = 0.25;
var gold_x = 10;
	
var _gtxt = (string(global.player_gold));
var _gw = (string_width(_gtxt)+110)*statscale;
	
draw_sprite_stretched(spr_stats, 0, gold_x-3, 9, _gw, 22);
draw_sprite(spr_gold_stack, 0, gold_x, 12);
draw_text_transformed(gold_x+18, 13,string(global.player_gold), statscale, statscale, 0);


for (var i = 0; i < tab_length; i++)
{
	var _tabW = (string_width(tabs[i])+75)*statscale;
	var xx = _xx + (i mod tabs_margin) * 50;
	
	var is_selected = (pos == i);
	var _tabH = is_selected ? 19 : 16;
    var _c = is_selected ? c_yellow : c_white;
	
	draw_sprite_stretched(spr_tabs, 0, tabs_x+xx,tabs_y, _tabW, _tabH);
	draw_text_transformed_colour(tabs_x+tabs_text_padding+xx, tabs_y+1, tabs[i], statscale, statscale, 0, _c,_c,_c,_c, 1);
}

