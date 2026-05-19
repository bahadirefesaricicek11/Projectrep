display_set_gui_size(384,216);

textfont = font_add("Project_Font_Better.ttf",24,false,false,32,128);
font_enable_sdf(textfont, true)

background = spr_shop_background;
deck = spr_shop_deck

obj_player.can_move = false;

tabs_x = 16;
tabs_y = 80;
tabs_margin = 50;
tabs_text_padding = 35;

items_x = 20;
items_y = 110;

info_x = 300;
info_y = 120;

pos = 0;

tabs[0] = "Buy";
tabs[1] = "Talk";
tabs[2] = "Map";

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
