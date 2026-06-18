/// @description Initialize Battle Controller Core

// --- 1. CORE STRUCTURAL PARTY STAT DATA ---
party_members = [
    { name: "Player",   hp: 100, max_hp: 100, display_hp: 100, atk: 12, def: 5, spd: 14, clover_leaves: 1, sprite: spr_player_battle_idle, img_idx: 0 },
    { name: "Ally 1",   hp: 80,  max_hp: 80,  display_hp: 80,  atk: 8,  def: 4, spd: 18, clover_leaves: 3, sprite: spr_npc,                 img_idx: 0 },
    { name: "Ally 2",   hp: 120, max_hp: 120, display_hp: 120, atk: 15, def: 8, spd: 8,  clover_leaves: 0, sprite: spr_npc_alternate,        img_idx: 0 }
];

party_input_index = 0; 
party_max_members = 3; 

// --- 2. VISUAL ASSET ASSIGNMENTS ---
background    = bg_battle;     
battle_font   = Project_Font;      
box_sprite    = spr_box;           
option_sprite = spr_option_btn;    

// --- 3. SELECTION CONTROL ENGINE (STATE DRIVEN) ---
menu_stage  = BATTLE_MENU.MAIN;  
menu_cursor = 0;      
card_cursor = 0;      

// Pre-defined static sub-menu options
interact_options    = ["Check", "Taunt", "Talk"];
take_action_options = ["Defend", "Flee", "Charge"];

// --- 4. TURN PROCESSING & ENGINE MANAGEMENT ---
battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
turn_queue       = [];        
current_turn_act = noone;    
action_timer     = 0;        
battle_text      = "";      

// --- CARD ANIMATION SYSTEM ---
card_intro_timer = 0;       // Tracks the entrance slide-in
card_reveal_timer = -1;     // Tracks the auto-dismissal countdown (-1 means idle)
card_flip_angle = 180;      // Starts at 180 (back of the card facing player)
card_choice_locked = false; // Tracks if choice is validated
screenshake_amount = 0;

// --- EXPANDED CARD EXIT ANIMATION ENGINE ---
card_exit_phase = false;    
card_exit_timer = 0;        
card_exit_duration = 20;    

// Transition state control
transition_timer = 0;
transition_duration = 50;   // Slightly extended for a dramatic arc finish (~0.83s)
in_card_transition = false; 

// Layout tracking for the chosen card's journey
chosen_card_start_x = 0;
chosen_card_start_y = 0;
chosen_card_angle   = 0;    // Added: Tracks dynamic lean angle during flight

pending_item = undefined;

// --- 6. FORCE REAL-TIME INITIALIZATION ---
if (!variable_global_exists("card_pool")) {
    battle_system_init();
} else {
    global.selected_cards = [];
    var _pool_size = array_length(global.card_pool);
    
    if (_pool_size > 0 && !variable_struct_exists(global.card_pool[0], "icon_sprite")) {
        battle_system_init();
    } else {
        repeat(3) {
            var _random_idx = irandom(_pool_size - 1);
            var _base_card  = global.card_pool[_random_idx];
            
            var _spawned_card = {
                is_revealed: false,
                x: 0,
                y: 0,
                icon_sprite: _base_card.icon_sprite,
                icon_frame:  _base_card.icon_frame,
                card_info:   _base_card
            };
            array_push(global.selected_cards, _spawned_card);
        }
    }
}