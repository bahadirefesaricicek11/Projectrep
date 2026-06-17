var _enemy_count = array_length(global.active_battle_enemies);
for (var _i = 0; _i < _enemy_count; _i++) {
    // Clean layout positions isolated to rm_battle
    var _spawn_x = room_width - 300;
    var _spawn_y = 200 + (_i * 150);
    
    var _inst = instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_battle_entity);
    _inst.stats = global.active_battle_enemies[_i];
}

menu_cursor = 0;