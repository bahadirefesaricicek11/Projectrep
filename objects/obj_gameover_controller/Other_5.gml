/// @description Clean Up Engine Right As Room Changes

global.state = GAME_STATE.PLAYING;
global.active_battle_enemies = [];

// Force clean the player instance variables if it managed to spawn
if (instance_exists(obj_player)) {
    obj_player.can_move = true;
    obj_player.can_open_menu = true;
    obj_player.can_open_inventory = true;
    obj_player.image_speed = 2;
    
    if (variable_instance_exists(obj_player, "pos_history")) {
        if (ds_exists(obj_player.pos_history, ds_type_list)) {
            ds_list_clear(obj_player.pos_history);
        }
    }
}

// Now it is safe to self-destruct
instance_destroy();