/// @description obj_player Room Start Event
switch (room) 
{
    case rm_init:
    case rm_splash:
    case rm_menuRoom:
    case rm_nameScreen:
    case rm_introCutscene:
        x = -50; y = -50;
        can_move = false; can_open_menu = false;
        visible = false;
        exit;
        
    default: 
        can_move = true; can_open_menu = true;
        visible = true;
        break;
}
// 1. Reinitialize and seed tracking history cleanly
if (!variable_instance_exists(id, "pos_history") || !ds_exists(pos_history, ds_type_list)) {
    pos_history = ds_list_create();
} else {
    ds_list_clear(pos_history);
}
repeat (120) {
    ds_list_add(pos_history, {
        x: x,
        y: y,
        sprite: sprite_index,
        img_idx: image_index
    });
}
// 2. Fetch target layer context safely
var _current_layer = layer_get_id("Instances");
if (_current_layer == -1) _current_layer = layer;
// 3. Clear ANY existing followers completely to prevent duplicate ghost copies
if (instance_exists(obj_follower)) {
    with (obj_follower) instance_destroy();
}
// 4. Clean spawning sequence using the Database structural layout
if (variable_instance_exists(id, "party_allies") && is_array(party_allies)) {
    var _ally_count = array_length(party_allies);
    
    for (var _i = 0; _i < _ally_count; _i++) {
        var _party_member_name = party_allies[_i];
        
        // Safety: If your array holds raw structs instead of strings, extract the name string
        if (is_struct(_party_member_name) && variable_struct_exists(_party_member_name, "name")) {
            _party_member_name = _party_member_name.name;
        }
        
        // Skip spawning if this slot is the Player character
        if (_party_member_name == "Player") continue;
        
        // FIX: this now points at global.ally_database (the single ally source of
        // truth, shared with the battle arena setup) instead of global.ally_db, which
        // was a name that didn't actually exist anywhere — this lookup would have
        // silently failed (or errored) every time before.
        // FIX: uses ally_database_lookup(), which matches case-insensitively — a
        // database entry written as "Bob", "bob", or "BOB" all resolve the same way,
        // so this can't silently miss just because of how an entry was capitalized
        // when it was added.
        var _db_entry = ally_database_lookup(_party_member_name);
        
        if (!is_undefined(_db_entry)) {
            var _spawn_obj = asset_get_index("obj_follower");
            
            if (_spawn_obj != -1) {
                // Space them out physically behind the player on spawn frame 1
                var _spawn_x = x - ((_i + 1) * 16);
                var _new_follower = instance_create_layer(_spawn_x, y, _current_layer, _spawn_obj);
                
                if (instance_exists(_new_follower)) {
                    _new_follower.follower_index = _i;
                    
                    // Core fix: Map database "sprite_idle" key directly to the instance
                    if (variable_struct_exists(_db_entry, "sprite_idle") && sprite_exists(_db_entry.sprite_idle)) {
                        _new_follower.sprite_index = _db_entry.sprite_idle;
                    }
                    
                    _new_follower.base_sprite = _new_follower.sprite_index;
                }
            }
        } else {
            show_debug_message("FOLLOWER SETUP ERROR: Ally '" + string(_party_member_name) + "' was not found in global.ally_database.");
        }
    }
}
