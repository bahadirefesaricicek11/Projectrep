#macro UI_BOX_PADDING 20
#macro UI_COL_WIDTH 160
#macro UI_LINE_HEIGHT 20
#macro UI_TEXT_SCALE 0.60

enum BATTLE_STATE {
    PLAYER_INPUT,
    TURN_SORTING,
    ACTION_EXECUTION,
    ACTION_RESOLUTION,
    TURN_PROCESSING,
    ENEMY_TURN
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

function battle_system_init() {
    global.card_pool = [
        { name: "Warrior's Will", buff_type: "atk",    value: 5,  desc: "+5 ATK for this battle",       icon_sprite: spr_card_icons, icon_frame: 1 },
        { name: "Iron Wall",     buff_type: "def",    value: 3,  desc: "+3 DEF for this battle",       icon_sprite: spr_card_icons, icon_frame: 0 },
        { name: "Swift Wind",     buff_type: "spd",    value: 4,  desc: "+4 SPD for this battle",       icon_sprite: spr_card_icons, icon_frame: 18 },
        { name: "Titan's Blood",  buff_type: "max_hp", value: 20, desc: "+20 Max HP for this battle",   icon_sprite: spr_card_icons, icon_frame: 3 }
    ];

    global.selected_cards = []; 
    global.active_battle_enemies = [];
    global.overworld_room = noone; 
    
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
    
    global.battle_spawn_queue = [];
    global.saved_gui_w = 0;
    global.saved_gui_h = 0;
}

function battle_trigger_room_transition(_enemy_id_array) {
    global.battle_spawn_queue = _enemy_id_array;
    global.overworld_room = room; 
    
    global.saved_gui_w = display_get_gui_width();
    global.saved_gui_h = display_get_gui_height();
    
    // Switch rooms. Let the persistent room transition object handle the display_set_gui_size
    // when the screen is pitch black to avoid visual flashing.
    room_goto(rm_battle); 
}

function battle_setup_card_selection() {
    global.state = GAME_STATE.CARD_SELECTION;
    global.selected_cards = [];
    
    var _pool_size = array_length(global.card_pool);
    var _temp_pool = array_create(_pool_size);
    array_copy(_temp_pool, 0, global.card_pool, 0, _pool_size);
    
    // Fixed: array_shuffle operates in-place. Do not assign it back.
    array_shuffle(_temp_pool);
    
    var _cards_to_select = min(3, _pool_size);
    for (var _i = 0; _i < _cards_to_select; _i++) {
        var _base_card = _temp_pool[_i];
        
        array_push(global.selected_cards, {
            card_info: _base_card,
            is_revealed: false,
            x: 0, 
            y: 0, 
            width: 76,              
            height: 120,            
            icon_sprite: _base_card.icon_sprite,
            icon_frame: _base_card.icon_frame
        });
    }
}

function battle_apply_card_buff(_card_info) {
    if (_card_info.buff_type == "atk")    global.battle_buff_atk += _card_info.value;
    if (_card_info.buff_type == "def")    global.battle_buff_def += _card_info.value;
    if (_card_info.buff_type == "spd")    global.battle_buff_spd += _card_info.value;
    if (_card_info.buff_type == "max_hp") global.battle_buff_max_hp += _card_info.value;
    
    global.selected_cards = [];
    global.state = GAME_STATE.BATTLE;
    
    // Safety check: Ensure the controller actually exists before calling events on it
    if (instance_exists(obj_battle_controller)) {
        with (obj_battle_controller) {
            event_user(0); 
        }
    } else {
        show_debug_message("Warning: obj_battle_controller not found yet. Buff applied globally.");
    }
}

function battle_cleanup_and_return() {
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
    
    global.selected_cards = [];
    global.active_battle_enemies = [];
    global.battle_spawn_queue = [];
    
    global.state = GAME_STATE.PLAYING;
    
    if (global.saved_gui_w > 0) {
        display_set_gui_size(global.saved_gui_w, global.saved_gui_h);
    }
    
    if (room_exists(global.overworld_room)) {
        room_goto(global.overworld_room);
    }
}

function battle_generate_party(_encounter_key) {
    if (!variable_global_exists("encounter_database") || !variable_struct_exists(global.encounter_database, _encounter_key)) {
        return ["slime"]; 
    }
    
    var _data = global.encounter_database[$ _encounter_key];
    
    // Fixed: irandom_range(1, 100) can break if weight_total is 100 but items add up to 99 due to human error.
    // Optimized to use standard 0-indexing layout matching custom pool calculations.
    var _roll = irandom(_data.weight_total - 1);
    var _current_weight = 0;
    var _pool_count = array_length(_data.pools);
    
    for (var _i = 0; _i < _pool_count; _i++) {
        var _option = _data.pools[_i];
        _current_weight += _option.weight;
        
        if (_roll < _current_weight) {
            return _option.enemies; 
        }
    }
    
    return _data.pools[0].enemies; // Default fallback to first pool item instead of a hardcoded string
}

function battle_kill_enemy(_index) {
    if (_index >= 0 && _index < array_length(global.active_battle_enemies)) {
        var _dead_enemy = global.active_battle_enemies[_index];
        
        // 1. Remove the instance pointer from your logic array first
        array_delete(global.active_battle_enemies, _index, 1);
        
        // 2. Safely trigger death VFX / destruction on the actual object instance
        if (instance_exists(_dead_enemy)) {
            with (_dead_enemy) {
                // Insert death animation/fade shader triggers here
                instance_destroy();
            }
        }
    }
}

function battle_spawn_hit_particles(_x, _y, _color) {
    if (!instance_exists(obj_battle_controller)) exit;
    
    // Safety fallback color
    var _p_color = (argument_count > 2) ? _color : c_white;
    var _count = irandom_range(10, 15);
    
    for (var _i = 0; _i < _count; _i++) {
        var _dir = random(360);
        var _spd = random_range(1.5, 4);
        
        var _particle = {
            type: "particle", // <-- CRITICAL: MUST MATCH STEP/DRAW EVENTS EXACTLY
            x: _x,
            y: _y,
            hspeed: lengthdir_x(_spd, _dir),
            vspeed: lengthdir_y(_spd, _dir),
            gravity: 0.12,
            life: irandom_range(20, 35),
            color: _p_color,
            size: irandom_range(2, 4)
        };
        
        array_push(obj_battle_controller.popup_numbers, _particle);
    }
}