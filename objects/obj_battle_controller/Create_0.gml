/// @description Initialize Battle Controller Core

// --- 1. CORE STRUCTURAL PARTY STAT DATA ---
party_members = [
    { name: "Player",   hp: 100, max_hp: 100, display_hp: 100, atk: 12, spd: 14, clover_leaves: 1, sprite: spr_player_battle_idle, img_idx: 0 },
    { name: "Ally 1",   hp: 80,  max_hp: 80,  display_hp: 80,  atk: 8,  spd: 18, clover_leaves: 3, sprite: spr_npc,                 img_idx: 0 },
    { name: "Ally 2",   hp: 120, max_hp: 120, display_hp: 120, atk: 15, spd: 8,  clover_leaves: 0, sprite: spr_npc_alternate,        img_idx: 0 }
];

party_input_index = 0; 
party_max_members = 3; 

// --- 2. VISUAL ASSET ASSIGNMENTS ---
background    = spr_battle_bg;     
battle_font   = Project_Font;      
box_sprite    = spr_box;           
option_sprite = spr_option_btn;    

// --- 3. SELECTION CONTROL ENGINE ---
menu_stage  = 0;      
menu_cursor = 0;      
card_cursor = 0;      

// --- 4. TURN PROCESSING & ENGINE MANAGEMENT ---
// REMOVED forced global.state switch here!
battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
turn_queue       = [];        
current_turn_act = noone;    
action_timer     = 0;        
battle_text      = "";      

// --- 5. UI ANIMATION & SCREEN FEEDBACK ENGINE ---
screenshake_amount   = 0;               
text_char_count     = 0;               
last_battle_text    = "";              
anim_timer          = 0; 

// --- 6. HEAVY INITIALIZATION ENGINE ---
if (!variable_global_exists("card_pool")) {
    battle_system_init();
}