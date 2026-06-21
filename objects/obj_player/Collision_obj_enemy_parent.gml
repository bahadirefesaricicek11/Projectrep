// Add a check to ensure we aren't already transitioning
if (global.state == GAME_STATE.PLAYING && !instance_exists(obj_battle_transition)) {
    can_move = false; 
    hspeed = 0;
    vspeed = 0;

    global.overworld_room_fallback = room;
    global.overworld_enemy_to_destroy = other.id; 

    var _encounter_composition = battle_generate_party(other.encounter_id); 

    var _inst = instance_create_layer(0, 0, "Instances", obj_battle_transition);
    _inst.encounter_composition = _encounter_composition;
}