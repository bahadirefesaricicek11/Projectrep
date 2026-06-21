/// @description obj_battle_controller -> Room Start Event

if (room == rm_battle) {
    // Force native resolution scale matrices safely inside the target room
    display_set_gui_size(384, 216);
    
    // --- 1. DYNAMICALLY GENERATE PARTY MEMBERS ---
    party_members = [];

    // Push the Main Player using your new global metrics
    array_push(party_members, {
        name: global.player_name,
        hp: global.player_hp,
        max_hp: global.player_hp_max,
        display_hp: global.player_hp, // Hook directly to your odometer rolling engine
        atk: global.player_attack,
        def: global.player_defense,
        spd: 14, // Keep your preferred speed metric
        clover_leaves: 1,
        sprite: spr_player_battle_idle,
        img_idx: 0,
        chosen_action_type: "",
        chosen_sub_action: "",
        chosen_target_index: -1,
        is_defending: false
    });

    // Dynamically pull whatever allies are currently registered in the player object
    // If obj_player doesn't exist or party_allies is empty, no allies will be added!
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
                spd: variable_struct_exists(_ally_data, "spd") ? _ally_data.spd : 12,
                clover_leaves: variable_struct_exists(_ally_data, "clover_leaves") ? _ally_data.clover_leaves : 0,
                sprite: variable_struct_exists(_ally_data, "sprite") ? _ally_data.sprite : spr_npc,
                img_idx: 0,
                chosen_action_type: "",
                chosen_sub_action: "",
                chosen_target_index: -1,
                is_defending: false
            });
        }
    }

    // Recalculate turn limits based on the actual populated array count dynamically
    party_max_members = array_length(party_members); 


    // --- 2. CLEAR AND INSTANTIATE THE ARENA ENEMIES ---
    global.active_battle_enemies = [];

    if (variable_global_exists("battle_spawn_queue") && is_array(global.battle_spawn_queue)) {
        var _count = array_length(global.battle_spawn_queue);
        var _enemy_object_id = asset_get_index("obj_battle_enemy_placeholder");
        
        if (_enemy_object_id == -1) {
            show_debug_message("CRITICAL ERROR: 'obj_battle_enemy_placeholder' missing!");
            exit; 
        }
        
        var _base_x = 280; 
        var _base_y = 60;  
        var _spacing = 45; 

        for (var _i = 0; _i < _count; _i++) {
            var _enemy_key = global.battle_spawn_queue[_i];
            
            if (variable_global_exists("enemy_database") && variable_struct_exists(global.enemy_database, _enemy_key)) {
                var _blueprint = global.enemy_database[$ _enemy_key];
                
                var _spawn_x = _base_x + (_i * 10); 
                var _spawn_y = _base_y + (_i * _spacing);
                
                // Spawning inside Room Start ensures these instances land in rm_battle!
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
                _new_enemy.is_dead      = false; // Ensure this flag exists for the drawing safety engine
                
                array_push(global.active_battle_enemies, _new_enemy);
                show_debug_message("Arena Setup: Spawning " + _new_enemy.name + " at " + string(_spawn_x) + "," + string(_spawn_y));
            } else {
                show_debug_message("BATTLE SETUP WARNING: Key '" + string(_enemy_key) + "' not found in global.enemy_database!");
            }
        }
    }
    
    // Transition game state out of overworld management safely
    battle_setup_card_selection();
}