load_settings();

// --- INITIALIZE BUTTON HINTS & LAYOUT STATES ---
if (!variable_global_exists("show_button_hints")) {
    global.show_button_hints = true; // Default to ON
}
// 0 = Xbox Col. BG, 1 = Xbox Col. Text, 2 = Xbox Standard, 3 = PS Colored, 4 = PS Standard
if (!variable_global_exists("prompt_gamepad_style")) global.prompt_gamepad_style = 0;

// 0 = WASD Icons, 1 = Arrow Key Icons
if (!variable_global_exists("prompt_kbd_movement"))  global.prompt_kbd_movement = 0; 

// 0 = ZXC Layout, 1 = Enter / Shift / E Layout
if (!variable_global_exists("prompt_kbd_action"))    global.prompt_kbd_action = 0;

grid_size = 8; 

// Movement speeds for X and Y axes
scroll_speed_x = 1.5;
scroll_speed_y = 1.0;

// Track the current offset positions
offset_x = 0;
offset_y = 0;

// obj_menu - Create Event

// 1. Remember if this menu was spawned during active gameplay
is_pause_menu = (global.state == GAME_STATE.PLAYING || global.state == GAME_STATE.MENU);

// 2. If it is a pause menu, transition the global state to MENU
if (is_pause_menu) {
    global.state = GAME_STATE.MENU;
}
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
        ["menu.load",      menu_element_type.script_runner, function() { load_game(); scr_text();}],
        ["menu.settings", menu_element_type.page_transfer, menu_page.settings],
        ["menu.quit",      menu_element_type.script_runner, scr_exit_game]
    );
}

// Settings page
ds_menu_settings = create_menu_page(
    ["menu.audio",    menu_element_type.page_transfer, menu_page.audio],
    ["menu.graphics", menu_element_type.page_transfer, menu_page.graphics],
    ["menu.language", menu_element_type.page_transfer, menu_page.language], 
    ["menu.back",     menu_element_type.page_transfer, menu_page.main]
);

ds_menu_audio = create_menu_page(
    ["menu.master", menu_element_type.slider, scr_change_volume, global.vol_master, [0,1]],
    ["menu.sounds", menu_element_type.slider, scr_change_volume, global.vol_sfx,    [0,1]],
    ["menu.music",  menu_element_type.slider, scr_change_volume, global.vol_music,  [0,1]],
    ["menu.back",   menu_element_type.page_transfer, menu_page.settings]
);

// The actual controls submenu containing the toggle setups
ds_menu_controls = create_menu_page(
    ["menu.gamepad_style", menu_element_type.shift, scr_change_prompt_gp_style, global.prompt_gamepad_style, ["Xbox (Col. BG)", "Xbox (Col. Text)", "Xbox (Standard)", "PS (Colored)", "PS (Standard)"]],
    ["menu.kbd_movement",  menu_element_type.toggle, scr_change_prompt_kbd_move, global.prompt_kbd_movement, ["WASD", "Arrows"]],
    ["menu.kbd_actions",   menu_element_type.toggle, scr_change_prompt_kbd_act,  global.prompt_kbd_action,   ["Z / X / C", "Enter / Shift / E"]],
    ["menu.back",          menu_element_type.page_transfer, menu_page.graphics] // Traces back to Graphics Page
);

// Declare graphics page grid variable
ds_menu_graphics = -1;

/// @desc Dynamically adds or removes the controls submenu transfer option in Graphics settings
rebuild_graphics_menu = function() {
    if (ds_exists(ds_menu_graphics, ds_type_grid)) {
        ds_grid_destroy(ds_menu_graphics);
    }
    
    if (global.show_button_hints) {
        // Build with the sub-page transfer button right below the toggle
        ds_menu_graphics = create_menu_page(
            ["menu.fullscreen",   menu_element_type.toggle, scr_change_window_mode, global.fullscreen, ["menu.windowed_label", "menu.fullscreen_label"]],
            ["menu.button_hints", menu_element_type.toggle, scr_change_button_hints, global.show_button_hints, ["menu.off", "menu.on"]],
            ["menu.btn_settings", menu_element_type.page_transfer, menu_page.controls], // PAGE TRANSFER SUBMENU!
            ["menu.back",         menu_element_type.page_transfer, menu_page.settings]
        );
    } else {
        // Build without the submenu option
        ds_menu_graphics = create_menu_page(
            ["menu.fullscreen",   menu_element_type.toggle, scr_change_window_mode, global.fullscreen, ["menu.windowed_label", "menu.fullscreen_label"]],
            ["menu.button_hints", menu_element_type.toggle, scr_change_button_hints, global.show_button_hints, ["menu.off", "menu.on"]],
            ["menu.back",         menu_element_type.page_transfer, menu_page.settings]
        );
    }
    
    // Push the fresh layout to your menu pages structure
    menu_pages[menu_page.graphics] = ds_menu_graphics;
}

// Perform the initial load of the graphics menu structure
rebuild_graphics_menu();

if (!variable_global_exists("setting_language")) global.setting_language = 0; 

ds_menu_language = create_menu_page(
    ["menu.language_select", menu_element_type.toggle, scr_change_language, global.setting_language, ["menu.lang_en", "menu.lang_tr"]],
    ["menu.back",            menu_element_type.page_transfer, menu_page.settings]
);

page = 0;

// Include your control submenu inside the global page array
menu_pages = [ds_menu_main, ds_menu_settings, ds_menu_audio, ds_menu_graphics, ds_menu_language, ds_menu_controls];
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
menu_parent[menu_page.controls] = menu_page.graphics; // Back goes up to Graphics

// In-game specific variables
prompt_exit = false;
prompt_option = 0;

inputting = false;
previous_menu_option = -1;

title_font = font_add("Project_Font_Simple.ttf", 25, false, false, 0, 0);

if (!variable_global_exists("InputInitialized")) {
    global.InputInitialized = true;
}