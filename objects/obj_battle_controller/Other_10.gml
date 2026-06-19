/// @description Structural Routing Engine: Spawning & Queue Intercept

if (global.state == GAME_STATE.BATTLE && menu_stage == BATTLE_MENU.HIT_BAR) {
    
    // --- MODE A: BUILD ARBITRATION STRUCT NODE FOR COMBAT ---
    var _act = {
        actor_type:   "PARTY",
        actor_index:  party_input_index,
        spd:          party_members[party_input_index].spd,
        action_type:  "FIGHT",
        target_index: targeted_enemy_index,
        multiplier:   hit_bar_multiplier,
        verdict:      hit_bar_verdict
    };
    
    // Push choice structural package into sequence array
    array_push(turn_queue, _act);
    
    // Cycle menu pointer forward
    party_input_index++;
    if (party_input_index >= party_max_members) {
        battle_sub_state = BATTLE_STATE.TURN_SORTING;
    } else {
        menu_stage = BATTLE_MENU.MAIN;
        menu_cursor = 0;
    }
} 
else {
    // --- MODE B: ARENA SETUP & DATABASE INITIALIZATION ---
    global.active_battle_enemies = [];

    if (variable_global_exists("battle_spawn_queue") && is_array(global.battle_spawn_queue)) {
        var _count = array_length(global.battle_spawn_queue);
        var _enemy_object_id = asset_get_index("obj_battle_enemy_placeholder");
        
        if (_enemy_object_id == -1) {
            show_debug_message("CRITICAL ERROR: 'obj_battle_enemy_placeholder' asset missing from Asset Browser!");
            exit; 
        }
        
        // Calibrate layout anchors for 384x216 screen profile
        var _base_x = 280; // Anchor position on the right side
        var _base_y = 60;  // Top boundary anchor
        var _spacing = 45; // Vertical separation between enemy rows

        for (var _i = 0; _i < _count; _i++) {
            var _enemy_key = global.battle_spawn_queue[_i];
            
            if (variable_global_exists("enemy_database") && variable_struct_exists(global.enemy_database, _enemy_key)) {
                var _blueprint = variable_struct_get(global.enemy_database, _enemy_key);
                
                // Spread enemies vertically based on their index position
                var _spawn_x = _base_x + (_i * 10); // Slight diagonal stagger style
                var _spawn_y = _base_y + (_i * _spacing);
                
                var _new_enemy = instance_create_layer(_spawn_x, _spawn_y, "Instances", _enemy_object_id);
                
                _new_enemy.name         = _blueprint.name;
                _new_enemy.hp           = _blueprint.hp;
                _new_enemy.max_hp       = _blueprint.max_hp;
                _new_enemy.atk          = variable_struct_exists(_blueprint, "atk") ? _blueprint.atk : 10;
                _new_enemy.def          = variable_struct_exists(_blueprint, "def") ? _blueprint.def : 0;
                _new_enemy.spd          = variable_struct_exists(_blueprint, "spd") ? _blueprint.spd : 8;
                _new_enemy.sprite       = _blueprint.sprite; 
                _new_enemy.sprite_index = _blueprint.sprite; 
                _new_enemy.image_index  = 0;                 
                
                array_push(global.active_battle_enemies, _new_enemy);
            } else {
                show_debug_message("BATTLE SETUP WARNING: Key '" + string(_enemy_key) + "' not found in global.enemy_database!");
            }
        }
    }
}