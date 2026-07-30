/**
 * @desc Recruits an overworld NPC into the active party and handles overworld cleanup.
 * @param {Id.Instance} _npc_inst The instance ID of the NPC being recruited.
 */
function party_recruit_npc(_npc_inst) {
   // 1. Safety Guard: Make sure the instance actually exists and has an ID key
    if (!instance_exists(_npc_inst)) return;
    if (!instance_exists(obj_player)) return;
    
    // Fallback to "Unknown" so it doesn't collide with existing party members
    var _ally_id = variable_instance_exists(_npc_inst, "ally_key") ? _npc_inst.ally_key : "Unknown";
    
    if (_ally_id == "Unknown") {
        show_debug_message("CRITICAL ERROR: NPC instance " + string(_npc_inst) + " is missing its 'ally_key' variable!");
        return;
    }
    
    // 2. FIX: obj_player.party_allies is the array everything else actually reads —
    // Room Start rebuilds every overworld follower from it on every room transition,
    // and the battle arena setup builds the fighting party from it. Pushing to
    // global.encounter_allies (a separate, disconnected array) meant a freshly
    // recruited ally's follower would vanish the instant the player changed rooms,
    // and would never show up in battle either.
    if (!variable_instance_exists(obj_player, "party_allies") || !is_array(obj_player.party_allies)) {
        obj_player.party_allies = [];
    }
    
    // Guard against recruiting the same ally twice (wasn't checked before)
    var _already_in_party = false;
    for (var _pc = 0; _pc < array_length(obj_player.party_allies); _pc++) {
        if (string_lower(string(obj_player.party_allies[_pc])) == string_lower(_ally_id)) {
            _already_in_party = true;
            break;
        }
    }
    if (_already_in_party) {
        show_debug_message("Cannot recruit: " + _ally_id + " is already in the party!");
        return;
    }
    
    // 3. Limit party size to Player + 2 Allies. party_allies holds ONLY allies, not
    // the player (obj_player's Room Start explicitly skips a "Player" entry), so the
    // cap here is 2 — matching "Player + 2 Allies" the same as the original intent.
    if (array_length(obj_player.party_allies) < 2) {
        
        // Register name to the single shared party-tracking array
        array_push(obj_player.party_allies, _ally_id);
        
        // Mirrored into global.encounter_allies too, ONLY for backward compatibility
        // in case other code elsewhere in the project still reads it. If nothing else
        // references global.encounter_allies, this block can be deleted entirely —
        // party_allies is now the actual source of truth.
        if (!variable_global_exists("encounter_allies") || !is_array(global.encounter_allies)) {
            global.encounter_allies = ["Hero"];
        }
        array_push(global.encounter_allies, _ally_id);
        
        // 4. Spawn the physical overworld follower
        var _new_follower = instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_follower);
        _new_follower.ally_name = _ally_id;
        // FIX: follower_index now matches this ally's position in party_allies. It
        // previously defaulted to 0 (obj_follower's own Create Event fallback), which
        // would stack a second mid-room recruit directly on top of the first one's
        // trail position instead of following one step further back.
        _new_follower.follower_index = array_length(obj_player.party_allies) - 1;
        
        // Force immediate visual asset alignment
        with (_new_follower) {
            // FIX: was global.ally_db (didn't exist anywhere). Now uses
            // ally_database_lookup(), which matches case-insensitively — this is the
            // actual fix for entries added in display case (e.g. "Bob") not matching
            // a lowercased lookup key ("bob").
            var _db_data = ally_database_lookup(_ally_id);
            if (!is_undefined(_db_data)) {
                sprite_index = variable_struct_exists(_db_data, "sprite_idle") ? _db_data.sprite_idle : sprite_index;
                base_sprite = sprite_index;
            } else {
                show_debug_message("FOLLOWER SPAWN WARNING: Ally '" + _ally_id + "' not found in global.ally_database — using default follower sprite.");
            }
        }
        
        // 5. Clean up the interactive NPC map asset
        _npc_inst.has_joined = true; // was defined on obj_npc but never actually set anywhere
        _npc_inst.visible = false;
        _npc_inst.x = -9999;
        _npc_inst.y = -9999;
        _npc_inst.alarm[0] = 10; // Trigger destruction delay
        
        show_debug_message("Successfully recruited: " + _ally_id);
    } else {
        show_debug_message("Cannot recruit: Party is already full!");
    }
}
