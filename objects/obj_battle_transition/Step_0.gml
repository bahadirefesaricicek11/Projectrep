timer++;

// --- PHASE 1: SLIDE CARDS TO TARGET ---
if (!target_room_reached) {
    var _slide_in_speed = 0.05; 
    
    for (var _i = 0; _i < card_count; _i++) {
        card_y[_i] = lerp(card_y[_i], 0, _slide_in_speed);
    }
    
    // Check if the right-most card has locked into place near 0
    if (abs(card_y[2]) <= 2) {
        card_y[0] = 0;
        card_y[1] = 0;
        card_y[2] = 0;
        target_room_reached = true;
        
        battle_trigger_room_transition(encounter_composition);
    }
}
// --- PHASE 2: DISCARD / SLIDE AWAY ---
else {
    var _slide_out_speed = 6; 
    
    // Send them back the exact way they came
    card_y[0] -= _slide_out_speed; // Left flies UP
    card_y[1] += _slide_out_speed; // Middle flies DOWN
    card_y[2] -= _slide_out_speed; // Right flies UP
    
    if (card_y[0] < -240) {
        instance_destroy();
    }
}