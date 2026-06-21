if (room == rm_outside || room == rm_forest_1 || room == rm_outside_3) {
    can_move = true;
}
if (room == rm_shop)
{
	can_open_menu = false;
}


if (room == rm_init || room == rm_splash || room == rm_menuRoom || room == rm_nameScreen || room == rm_introCutscene)
{
	x = -50;
	y = -50;
	can_move = false;
	can_open_menu = false;
}
else {
	can_open_menu = true;
}

/// @description obj_player Room Start Event (or Overworld Controller Room Start)

// 1. Clear out any old physical followers to prevent duplicates
if (instance_exists(obj_follower)) {
    instance_destroy(obj_follower);
}

// 2. Clear movement history list so followers don't teleport across the room on spawn
if (ds_exists(pos_history, ds_type_list)) {
    ds_list_clear(pos_history);
}

// 3. Spawn physical followers ONLY IF they exist in the party array data slot
var _ally_count = array_length(party_allies);
for (var _i = 0; _i < _ally_count; _i++) {
    var _ally_data = party_allies[_i];
    
    // Spawn them directly on top of the player at first
    var _new_follower = instance_create_layer(x, y, "Instances", obj_follower);
    _new_follower.follower_index = _i;
    
    // Assign their overworld walking sprites from their data struct
    if (variable_struct_exists(_ally_data, "sprite")) {
        _new_follower.sprite_index = _ally_data.sprite; 
    }
}