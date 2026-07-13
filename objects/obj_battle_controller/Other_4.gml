/// @description Build Arena Entities & Populate Arrays

if (room == rm_battle) {
    
    // --- 1. DYNAMICALLY DOCK UNIFIED PARTY MODEL ---
    party_members = [];

    // Push Main Player with fully consolidated property profile
    array_push(party_members, {
        name: global.player_name,
        hp: global.player_hp,
        max_hp: global.player_hp_max,
        display_hp: global.player_hp, 
        atk: global.player_attack,
        def: global.player_defense,
        clover_leaves: 1,
        sprite: spr_player_battle_idle,
        img_idx: 0,
        chosen_action_type: "",
        chosen_sub_action: "",
        chosen_target_index: -1,
        is_defending: false,
        chosen_hit_multiplier: 1.0,
        chosen_hit_verdict: ""
    });

    // Dynamically pull whatever tracking allies are actively registered inside obj_player
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "party_allies")) {
        var _ally_count = array_length(obj_player.party_allies);
        for (var _i = 0; _i < _ally_count; _i++) {
            var _ally_data = obj_player.party_allies[_i];
            
            // --- PROTECTED COMBAT STAT ASSIGNMENTS ---
            // Fall back to safe baseline numbers if variables are completely missing (e.g. freshly loaded saves)
            var _name   = variable_struct_exists(_ally_data, "name")   ? _ally_data.name   : "Ally";
            var _hp     = variable_struct_exists(_ally_data, "hp")     ? _ally_data.hp     : 100;
            var _max_hp = variable_struct_exists(_ally_data, "max_hp") ? _ally_data.max_hp : 100;
            var _atk    = variable_struct_exists(_ally_data, "atk")    ? _ally_data.atk    : 10;
            var _def    = variable_struct_exists(_ally_data, "def")    ? _ally_data.def    : 5;
            
            array_push(party_members, {
                name: _name,
                hp: _hp,
                max_hp: _max_hp,
                display_hp: _hp,
                atk: _atk,
                def: _def,
                clover_leaves: variable_struct_exists(_ally_data, "clover_leaves") ? _ally_data.clover_leaves : 0,
                sprite: variable_struct_exists(_ally_data, "sprite") ? _ally_data.sprite : spr_npc_portrait,
                img_idx: 0,
                chosen_action_type: "",
                chosen_sub_action: "",
                chosen_target_index: -1,
                is_defending: false,
                chosen_hit_multiplier: 1.0,
                chosen_hit_verdict: ""
            });
        }
    }

    // Capture exact size configuration definitions 
    party_max_members = array_length(party_members); 

    // Reset status tracker arrays to match dynamic layout width
    global.active_combat_buffs = [];
    for (var _i = 0; _i < party_max_members; _i++) {
        global.active_combat_buffs[_i] = noone;
    }

    // --- 2. SPAWN PARTY MEMBER VISUAL INSTANCES SAFELY ---
    var _party_obj_id = asset_get_index("obj_battle_party_member");
    
    if (_party_obj_id != -1) {
        if (instance_exists(_party_obj_id)) {
            with (_party_obj_id) instance_destroy();
        }

        for (var _i = 0; _i < party_max_members; _i++) {
            if (_i < array_length(party_battle_positions)) {
                var _pos = party_battle_positions[_i];
                var _ally_visual = instance_create_depth(_pos.x, _pos.y, 0, _party_obj_id);
                if (instance_exists(_ally_visual)) {
                    _ally_visual.party_index = _i; 
                }
            }
        }
    } else {
        show_debug_message("BATTLE SYSTEM WARNING: 'obj_battle_party_member' object does not exist in the Asset Browser!");
    }

    // --- 3. CLEAR AND INSTANTIATE THE ARENA ENEMIES ---
    global.active_battle_enemies = [];

    if (variable_global_exists("battle_spawn_queue") && is_array(global.battle_spawn_queue)) {
        var _count = array_length(global.battle_spawn_queue);
        var _enemy_object_id = asset_get_index("obj_battle_enemy_placeholder");
        
        if (_enemy_object_id == -1) {
            show_debug_message("CRITICAL ERROR: 'obj_battle_enemy_placeholder' object is missing from the asset browser tree!");
            exit; 
        }
        
        var _base_x = 280; 
        var _base_y = 60;  
        var _spacing = 45; 

        // Absolute verification check before accessing the data structure
        if (!variable_global_exists("enemy_database") || global.enemy_database == undefined) {
            show_debug_message("CRITICAL ERROR: global.enemy_database is completely missing at battle initialization! Check execution order.");
            exit;
        }

        for (var _i = 0; _i < _count; _i++) {
            var _enemy_key = global.battle_spawn_queue[_i];
            
            if (is_string(_enemy_key)) {
                _enemy_key = string_lower(string_trim(_enemy_key));
            }
            
            if (struct_exists(global.enemy_database, _enemy_key)) {
                var _blueprint = global.enemy_database[$ _enemy_key];
                
                var _spawn_x = _base_x + (_i * 10); 
                var _spawn_y = _base_y + (_i * _spacing);
                
                var _new_enemy = instance_create_layer(_spawn_x, _spawn_y, "Instances", _enemy_object_id);
                
                if (instance_exists(_new_enemy)) {
                    _new_enemy.name         = struct_exists(_blueprint, "name") ? _blueprint.name : "Enemy";
                    _new_enemy.hp           = struct_exists(_blueprint, "hp") ? _blueprint.hp : 30;
                    _new_enemy.max_hp       = struct_exists(_blueprint, "max_hp") ? _blueprint.max_hp : 30;
                    _new_enemy.atk          = struct_exists(_blueprint, "atk") ? _blueprint.atk : 10;
                    _new_enemy.def          = struct_exists(_blueprint, "def") ? _blueprint.def : 0;
                    
                    // --- MERCY PROPERTIES ---
                    _new_enemy.max_mercy    = struct_exists(_blueprint, "max_mercy") ? _blueprint.max_mercy : 100;
                    _new_enemy.mercy        = 0;     
                    _new_enemy.can_spare    = false; 
                    _new_enemy.is_spared    = false; // Ensure this is explicitly set at spawning

                    // --- DYNAMICALLY BIND INTERACT OPTIONS ---
                    if (struct_exists(_blueprint, "interact_options") && is_array(_blueprint.interact_options)) {
                        var _len = array_length(_blueprint.interact_options);
                        _new_enemy.interact_options = array_create(_len);
                        array_copy(_new_enemy.interact_options, 0, _blueprint.interact_options, 0, _len);
                    } else {
                        _new_enemy.interact_options = ["Check"]; // Baseline fallback option
                    }
                    
                    // --- REVENUE BALANCING TRACKERS ---
                    _new_enemy.gold_value   = struct_exists(_blueprint, "gold_value") ? _blueprint.gold_value : 0;
                    _new_enemy.xp_value     = struct_exists(_blueprint, "xp_value") ? _blueprint.xp_value : 0;
                    
                    // --- VISUAL RENDERING ASSETS ---
                    _new_enemy.sprite       = struct_exists(_blueprint, "sprite") ? _blueprint.sprite : spr_box; 
                    _new_enemy.sprite_index = _new_enemy.sprite; 
                    _new_enemy.image_index  = 0;                 
                    _new_enemy.is_dead      = false; 
                    
                    array_push(global.active_battle_enemies, _new_enemy);
                    show_debug_message("Arena Setup Verified: Spawning " + _new_enemy.name + " with database HP: " + string(_new_enemy.hp));
                }
            } else {
                show_debug_message("BATTLE SETUP ERROR: Key '" + string(_enemy_key) + "' was not found in the external database file.");
            }
        }
    }
    
    // --- 4. POPULATE OPTIONS FOR TARGET SELECTION ENGINE ---
    _options_array = global.active_battle_enemies;
    _total_options = array_length(global.active_battle_enemies);
    menu_cursor    = 0;

    // --- 5. INITIALIZE FRESH DECK SELECTION OFFER ---
    global.selected_cards = [];
    if (variable_global_exists("card_pool") && array_length(global.card_pool) > 0) {
        var _pool_size = array_length(global.card_pool);
        repeat(3) {
            var _random_idx = irandom(_pool_size - 1);
            var _base_card  = global.card_pool[_random_idx];
            
            array_push(global.selected_cards, {
                is_revealed: false,
                x: 0,
                y: 0,
                icon_sprite: _base_card.icon_sprite,
                icon_frame:  _base_card.icon_frame,
                card_info:   _base_card
            });
        }
    }
    
    battle_setup_card_selection();
}