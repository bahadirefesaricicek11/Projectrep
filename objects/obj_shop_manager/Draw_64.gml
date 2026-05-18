draw_sprite(background, 0, 0, 0);

draw_set_font(textfont);
draw_set_halign(fa_left)
draw_set_valign(fa_top);

var statscale = 0.25;
var gold_x = 10;
	
var _gtxt = (string(global.player_gold));
var _gw = (string_width(_gtxt)+110)*statscale;
	
draw_sprite_stretched(spr_stats, 0, gold_x-3, 9, _gw, 22);
draw_sprite(spr_gold_stack, 0, gold_x, 12);
draw_text_transformed(gold_x+18, 13,string(global.player_gold), statscale, statscale, 0);



var _tab1W = (string_width(tabs[0])+75)*statscale;
draw_sprite_stretched(spr_box, 0, tabs_x,tabs_y, _tab1W, 16);
draw_text_transformed(tabs_x+tabs_text_padding, tabs_y+2, tabs[0], statscale, statscale, 0);

var _tab2W = (string_width(tabs[1])+75)*statscale;
draw_sprite_stretched(spr_box, 0, tabs_x+tabs_margin,tabs_y, _tab2W, 16);
draw_text_transformed(tabs_x+tabs_text_padding+tabs_margin, tabs_y+2, tabs[1], statscale, statscale, 0);

var _tab3W = (string_width(tabs[2])+75)*statscale;
draw_sprite_stretched(spr_box, 0, tabs_x+tabs_margin*2,tabs_y, _tab3W, 16);
draw_text_transformed(tabs_x+tabs_text_padding+tabs_margin*2, tabs_y+2, tabs[2], statscale, statscale, 0);