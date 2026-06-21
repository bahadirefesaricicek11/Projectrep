// Clear out whatever static array initialization you had before
party_members = [];

/// Inside obj_battle_controller (e.g., Create Event or Setup Script)

// Hardcoded positions for up to 3 party members on screen
// Matches your low-resolution presentation window baseline
party_battle_positions = [
    { x: 75,  y: 55 }, // Slot 0: Main Player
    { x: 75,  y: 105  }, // Slot 1: Follower Ally 1
    { x: 75,  y: 155 }  // Slot 2: Follower Ally 2
];

// Loop through your player's active party and spawn their battle visuals
var _party_count = array_length(obj_player.party_allies);
for (var i = 0; i < _party_count; i++) {
    // If you use an object to draw party sprites in battle:
    var _pos = party_positions[i];
    var _ally_visual = instance_create_depth(_pos.x, _pos.y, 0, obj_battle_party_member);
    _ally_visual.party_index = i; // Link visual object to the stats array index
}


// 1. DOCK THE PLAYER INTO THE BATTLE ENGINE SLOTS USING THE NEW GLOBAL METRICS
array_push(party_members, {
    name: global.player_name,
    hp: global.player_hp,
    max_hp: global.player_hp_max,
    display_hp: global.player_hp, // Hook directly to your odometer rolling engine
    atk: global.player_attack,
    def: global.player_defense,
    spd: 10, // Add a fallback speed or define global.player_speed if you have one
    is_defending: false,
    chosen_hit_multiplier: 1.0,
    chosen_hit_verdict: ""
});

// 2. DYNAMICALLY PARSE ALLIES (Only if they are registered)
// We wrap this in a safe instance check. If obj_player doesn't exist or party_allies is empty,
// party_max_members will safely fall back to 1 (Player solo).
if (instance_exists(obj_player) && variable_instance_exists(obj_player, "party_allies")) {
    var _ally_count = array_length(obj_player.party_allies);
    for (var _i = 0; _i < _ally_count; _i++) {
        var _ally_data = obj_player.party_allies[_i];
        array_push(party_members, {
            name: _ally_data.name,
            hp: _ally_data.hp,
            max_hp: _ally_data.max_hp,
            display_hp: _ally_data.hp,
            atk: _ally_data.atk,
            def: _ally_data.def,
            spd: _ally_data.spd,
            is_defending: false,
            chosen_hit_multiplier: 1.0,
            chosen_hit_verdict: ""
        });
    }
}

// Recalculate turn limits based on the actual populated array count
party_max_members = array_length(party_members);

// --- 2. STATUS EFFECT & CARD SELECTION TRACKERS ---
// Tracks the buff structure data applied to each character's HUD slot
global.active_combat_buffs = [];
for (var _i = 0; _i < party_max_members; _i++) {
    global.active_combat_buffs[_i] = noone;
}

party_input_index = 0; // Tracks which character is picking cards/actions
card_cursor       = 0; // Highlight position on the 3 draft cards

// --- 3. VISUAL HUD ASSET ASSIGNMENTS ---
background    = bg_battle;     
battle_font   = Project_Font;       
box_sprite    = spr_box;           
option_sprite = spr_option_btn;    

// Run this ONLY when transitioning into the Target Selection menu state:
menu_stage = BATTLE_MENU.TARGET_SELECT;
menu_cursor = 0;

// Populate it safely now that the battle is active and enemies exist!
if (variable_global_exists("active_battle_enemies")) {
    _options_array = global.active_battle_enemies;
    _total_options = array_length(global.active_battle_enemies);
} else {
    _options_array = [];
    _total_options = 0;
}

// Pre-defined static sub-menu options
interact_options    = ["Check", "Taunt", "Talk"];
take_action_options = ["Defend", "Flee", "Charge"];

menu_context         = "fight";     // "fight", "interact", or "item"
selected_sub_action  = "";          // Holds string names of sub-menus
targeted_enemy_index = -1;         // Target window array index
pending_item         = undefined;

// --- 5. TRANSIENT COMBAT TEXT POPUPS ---
popup_numbers = [];
popup_list = []; // Guarantees the array exists on frame 1

// --- 6. REAL-TIME HIT BAR ENGINE (DELTARUNE STYLE) ---
hit_bar_active     = false;
hit_bar_progress   = 0.0;       // Starts at 1.0 (far right) and drops towards 0.0 (far left)
hit_bar_speed      = 0.02;      // Alter the difficulty speed window ticker
hit_bar_target     = 0.25;      // Sweet spot target pixel location
hit_bar_multiplier = 0;        // Damage scale output
hit_bar_verdict    = "";        // Display text overhead ("MISS", "GOOD", "PERFECT!")

// --- 7. TURN PROCESSING & TIMERS ---
battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
turn_queue       = [];        
current_turn_act = noone;    
action_timer     = 0;        
battle_text      = "";      
text_char_count  = 0;

// --- 8. CARD ANIMATION & TRANSITION FLIGHT PATHS ---
card_intro_timer   = 0;        // Entrance linear interpolation weight slider
card_reveal_timer  = -1;       // Auto-dismissal look counter (-1 means idle)
card_flip_angle    = 180;      // Starts at 180 (back card face) down to 0 (face)
card_choice_locked = false;    // Safety block while choices transition
screenshake_amount = 0;

card_exit_phase    = false;    
card_exit_timer    = 0;        
card_exit_duration = 20;    

transition_timer    = 0;
transition_duration = 50;      // Fight arc flight duration (~0.83s)
in_card_transition  = false; 

chosen_card_start_x = 0;
chosen_card_start_y = 0;
chosen_card_angle   = 0;       // Rotation skew modifier during flight path

// --- 9. GLOBAL BACKEND PROTECTION & DECK POOL DRAFT SETUP ---
if (!variable_global_exists("state")) {
    global.state = GAME_STATE.BATTLE;
}

// Ensure the active enemy tracking array is reset cleanly
global.active_battle_enemies = [];

/* STRUCTURAL FIX: If your overworld engine passes raw object IDs rather than live instances,
  we read them here. For testing/fallback, we populate a default setup if empty.
*/
if (array_length(global.active_battle_enemies) == 0) {
    // Replace these placeholder object names with your actual enemy object asset names!
    var _enemy_spawn_pool = [obj_slime, obj_slime]; 
    
    var _spawn_layer = "Instances";
    if (!layer_exists(_spawn_layer)) {
        _spawn_layer = layer_create(-100, "Battle_Enemies");
    }
    
    for (var _i = 0; _i < array_length(_enemy_spawn_pool); _i++) {
        // Position layout coordinates matching a native 384x216 screen aspect ratio
        var _spawn_x = 280; 
        var _spawn_y = 60 + (_i * 45);
        
        // Physically instantiate the enemy inside the current battle arena room
        var _live_enemy = instance_create_layer(_spawn_x, _spawn_y, _spawn_layer, _enemy_spawn_pool[_i]);
        
        // Inject a safety check to ensure it has required properties initialized
        if (instance_exists(_live_enemy)) {
            if (!variable_instance_exists(_live_enemy, "hp"))  _live_enemy.hp = 50;
            if (!variable_instance_exists(_live_enemy, "max_hp")) _live_enemy.max_hp = 50;
            if (!variable_instance_exists(_live_enemy, "atk")) _live_enemy.atk = 8;
            if (!variable_instance_exists(_live_enemy, "def")) _live_enemy.def = 3;
            if (!variable_instance_exists(_live_enemy, "spd")) _live_enemy.spd = 10;
            if (!variable_instance_exists(_live_enemy, "name")) _live_enemy.name = "Enemy " + string(_i + 1);
            
            // Push the direct, valid pointer into the global target array
            array_push(global.active_battle_enemies, _live_enemy);
        }
    }
}

// --- ORIGINAL DECK DRAFT LOGIC CONTINUES UNCHANGED ---
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