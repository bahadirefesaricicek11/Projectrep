#macro UI_BOX_PADDING 20
#macro UI_COL_WIDTH 160
#macro UI_LINE_HEIGHT 20
#macro UI_TEXT_SCALE 0.60

// Global Game State Enums
enum BATTLE_STATE {
    PLAYER_INPUT,
    TURN_SORTING,
    ENEMY_INPUT,
    ACTION_EXECUTION
}

enum BATTLE_MENU
{
    MAIN,
    TARGET_SELECT,
    INTERACT,
    TAKE_ACTION,
    ITEM_USE,
    ITEM_TARGET_SELECT
}

function battle_system_init() {
    global.card_pool = [
        { 
            name: "Warrior's Will", 
            buff_type: "atk", 
            value: 5,  
            desc: "+5 ATK for this battle",
            icon_sprite: spr_card_icons, 
            icon_frame: 1               
        },
        { 
            name: "Iron Wall",      
            buff_type: "def", 
            value: 3,  
            desc: "+3 DEF for this battle",
            icon_sprite: spr_card_icons,
            icon_frame: 0               
        },
        { 
            name: "Swift Wind",     
            buff_type: "spd", 
            value: 4,  
            desc: "+4 SPD for this battle",
            icon_sprite: spr_card_icons,
            icon_frame: 18              
        },
        { 
            name: "Titan's Blood",  
            buff_type: "max_hp", 
            value: 20, 
            desc: "+20 Max HP for this battle",
            icon_sprite: spr_card_icons,
            icon_frame: 3               
        }
    ];

    global.selected_cards = []; 
    global.active_battle_enemies = [];
    global.overworld_room = noone; 
    
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
}

function battle_trigger_room_transition(_enemy_id_array) {
    global.battle_spawn_queue = _enemy_id_array;
    global.overworld_room = room; 
    
    global.saved_gui_w = display_get_gui_width();
    global.saved_gui_h = display_get_gui_height();
    
    display_set_gui_size(384, 216);
    
    // Switch rooms immediately when called by Phase 2 of the transition object
    room_goto(rm_battle); 
}

function battle_setup_card_selection() {
    global.state = GAME_STATE.CARD_SELECTION;
    global.selected_cards = [];
    
    var _pool_size = array_length(global.card_pool);
    var _temp_pool = array_create(_pool_size);
    array_copy(_temp_pool, 0, global.card_pool, 0, _pool_size);
    
    // Shuffle the deck pool
    _temp_pool = array_shuffle(_temp_pool);
    
    // Select 3 cards, passing down explicit drawing parameters directly
    var _cards_to_select = min(3, _pool_size);
    for (var _i = 0; _i < _cards_to_select; _i++) {
        var _base_card = _temp_pool[_i];
        
        array_push(global.selected_cards, {
            card_info: _base_card,
            is_revealed: false,
            x: 0, 
            y: 0, 
            width: 76,              // Synchronized directly with Draw GUI properties
            height: 120,            // Synchronized directly with Draw GUI properties
            icon_sprite: _base_card.icon_sprite,
            icon_frame: _base_card.icon_frame
        });
    }
}

function battle_apply_card_buff(_card_info) {
    // Structural fix: Changed to incremental additions (+=) to protect existing buffs
    if (_card_info.buff_type == "atk")    global.battle_buff_atk += _card_info.value;
    if (_card_info.buff_type == "def")    global.battle_buff_def += _card_info.value;
    if (_card_info.buff_type == "spd")    global.battle_buff_spd += _card_info.value;
    if (_card_info.buff_type == "max_hp") global.battle_buff_max_hp += _card_info.value;
    
    global.selected_cards = [];
    global.state = GAME_STATE.BATTLE;
    
    // Signal battle initialization inside the arena
    with (obj_battle_controller) {
        event_user(0); 
    }
}

function battle_cleanup_and_return() {
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
    
    // Clear structural memory records
    global.selected_cards = [];
    global.active_battle_enemies = [];
    if (variable_global_exists("battle_spawn_queue")) {
        global.battle_spawn_queue = [];
    }
    
    global.state = GAME_STATE.PLAYING;
    
    // Restore original resolution scale matrix
    if (variable_global_exists("saved_gui_w") && global.saved_gui_w > 0) {
        display_set_gui_size(global.saved_gui_w, global.saved_gui_h);
    }
    
    // Return safely to overworld room map coordinate
    if (room_exists(global.overworld_room)) {
        room_goto(global.overworld_room);
    }
}

function battle_generate_party(_encounter_key) {
    // Fallback security check
    if (!variable_global_exists("encounter_database") || !variable_struct_exists(global.encounter_database, _encounter_key)) {
        return ["slime"]; // Emergency fallback so your game doesn't crash
    }
    
    var _data = variable_struct_get(global.encounter_database, _encounter_key);
    var _roll = irandom_range(1, _data.weight_total);
    var _current_weight = 0;
    
    // Loop through the pool options to see which one the roll lands on
    var _pool_count = array_length(_data.pools);
    for (var _i = 0; _i < _pool_count; _i++) {
        var _option = _data.pools[_i];
        _current_weight += _option.weight;
        
        if (_roll <= _current_weight) {
            return _option.enemies; // Returns the selected array (e.g., ["slime", "slime", "slime"])
        }
    }
    
    return ["slime"]; 
}