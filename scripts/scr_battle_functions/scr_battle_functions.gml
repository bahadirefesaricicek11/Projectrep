enum BATTLE_STATE {
    PLAYER_INPUT,    // Menu navigation (where you are right now)
    TURN_SORTING,    // Engine compares Speeds and creates the turn timeline
    ACTION_EXECUTE,  // Processing an action, displaying text, applying damage
    BATTLE_END       // Checking for win/loss conditions and cleaning up
}

function battle_system_init() {
    global.card_pool = [
        { name: "Warrior's Will", buff_type: "atk", value: 5,  desc: "+5 ATK for this battle" },
        { name: "Iron Wall",     buff_type: "def", value: 3,  desc: "+3 DEF for this battle" },
        { name: "Swift Wind",    buff_type: "spd", value: 4,  desc: "+4 SPD for this battle" },
        { name: "Titan's Blood",  buff_type: "max_hp", value: 20, desc: "+20 Max HP for this battle" }
    ];

    global.selected_cards = []; 
    global.active_battle_enemies = [];
    global.overworld_room = noone; // Caches the room we left behind
    
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
}

function battle_trigger_room_transition(_enemy_struct_array) {
    // 1. Cache current overworld state data
    global.active_battle_enemies = _enemy_struct_array;
    global.overworld_room = room; 
    
    // 2. Dynamically cache whatever your "weird" overworld GUI resolution is right now
    global.saved_gui_w = display_get_gui_width();
    global.saved_gui_h = display_get_gui_height();
    
    // 3. Force the GUI canvas to shrink down to pixel-perfect size for the battle room
    display_set_gui_size(384, 216);
    
    // 4. Move to dedicated battle space
    room_goto(rm_battle); 
}

function battle_setup_card_selection() {
    global.state = GAME_STATE.CARD_SELECTION;
    global.selected_cards = [];
    
    var _pool_size = array_length(global.card_pool);
    var _temp_pool = array_create(_pool_size);
    array_copy(_temp_pool, 0, global.card_pool, 0, _pool_size);
    _temp_pool = array_shuffle(_temp_pool);
    
    for (var _i = 0; _i < 3; _i++) {
        array_push(global.selected_cards, {
            card_info: _temp_pool[_i],
            is_revealed: false,
            x: 0, y: 0, width: 160, height: 240
        });
    }
}

function battle_apply_card_buff(_card_info) {
    global.battle_buff_atk = (_card_info.buff_type == "atk") ? _card_info.value : 0;
    global.battle_buff_def = (_card_info.buff_type == "def") ? _card_info.value : 0;
    global.battle_buff_spd = (_card_info.buff_type == "spd") ? _card_info.value : 0;
    global.battle_buff_max_hp = (_card_info.buff_type == "max_hp") ? _card_info.value : 0;
    
    global.selected_cards = [];
    global.state = GAME_STATE.BATTLE;
    
    // Tell battle controller to populate the combat layout
    with (obj_battle_controller) {
        event_user(0); 
    }
}

function battle_cleanup_and_return() {
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_spd = 0;
    global.battle_buff_max_hp = 0;
    global.selected_cards = [];
    global.active_battle_enemies = [];
    
    global.state = GAME_STATE.PLAYING;
    
    // Restore your old overworld GUI dimensions perfectly
    if (variable_global_exists("saved_gui_w") && global.saved_gui_w > 0) {
        display_set_gui_size(global.saved_gui_w, global.saved_gui_h);
    }
    
    // Return safely to cached overworld map
    if (room_exists(global.overworld_room)) {
        room_goto(global.overworld_room);
    }
}