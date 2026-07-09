load_settings();

is_ingame = (room != rm_menuRoom);

if (is_ingame && instance_exists(obj_player)) {
    obj_player.can_move = false;
}

view_width = display_get_gui_width();
view_height = display_get_gui_height();

fade_alpha = 1;
fade_speed = is_ingame ? 0.05 : 0.01;
fade_active = true;
lerpAmt = 0.15;
xo = 0;

// Context-Specific Main Page
if (is_ingame) {
    ds_menu_main = create_menu_page(
        ["menu.resume",    menu_element_type.script_runner, function() { instance_destroy(); global.state = GAME_STATE.PLAYING;}],
        ["menu.save",      menu_element_type.script_runner, function() { save_game(); }],
        ["menu.options",   menu_element_type.page_transfer, menu_page.settings],
        ["menu.main_menu", menu_element_type.script_runner, function() { prompt_exit = true; }]
    );
} else {
    ds_menu_main = create_menu_page(
        ["menu.start",    menu_element_type.script_runner, scr_send_nameScreen],
        ["menu.load",     menu_element_type.script_runner, function() { load_game(); scr_text();}],
        ["menu.settings", menu_element_type.page_transfer, menu_page.settings],
        ["menu.quit",     menu_element_type.script_runner, scr_exit_game]
    );
}

// FIX 1: Linked the Language Sub-Page inside your Settings page
ds_menu_settings = create_menu_page(
    ["menu.audio",    menu_element_type.page_transfer, menu_page.audio],
    ["menu.graphics", menu_element_type.page_transfer, menu_page.graphics],
    ["menu.language", menu_element_type.page_transfer, menu_page.language], // Added navigation bridge
    ["menu.back",     menu_element_type.page_transfer, menu_page.main]
);

ds_menu_audio = create_menu_page(
    ["menu.master", menu_element_type.slider, scr_change_volume, global.vol_master, [0,1]],
    ["menu.sounds", menu_element_type.slider, scr_change_volume, global.vol_sfx,    [0,1]],
    ["menu.music",  menu_element_type.slider, scr_change_volume, global.vol_music,  [0,1]],
    ["menu.back",   menu_element_type.page_transfer, menu_page.settings]
);

ds_menu_graphics = create_menu_page(
    ["menu.fullscreen", menu_element_type.toggle, scr_change_window_mode, global.fullscreen, ["menu.windowed_label", "menu.fullscreen_label"]],
    ["menu.back",       menu_element_type.page_transfer, menu_page.settings]
);

if (!variable_global_exists("setting_language")) global.setting_language = 0; 

ds_menu_language = create_menu_page(
    ["menu.language_select", menu_element_type.toggle, scr_change_language, global.setting_language, ["menu.lang_en", "menu.lang_tr"]],
    ["menu.back",            menu_element_type.page_transfer, menu_page.settings]
);

page = 0;
menu_pages = [ds_menu_main, ds_menu_settings, ds_menu_audio, ds_menu_graphics, ds_menu_language];
for (var i = 0; i < array_length(menu_pages); i++) {
    menu_option[i] = 0;
}

// Unified Back Logic Mapping
menu_parent = [];
menu_parent[menu_page.main]     = -1; 
menu_parent[menu_page.settings] = menu_page.main;
menu_parent[menu_page.audio]    = menu_page.settings;
menu_parent[menu_page.graphics] = menu_page.settings;
menu_parent[menu_page.language] = menu_page.settings;

// In-game specific variables
prompt_exit = false;
prompt_option = 0;

inputting = false;
previous_menu_option = -1;

title_font = font_add("Project_Font_Simple.ttf", 25, false,
false, 0, 0);

if (!variable_global_exists("InputInitialized")) {
    global.InputInitialized = true;
}