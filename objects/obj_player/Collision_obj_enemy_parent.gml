if (global.state == GAME_STATE.PLAYING) {
    // 1. Freeze player input/movement variables immediately
    can_move = false; 
    hspeed = 0;
    vspeed = 0;

    // 2. Capture the stats of the enemy we ran into
    var _encounter_composition = [other.combat_stats]; 

    // 3. Destroy the overworld enemy instance so it's gone when we return
    with (other) {
        instance_destroy();
    }
    
    // 4. Go to battle room
    battle_trigger_room_transition(_encounter_composition);
}