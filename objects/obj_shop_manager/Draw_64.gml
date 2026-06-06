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


//--- BUY TAB ---
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
		
    }
}

var _content_x = items_x;
var _content_y = items_y;
var statscale = 0.35;

// --- TALK TAB ---
if (pos == 1) {
    for (var i = 0; i < array_length(talk_options); i++) {
        var _is_selected = (menu_state == "TALK_SUB" && sub_pos == i);
        var _c = _is_selected ? c_yellow : c_white;
        var _txt = _is_selected ? "> " + talk_options[i] : talk_options[i];
        draw_text_transformed_colour(_content_x, _content_y + (i * 20), _txt, statscale, statscale, 0, _c, _c, _c, _c, 1);
    }
}

// --- MAP TAB ---
else if (pos == 2) {
    draw_text_transformed(_content_x, _content_y, "Current Location: Shop", statscale, statscale, 0);
    
    var _mx = _content_x + 20;
    var _my = _content_y + 30;
	//------------TURN THIS INTO A MINIMAP-------------------------------
	//------------TURN THIS INTO A MINIMAP-------------------------------
	//------------TURN THIS INTO A MINIMAP-------------------------------
	//------------TURN THIS INTO A MINIMAP-------------------------------
    draw_rectangle_colour(_mx, _my, _mx + 80, _my + 50, c_gray, c_gray, c_gray, c_gray, false);
    draw_circle_colour(_mx + 40, _my + 25, 4, c_yellow, c_yellow, false); // Player
}

// --- BUY TAB ---
else if (pos == 0) {
    // Your existing Buy tab loop remains here, 
    // it will now naturally sit in the same spot as Talk/Map
    var _item_count = array_length(shop_items);
    for (var j = 0; j < _item_count; j++) {
        // ... (your existing buy rendering code)
    }
}
// --- INFO TEXT ---
var _statscale = 0.3; 
var _max_width = 250;
var _line_sep = 50;

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _displayText = "";

// 1. Determine the text content
if (pos == 0) { // BUY TAB
    _displayText = (menu_state == "BUY_SUB") ? shop_items[sub_pos].description : "Buy some items.";
} 
else if (pos == 1) { // TALK TAB
    // Show the shopkeeper's response here
    _displayText = shopkeeper_response; 
} 
else if (pos == 2) { // MAP TAB
    _displayText = "You are currently inside the shop. The town exit is to the east.";
}

// 2. Draw the text with wrap and line height
// info_text_x/y should be the start point just under the "INFO" label
draw_text_ext_transformed(info_text_x, info_text_y, _displayText, _line_sep, _max_width, _statscale, _statscale, 0);

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