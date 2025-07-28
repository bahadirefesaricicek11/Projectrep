global.game_pause = true;

global.view_width = camera_get_view_width(view_camera[0]) * 1.3;
global.view_height = camera_get_view_height(view_camera[0]) * 1.3;
display_set_gui_size(global.view_width, global.view_height);


lerpAmt = 0.15;
xo = 0;
menu_left_margin = 50;


// Menu Structure
enum menu_page {
    main,
    settings,
    audio,
    graphics
}

enum menu_element_type {
    script_runner,
    page_transfer,
    slider,
    shift,
    toggle
}

ds_menu_main = create_menu_page(
    ["START GAME", menu_element_type.script_runner, scr_start_game],
    ["LOAD GAME", menu_element_type.script_runner, scr_load_game],
    ["SETTINGS", menu_element_type.page_transfer, menu_page.settings],
    ["EXIT", menu_element_type.script_runner, scr_exit_game]
);

ds_menu_settings = create_menu_page(
    ["AUDIO", menu_element_type.page_transfer, menu_page.audio],
    ["GRAPHICS", menu_element_type.page_transfer, menu_page.graphics],
    ["BACK", menu_element_type.page_transfer, menu_page.main]
);

ds_menu_audio = create_menu_page(
    ["MASTER", menu_element_type.slider, scr_change_volume, 0.5, [0,1]],
    ["SOUNDS", menu_element_type.slider, scr_change_volume, 0.2, [0,1]],
    ["MUSIC", menu_element_type.slider, scr_change_volume, 1, [0,1]],
    ["BACK", menu_element_type.page_transfer, menu_page.settings]
);

ds_menu_graphics = create_menu_page(
    ["RESOLUTION", menu_element_type.shift, scr_change_resolution, 0, ["384x216", "768x432", "1152x648", "1536x864", "1920x1080"]],
    ["FULLSCREEN", menu_element_type.toggle, scr_change_window_mode, 1, ["FULLSCREEN", "WINDOWED"]],
    ["BACK", menu_element_type.page_transfer, menu_page.settings]
);


page = 0;
menu_pages = [ds_menu_main, ds_menu_settings, ds_menu_audio, ds_menu_graphics];
for (var i = 0; i < array_length(menu_pages); i++) {
    menu_option[i] = 0;
}

inputting = false;
previous_menu_option = -1;

title_font = font_add("Project_Font.ttf", 24, false, false, 0, 0);

if (!variable_global_exists("InputInitialized")) {
    global.InputInitialized = true;
}