/// @description Update Card Transitions and Timers
timer++;
// --- PHASE 1: SLIDE CARDS TO TARGET CENTER ---
if (!target_room_reached) {
    var _slide_in_speed = 0.05; 
    
    for (var _i = 0; _i < card_count; _i++) {
        card_y[_i] = lerp(card_y[_i], 0, _slide_in_speed);
    }
    
    // Check if the right-most card has locked into place near center 0
    if (abs(card_y[2]) <= 1) {
        for (var _i = 0; _i < card_count; _i++) card_y[_i] = 0;
        
        target_room_reached = true;
        
        // NEW: propagate this transition's battle_id (set by whatever created this
        // instance — e.g. a dialogue EXECUTE block) into global.battle_id, so
        // scr_check_slime_results() and friends can identify this specific fight
        // once it ends. Also defensively resets global.battle_result, in case a
        // previous battle left a stale value sitting there.
        global.battle_id = variable_instance_exists(id, "battle_id") ? battle_id : "none";
        global.battle_result = "none";
        
        // Trigger the room transition function
        battle_trigger_room_transition(encounter_composition);
    }
}
// --- PHASE 2: DISCARD / SLIDE AWAY (ONLY AFTER REACHING RM_BATTLE) ---
else {
    // GATE: Wait until the engine actually arrives in the battle room!
    // This stops them from instantly flying away while the overworld is still unloading.
    if (room == rm_battle) {
        var _slide_out_speed = 8; 
        
        // Send cards flying away back the exact path they arrived
        card_y[0] -= _slide_out_speed; // Left flies UP
        card_y[1] += _slide_out_speed; // Middle flies DOWN
        card_y[2] -= _slide_out_speed; // Right flies UP
        
        // Once the cards clear presentation bounds completely, clean up the instance
        if (card_y[1] > 240) {
            instance_destroy();
        }
    }
}
