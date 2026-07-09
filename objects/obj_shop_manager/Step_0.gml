right_key = InputPressed(INPUT_VERB.RIGHT);
left_key = InputPressed(INPUT_VERB.LEFT);
down_key = InputPressed(INPUT_VERB.DOWN);
up_key   = InputPressed(INPUT_VERB.UP);
accept_key = InputPressed(INPUT_VERB.ACCEPT);
cancel_key = InputPressed(INPUT_VERB.CANCEL);

var _l1 = InputPressed(INPUT_VERB.L1);
var _r1 = InputPressed(INPUT_VERB.R1);

if (menu_state != "BUY_CONFIRM" && menu_state != "LEAVE_CONFIRM") {
    if (_r1 || _l1) {
        if (_r1) pos++;
        if (_l1) pos--;
        
        if (pos >= tab_length) pos = 0;
        if (pos < 0) pos = tab_length - 1;
        
        if (pos == 0) { menu_state = "BUY_SUB"; sub_pos = 0; }
        else if (pos == 1) { menu_state = "TALK_SUB"; sub_pos = 0; }
        else if (pos == 2) { menu_state = "TABS";}
    }
}

if (menu_state == "TABS") {
    pos += right_key - left_key;
    if (pos >= tab_length) pos = 0;
    if (pos < 0) pos = tab_length - 1;
    
    if (down_key || accept_key) {
        if (pos == 0) { menu_state = "BUY_SUB"; sub_pos = 0; }
        else if (pos == 1) { menu_state = "TALK_SUB"; sub_pos = 0; }
    }
    
    if (cancel_key) {
        menu_state = "LEAVE_CONFIRM";
        confirm_pos = 1;
    }
}
else if (menu_state == "MAP_SUB") {
    if (cancel_key) menu_state = "TABS";
}
else if (menu_state == "TALK_SUB") {
    sub_pos += down_key - up_key;
    if (sub_pos >= array_length(talk_options)) sub_pos = 0;
    if (sub_pos < 0) sub_pos = array_length(talk_options) - 1;

    if (cancel_key) menu_state = "TABS";

	switch(sub_pos) {
		case 0: shopkeeper_response = "I sell only the finest quality goods."; break;
        case 1: shopkeeper_response = "It's a quiet town, but the roads are long."; break;
        case 2: shopkeeper_response = "Safe travels, friend!"; break;
    }
}
else if (menu_state == "BUY_SUB") {
    sub_pos += down_key - up_key;
    var _max_items = array_length(shop_items);
    if (sub_pos >= _max_items) sub_pos = 0;
    if (sub_pos < 0) sub_pos = _max_items - 1;
    
    if (cancel_key) menu_state = "TABS";
    
    if (accept_key) {
        menu_state = "BUY_CONFIRM";
        buy_confirm_pos = 0;
    }
}
else if (menu_state == "BUY_CONFIRM") {
    buy_confirm_pos += right_key - left_key;
    if (buy_confirm_pos > 1) buy_confirm_pos = 0;
    if (buy_confirm_pos < 0) buy_confirm_pos = 1;
    
    if (cancel_key) menu_state = "BUY_SUB";
    
    if (accept_key) {
        if (buy_confirm_pos == 0) {
            var _selected_item = shop_items[sub_pos];
            if (global.player_gold >= _selected_item.price) {
                global.player_gold -= _selected_item.price;
                item_add(_selected_item);
                menu_state = "BUY_SUB"; 
            } else {
                menu_state = "BUY_SUB";
            }
        } else {
            menu_state = "BUY_SUB";
        }
    }
}
else if (menu_state == "LEAVE_CONFIRM") {
    confirm_pos += right_key - left_key;
    if (confirm_pos > 1) confirm_pos = 0;
    if (confirm_pos < 0) confirm_pos = 1;
    
    if (cancel_key) menu_state = "TABS";
    
    if (accept_key) {
        if (confirm_pos == 0) {
            obj_player.can_move = true;
            room_goto(rm_outside);
            obj_player.x = 280;
            obj_player.y = 175;
            instance_destroy();
        } else {
            menu_state = "TABS";
        }
    }
}