/// @description Build Combat Arena Instances From Database
global.active_battle_enemies = [];

if (variable_global_exists("battle_spawn_queue") && is_array(global.battle_spawn_queue)) {
    var _count = array_length(global.battle_spawn_queue);
    
    // Safely resolve the placeholder object index
    var _enemy_object_id = asset_get_index("obj_battle_enemy_placeholder");
    if (_enemy_object_id == -1) {
        show_debug_message("CRITICAL ERROR: 'obj_battle_enemy_placeholder' asset missing from Asset Browser!");
        exit; 
    }
    
    for (var _i = 0; _i < _count; _i++) {
        var _enemy_key = global.battle_spawn_queue[_i]; // e.g., "slime"
        
        // Safety verification: Ensure the key actually exists inside your database script
        if (variable_global_exists("enemy_database") && variable_struct_exists(global.enemy_database, _enemy_key)) {
            var _blueprint = variable_struct_get(global.enemy_database, _enemy_key);
            
            // Spawn the concrete arena entity
            var _new_enemy = instance_create_layer(0, 0, "Instances", _enemy_object_id);
            
            // Map core metrics directly from the blueprint struct
            _new_enemy.name     = _blueprint.name;
            _new_enemy.hp       = _blueprint.hp;
            _new_enemy.max_hp   = _blueprint.max_hp;
            
            // --- THE CRITICAL ANIMATION ALIGNMENT ---
            // We assign the asset directly to BOTH your custom variable AND the engine's built-in sprite variable
            _new_enemy.sprite       = _blueprint.sprite; 
            _new_enemy.sprite_index = _blueprint.sprite; // Forces GameMaker's image_speed to process frames
            _new_enemy.image_index  = 0;                 // Reset frame starting index position
            
            array_push(global.active_battle_enemies, _new_enemy);
        } else {
            show_debug_message("BATTLE SETUP WARNING: Key '" + string(_enemy_key) + "' not found in global.enemy_database!");
        }
    }
}