if (global.state == GAME_STATE.PLAYING) {
    can_move = false; 
    hspeed = 0;
    vspeed = 0;

    // --- DYNAMIC PARTY DETERMINATION ---
    // Instead of [other.enemy_id], we roll for the entire party composition array
    var _encounter_composition = battle_generate_party(other.encounter_id); 

    // Spawn the transition runner and hand off the newly rolled party array
    var _inst = instance_create_layer(0, 0, "Instances", obj_battle_transition);
    _inst.encounter_composition = _encounter_composition;

    with (other) {
        instance_destroy();
    }
}