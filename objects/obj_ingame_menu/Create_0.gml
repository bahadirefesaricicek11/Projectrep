if (instance_exists(obj_player)) {
    obj_player.can_move = false;
}

global.view_width = camera_get_view_width(view_camera[0]) * 1.3;
global.view_height = camera_get_view_height(view_camera[0]) * 1.3;
display_set_gui_size(global.view_width, global.view_height);

fade_alpha = 1;
fade_speed = 0.05;
fade_active = true;
lerpAmt = 0.15;
xo = 0;

ds_menu_main = create_menu_page(
    ["RESUME",       menu_element_type.script_runner, function() { instance_destroy(); }],
    ["SAVE GAME",    menu_element_type.script_runner, scr_save_game],
    ["OPTIONS",      menu_element_type.page_transfer, menu_page.settings],
    ["MAIN MENU",    menu_element_type.script_runner, function() { prompt_exit = true; }]
);

ds_menu_settings = create_menu_page(
    ["AUDIO",        menu_element_type.page_transfer, menu_page.audio],
    ["GRAPHICS",     menu_element_type.page_transfer, menu_page.graphics],
    ["GO BACK",      menu_element_type.page_transfer, menu_page.main]
);

ds_menu_audio = create_menu_page(
    ["MASTER",       menu_element_type.slider,        scr_change_volume, global.vol_master, [0,1]],
    ["SOUNDS",       menu_element_type.slider,        scr_change_volume, global.vol_sfx,    [0,1]],
    ["MUSIC",        menu_element_type.slider,        scr_change_volume, global.vol_music,  [0,1]],
    ["GO BACK",      menu_element_type.page_transfer, menu_page.settings]
);

var _fs_val = window_get_fullscreen() ? 0 : 1;
ds_menu_graphics = create_menu_page(
    ["FULLSCREEN",   menu_element_type.toggle,        scr_change_window_mode, _fs_val, ["FULLSCREEN", "WINDOWED"]],
    ["GO BACK",      menu_element_type.page_transfer, menu_page.settings]
);

page = menu_page.main;
menu_pages = [ds_menu_main, ds_menu_settings, ds_menu_audio, ds_menu_graphics];

for (var i = 0; i < array_length(menu_pages); i++) {
    menu_option[i] = 0;
}

menu_parent = [];
menu_parent[menu_page.main]     = -1; 
menu_parent[menu_page.settings] = menu_page.main;
menu_parent[menu_page.audio]    = menu_page.settings;
menu_parent[menu_page.graphics] = menu_page.settings;

prompt_exit = false;
prompt_option = 0;
inputting = false;
previous_menu_option = -1;

title_font = font_add("Project_Font.ttf", 24, false, false, 0, 0);