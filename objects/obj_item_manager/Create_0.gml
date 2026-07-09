/// @description Initialize Inventory Layout & Trackers

depth = -9999;
inv_open = false;

// UI Text & Font Assets
textfont = font_add("Project_Font_Simple.ttf", 50, false, false, 32, 9830);
font_enable_sdf(textfont, true);

// Screen Coordinates
name_x = 16;
name_y = 230;
info_x = 394;
info_y = 16;

sep = 20;
sepx = 18;
_x = 192;
_y = 59;
rowLength = 4;

// Constraints & Trackers
max_inv_length = 32;
max_equipped_length = 5;
selected_item = -1;
posx = 0;
selected_option = 0;

// Runtime Tracking Arrays
inv = array_create(0);
inv_length = array_length(inv);
inv_full = false;

equipped = [undefined, undefined, undefined, undefined, undefined];