draw_sprite(background, 0, 0, 0);
draw_sprite(deck, 0, 0, 0);

draw_set_font(textfont);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var statscale = 0.25;

// --- DRAW GOLD DISPLAY ---
var gold_x = 10;
var _gtxt = string(global.player_gold);
var _gw = (string_width(_gtxt) + 110) * statscale;
    
draw_sprite_stretched(spr_stats, 0, gold_x - 3, 9, _gw, 22);
draw_sprite(spr_gold_stack, 0, gold_x, 12);
draw_text_transformed(gold_x + 18, 13, _gtxt, statscale, statscale, 0);


var current_tab_x = tabs_x;

for (var i = 0; i < tab_length; i++)
{
    var _tabW = (string_width(tabs[i]) + 75) * statscale;
    var is_selected = (pos == i);
    
    var _tabH = is_selected ? 19 : 16;
    var _tabY_offset = is_selected ? tabs_y - 3 : tabs_y; 
    var _c = is_selected ? c_yellow : c_white;
    
    draw_sprite_stretched(spr_tabs, 0, current_tab_x, _tabY_offset, _tabW, _tabH);
    draw_text_transformed_colour(current_tab_x + (tabs_text_padding * statscale), _tabY_offset + 2, tabs[i], statscale, statscale, 0, _c, _c, _c, _c, 1);
    
    current_tab_x += _tabW + 4;
}

if (pos == 0) {
    var _item_count = array_length(shop_items);
	var statscale = 0.35;
    
    for (var j = 0; j < _item_count; j++) {
        var _item_y = items_y + (j * 32);
        var _is_sub_selected = (menu_state == "BUY_SUB" && sub_pos == j);
        var _item_color = _is_sub_selected ? c_yellow : c_white;
        
        if (_is_sub_selected) {
            draw_text_transformed_colour(items_x - 10, _item_y, ">", statscale, statscale, 0, _item_color, _item_color, _item_color, _item_color, 1);
        }
        
        draw_text_transformed_colour(items_x, _item_y, shop_items[j].name, statscale, statscale, 0, _item_color, _item_color, _item_color, _item_color, 1);
        
        draw_text_transformed_colour(items_x + 150, _item_y, string(shop_items[j].price) + "G", statscale, statscale, 0, _item_color, _item_color, _item_color, _item_color, 1);
		
        var subtabs = menu_state == "BUY_SUB";
		var _itemText = subtabs ? string(shop_items[sub_pos].description) : "Welcome.";
		
		draw_text_transformed(info_x, info_y, _itemText , statscale, statscale, 0);
    }
}


if (menu_state == "BUY_CONFIRM") {
	var statscale = 0.25;
	
    var _box_w = 180;
    var _box_h = 65;
    var _box_x = (384 / 2) - (_box_w / 2);
    var _box_y = (216 / 2) - (_box_h / 2);
    
    draw_sprite_stretched(spr_box, 0, _box_x, _box_y, _box_w, _box_h);
    
    draw_set_halign(fa_center);
    
    var _current_item = shop_items[sub_pos];
    var _prompt_text = "Buy " + _current_item.name + " for " + string(_current_item.price) + "G?";
    
    draw_text_transformed_colour(_box_x + (_box_w / 2), _box_y + 12, _prompt_text, statscale, statscale, 0, c_white, c_white, c_white, c_white, 1);
    
    var _yes_x = _box_x + (_box_w / 3);
    var _no_x = _box_x + ((_box_w / 3) * 2);
    var _options_y = _box_y + 38;
    
    var _yes_color = (buy_confirm_pos == 0) ? c_yellow : c_white;
    var _no_color  = (buy_confirm_pos == 1) ? c_yellow : c_white;
    
    draw_text_transformed_colour(_yes_x, _options_y, "YES", statscale, statscale, 0, _yes_color, _yes_color, _yes_color, _yes_color, 1);
    draw_text_transformed_colour(_no_x, _options_y, "NO", statscale, statscale, 0, _no_color, _no_color, _no_color, _no_color, 1);
    
    if (buy_confirm_pos == 0) {
        draw_text_transformed_colour(_yes_x - 16, _options_y, ">", statscale, statscale, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
    } else {
        draw_text_transformed_colour(_no_x - 14, _options_y, ">", statscale, statscale, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
    }
    
    draw_set_halign(fa_left);
}


if (menu_state == "LEAVE_CONFIRM") {
	var statscale = 0.25;
    var _box_w = 160;
    var _box_h = 60;
    var _box_x = (384 / 2) - (_box_w / 2);
    var _box_y = (216 / 2) - (_box_h / 2);
   
    draw_sprite_stretched(spr_box, 0, _box_x, _box_y, _box_w, _box_h);
    
    draw_set_halign(fa_center);
    
    draw_text_transformed_colour(_box_x + (_box_w / 2), _box_y + 10, "Do you want to leave?", statscale, statscale, 0, c_white, c_white, c_white, c_white, 1);
    
    var _yes_x = _box_x + (_box_w / 3);
    var _no_x = _box_x + ((_box_w / 3) * 2);
    var _options_y = _box_y + 35;
    
    var _yes_color = (confirm_pos == 0) ? c_yellow : c_white;
    var _no_color  = (confirm_pos == 1) ? c_yellow : c_white;
    
    draw_text_transformed_colour(_yes_x, _options_y, "YES", statscale, statscale, 0, _yes_color, _yes_color, _yes_color, _yes_color, 1);
    draw_text_transformed_colour(_no_x, _options_y, "NO", statscale, statscale, 0, _no_color, _no_color, _no_color, _no_color, 1);
    
    if (confirm_pos == 0) {
        draw_text_transformed_colour(_yes_x - 16, _options_y, ">", statscale, statscale, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
    } else {
        draw_text_transformed_colour(_no_x - 14, _options_y, ">", statscale, statscale, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
    }
	
    draw_set_halign(fa_left);
}