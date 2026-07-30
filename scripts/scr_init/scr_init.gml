#macro FACE_UP 0
#macro FACE_LEFT 1
#macro FACE_RIGHT 2
#macro FACE_DOWN 3

global.date = 0;
global.ingame = false;

global.dialogue = 0;

global.view_width = 384;
global.view_height = 216;

// --- 4. PERSISTENT SYSTEM CORE LIVE METRICS ---
global.state = GAME_STATE.TITLE_SCREEN;
global.active_battle_enemies = []; // Stores active combat instance IDs
global.overworld_room_fallback = room;

// Core Live Player Metrics (Read/Written by Save & Load and Battle resolution systems)
global.player_name = "Hero";
global.player_hp = 100;
global.player_max_hp = 100;
global.player_gold = 0;

// Save-File Migration Handlers
global.is_loading_save = false;
global.load_x = 0;
global.load_y = 0;
global.load_face = 0;

global.item_found = undefined;
global.item_found_name = "";

// 0 = Normal / Monochrome, 1 = Colored (Xbox Style), 2 = PlayStation Style
global.prompt_gamepad_style = 0; 

// 0 = WASD, 1 = Arrow Keys
global.prompt_kbd_movement = 0; 

// 0 = ZXC Layout, 1 = Enter/Shift/E Layout
global.prompt_kbd_action = 0;

// In obj_game_controller / Boot Object Create Event:
global.connected_gamepad_count = 0;
global.active_gamepad = -1;

// Perform an initial scan on startup
for (var i = 0; i < 12; i++) {
    if (gamepad_is_connected(i)) {
        global.connected_gamepad_count++;
        if (global.active_gamepad == -1) {
            global.active_gamepad = i;
        }
    }
}
