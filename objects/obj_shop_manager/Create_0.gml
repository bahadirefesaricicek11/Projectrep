display_set_gui_size(384,216);

textfont = font_add("Project_Font_Better.ttf",24,false,false,32,128);
font_enable_sdf(textfont, true)

background = spr_shop_background;

obj_player.can_move = false;

tabs_x = 16;
tabs_y = 81;
tabs_margin = 50;
tabs_text_padding = 8;

tabs[3] = "";

tabs[0] = "Items";
tabs[1] = "Talk";
tabs[2] = "Map";

option = 0;



