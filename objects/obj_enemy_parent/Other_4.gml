/// @description obj_enemy_spawner Room Start Event
if (variable_global_exists("overworld_enemy_to_destroy")) {
    if (global.overworld_enemy_to_destroy == id) {
        instance_destroy();
        global.overworld_enemy_to_destroy = noone;
    }
}