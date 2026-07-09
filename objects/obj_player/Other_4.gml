/// @description Complete Room Start Management Engine

// ============================================================================
// PHASE 1: UNIFIED ROOM CONDITIONAL STATE CONFIGURATION
// ============================================================================
switch (room) 
{
    case rm_init:
    case rm_splash:
    case rm_menuRoom:
    case rm_nameScreen:
    case rm_introCutscene:
        x = -50;
        y = -50;
        can_move = false;
        can_open_menu = false;
        can_open_inventory = false;
        visible = false;
        break;
        
    case rm_shop:
    case rm_battle: // Prevent menu access during combat environments
        can_move = (room == rm_shop); // True if shop, false if gameOver/battle
        can_open_menu = false;
        can_open_inventory = false;
        visible = (room != rm_battle); // Hide player sprite if in battle room
        break;
        
    case rm_outside:
    case rm_forest_1:
    case rm_forest_2:
    default: // Standard overworld exploration environments
        can_move = true;
        can_open_menu = true;
        can_open_inventory = true;
        visible = true;
        image_alpha = 1.0;
        break;
}

// ============================================================================
// PHASE 2: PROCESS SAVE FILE POSITIONING OVERRIDES
// ============================================================================
if (variable_global_exists("is_loading_save") && global.is_loading_save == true) {
    
    // Snatch cached load coordinates and metadata safely
    x = global.load_x;
    y = global.load_y;
    face = variable_global_exists("load_face") ? global.load_face : 0;
    
    // Enforce default exploration states on load
    global.state = GAME_STATE.PLAYING;
    can_move = true;
    can_open_menu = true;
    can_open_inventory = true;
    visible = true;
    image_alpha = 1.0;
    
    // Reconstruct the tracking data array structure safely from disk save strings
    party_allies = [];
    if (variable_global_exists("load_followers") && is_array(global.load_followers)) {
        var _loaded_count = array_length(global.load_followers);
        for (var _f = 0; _f < _loaded_count; _f++) {
            var _data_struct = global.load_followers[_f];
            
            if (is_struct(_data_struct)) {
                var _obj_asset = asset_get_index(_data_struct.object_name);
                var _spr_asset = asset_get_index(_data_struct.sprite_name);
                
                // Rebuild it back into a standard data runtime struct profile
                var _runtime_profile = {
                    object_index: (_obj_asset != -1) ? _obj_asset : asset_get_index("obj_follower"),
                    sprite: (_spr_asset != -1) ? _spr_asset : noone
                };
                
                array_push(party_allies, _runtime_profile);
            }
        }
    }
    
    // Consume the load flag so normal room transitions function correctly
    global.is_loading_save = false;
    global.load_followers = [];
    show_debug_message("Player safely instantiated via Save System at: " + string(x) + "," + string(y));
}

// ============================================================================
// PHASE 3: PHYSICAL FOLLOWER INSTANTIATION CLEANUP & SPAWN
// ============================================================================

// 1. Vaporize old overworld instances to prevent duplication across room changes
var _base_follower_idx = asset_get_index("obj_follower");
if (_base_follower_idx != -1 && instance_exists(_base_follower_idx)) {
    with (_base_follower_idx) instance_destroy();
}

// 2. Wipe and re-prime position histories clean to prevent trailing movement lag
if (variable_instance_exists(id, "pos_history")) {
    if (!ds_exists(pos_history, ds_type_list)) {
        pos_history = ds_list_create();
    } else {
        ds_list_clear(pos_history);
    }
    
    // SEED POSITION HISTORY: Prime the trail with 100 frames of current coordinates
    // This stops obj_follower's step event history size check from crashing on frame 1
    repeat(100) {
        ds_list_add(pos_history, {
            x: x,
            y: y,
            img_idx: 0
        });
    }
}

if (can_open_menu && room != rm_menuRoom) {
    if (variable_instance_exists(id, "party_allies") && is_array(party_allies)) {
        var _ally_count = array_length(party_allies);
        
        // --- FIXED LAYER CHECK ---
        // Fall back to a string named layer if the player's persistent layer ID isn't found in this room
        var _target_layer = layer; 
        if (_target_layer == -1 || !layer_exists(_target_layer)) {
            if (layer_exists("Instances")) {
                _target_layer = layer_get_id("Instances");
            } else {
                // Last ditch safety fallback: force it onto whatever layer the player is currently sitting on
                _target_layer = obj_player.layer; 
            }
        }
        
        show_debug_message("ROOM START: Processing party_allies array. Total count found: " + string(_ally_count));
        
        for (var _i = 0; _i < _ally_count; _i++) {
            var _ally_entry = party_allies[_i];
            
            // Fallback default assignments
            var _spawn_obj = _base_follower_idx;
            var _custom_sprite = noone;
            
            // CONDITION A: The save loaded a raw object index pointer
            if (object_exists(_ally_entry)) {
                _spawn_obj = _ally_entry;
            }
            // CONDITION B: The array is holding a live custom struct from the overworld setup
            else if (is_struct(_ally_entry)) {
                if (variable_struct_exists(_ally_entry, "object_index") && object_exists(_ally_entry.object_index)) {
                    _spawn_obj = _ally_entry.object_index;
                }
                if (variable_struct_exists(_ally_entry, "sprite")) {
                    _custom_sprite = _ally_entry.sprite;
                }
            }
            
            // EXECUTE SPAWN PASS
            if (_spawn_obj != -1) {
                var _new_follower = instance_create_layer(x, y, _target_layer, _spawn_obj);
                
                if (instance_exists(_new_follower)) {
                    _new_follower.follower_index = _i;
                    
                    // Force apply the custom graphics overlay if specified by a struct blueprint
                    if (_custom_sprite != noone && sprite_exists(_custom_sprite)) {
                        _new_follower.sprite_index = _custom_sprite;
                    }
                    
                    show_debug_message("SUCCESS: Spawned follower index [" + string(_i) + "] using object asset: " + object_get_name(_new_follower.object_index) + " with Sprite Index: " + sprite_get_name(_new_follower.sprite_index));
                }
            } else {
                show_debug_message("WARNING: Follower slot [" + string(_i) + "] skipped because no valid object could be resolved.");
            }
        }
    } else {
        show_debug_message("ROOM START: party_allies array completely missing or uninitialized on player instance.");
    }
}