#macro FACE_UP 0
#macro FACE_LEFT 1
#macro FACE_RIGHT 2
#macro FACE_DOWN 3

global.date = 0;
global.ingame = false;

global.dialogue = 0;

global.view_width = display_get_gui_width();
global.view_height = display_get_gui_height();

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
