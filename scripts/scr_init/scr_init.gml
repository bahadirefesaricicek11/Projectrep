#macro FACE_UP 0
#macro FACE_LEFT 1
#macro FACE_RIGHT 2
#macro FACE_DOWN 3

global.date = 0;
global.ingame = false;

global.dialogue = 0;

global.view_width = display_get_gui_width();
global.view_height = display_get_gui_height();


enum GAME_STATE {
    PLAYING,
    MENU,
    BATTLE,
    CARD_SELECTION,
    CUTSCENE,
    TITLE_SCREEN,
    GAMEOVER
}

enum BATTLE_STATE {
    PLAYER_INPUT,
    TURN_SORTING,
    ACTION_EXECUTION,
    ACTION_RESOLUTION,
    TURN_PROCESSING,
    ENEMY_TURN,
    VICTORY,
    GAMEOVER
}

enum BATTLE_MENU {
    MAIN,
    TARGET_SELECT,
    INTERACT,
    TAKE_ACTION,
    ITEM_USE,
    ITEM_TARGET_SELECT,
    HIT_BAR
}

enum ENEMY_AI {
    IDLE,
    WANDER,
    CHASE
}


global.enemy_database = {
    slime: {
        name: "Slime",
        max_hp: 30,
        atk: 12,
        def: 1,
        xp_value: 15,
        gold_value: 10,
        sprite: spr_slime
    },
    strong_slime: {
        name: "Strong Slime",
        max_hp: 50,
        atk: 18,
        def: 4,
        xp_value: 35,
        gold_value: 25,
        sprite: spr_slime_dad
    }
};

// --- 3. OVERWORLD ENCOUNTER COMPOSITIONS ---
global.encounter_database = {
    slime_easy: {
        weight_total: 100,
        pools: [
            { enemies: ["slime"],                 weight: 50 },
            { enemies: ["slime", "slime"],         weight: 35 },
            { enemies: ["slime", "slime", "slime"], weight: 15 }
        ]
    },
    forest_ambush: {
        weight_total: 100,
        pools: [
            { enemies: ["slime", "strong_slime"],         weight: 70 },
            { enemies: ["strong_slime", "strong_slime"], weight: 30 }
        ]
    }
};

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
