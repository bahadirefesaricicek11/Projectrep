/// @description Initialize Battle Controller Core Data

// --- 1. PERSISTENT PARTY & POSITION STORAGE ---
party_members = [];
party_max_members = 0;

// HP box column occupies roughly x:5 to x:107 (box is 102px wide) before any scaling.
// Formation pushed clear of that, with room to spare in a 384-wide room.
party_battle_positions = [
    { x: 160, y: 60  }, // Slot 0: Main Player
    { x: 200, y: 110 }, // Slot 1: Follower Ally 1
    { x: 200, y: 160 }  // Slot 2: Follower Ally 2
];


/// @desc Clean Scroller Initialization
bg_scroll_x = 0;
bg_scroll_y = 0;
bg_wiggle_timer = 0;

bg_scroll_sprite = spr_bg_icon_default;

// Pull the overworld room we just came from to determine the correct asset pattern
if (variable_global_exists("overworld_room_fallback")) {
    bg_color = battle_get_background_color();
    bg_scroll_sprite = battle_get_background_sprite();
} else {
    bg_scroll_sprite = spr_bg_icon_default;
	bg_color = make_color_rgb(20, 15, 35);
}

// --- 2. STATUS EFFECT & CARD SELECTION TRACKERS ---
global.active_combat_buffs = [];
party_input_index = 0; // Tracks which character is picking cards/actions
card_cursor       = 0; // Highlight position on the 3 draft cards

// --- 3. VISUAL HUD ASSET ASSIGNMENTS ---   
battle_font   = Project_Font;      
box_sprite    = spr_box;           
option_sprite = spr_option_btn;    

// --- 4. TARGET SELECTION & SUB-MENU ENGINE ---
menu_stage    = BATTLE_MENU.TARGET_SELECT;
menu_cursor   = 0;
_options_array = [];
_total_options = 0;

// Pre-defined structural options
interact_options    = ["Check", "Taunt", "Talk"];
take_action_options = ["Defend", "Flee", "Charge"];

menu_context         = "fight";     // "fight", "interact", or "item"
selected_sub_action  = "";          // Holds string names of sub-menus
targeted_enemy_index = -1;          // Target window array index
pending_item         = undefined;
item_choice_index_lock = -1;

// --- 5. TRANSIENT COMBAT TEXT POPUPS ---
popup_numbers = [];
popup_list = []; 

// --- 6. REAL-TIME HIT BAR ENGINE (DELTARUNE STYLE) ---
hit_bar_active     = false;
hit_bar_progress   = 0.0;       // Starts at 1.0 (far right) and drops towards 0.0 (far left)
hit_bar_speed      = 0.02;      // Alter the difficulty speed window ticker
hit_bar_target     = 0.25;      // Sweet spot target pixel location
hit_bar_multiplier = 0;         // Damage scale output
hit_bar_verdict    = "";        // Display text overhead ("MISS", "GOOD", "PERFECT!")

// --- 7. TURN PROCESSING & TIMERS ---
battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
turn_queue       = [];        
current_turn_act = noone;    
action_timer     = 0;        
battle_text      = "";      
text_char_count  = 0;

// --- 8. CARD ANIMATION & TRANSITION FLIGHT PATHS ---
card_intro_timer   = 0;         // Entrance linear interpolation weight slider
card_reveal_timer  = -1;        // Auto-dismissal look counter (-1 means idle)
card_flip_angle    = 180;       // Starts at 180 (back card face) down to 0 (face)
card_choice_locked = false;     // Safety block while choices transition
screenshake_amount = 0;

card_exit_phase    = false;    
card_exit_timer    = 0;        
card_exit_duration = 20;    

transition_timer    = 0;
transition_duration = 50;      // Fight arc flight duration (~0.83s)
in_card_transition  = false; 

chosen_card_start_x = 0;
chosen_card_start_y = 0;
chosen_card_angle   = 0;        // Rotation skew modifier during flight path

// --- 9. GLOBAL SYSTEM CONFIGURATION & REGISTRATION ---
if (!variable_global_exists("state")) {
    global.state = GAME_STATE.BATTLE;
}
global.active_battle_enemies = [];

// Fallback pool initialization for standard baseline deck drafts if missing
if (!variable_global_exists("card_pool")) {
    battle_system_init();
}

