room_goto(target_rm);
obj_player.x = target_x;
obj_player.y = target_y;
obj_player.depth = -bbox_bottom;

if !instance_exists(obj_player) {instance_create_layer(global.x, global.y, layer, obj_player);};

image_speed = -1;