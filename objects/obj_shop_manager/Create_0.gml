textfont = font_add("Project_Font_Better.ttf",24,false,false,32,128);
font_enable_sdf(textfont, true)

background = spr_shop_background;
deck = spr_shop_deck

obj_player.can_move = false;

tabs_x = 16;
tabs_y = 80;
tabs_margin = 50;
tabs_text_padding = 35;

content_x = 15;
content_y = 110;

info_text_x = 305; 
info_text_y = 122;
pos = 0;

tabs[0] = "Buy";
tabs[1] = "Talk";
tabs[2] = "Map";

map_scale = 0.5;

menu_x = 40;
menu_y = 60;

talk_options = ["Ask about items", "Ask about town", "Goodbye"];
shopkeeper_response = "Welcome to my shop, traveler!";
talk_pos = 0;

tab_length = array_length(tabs);

menu_state = "TABS";
sub_pos = 0;

confirm_pos = 0;

buy_confirm_pos = 0;

shop_items = [
    global.item_list.apple,
    global.item_list.bread,
    global.item_list.hamburger,
];
