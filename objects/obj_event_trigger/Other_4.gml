var _layer_id = layer_get_id("Instances");
layer_sequence_create(_layer_id, 0, 0, sequence_id);

obj_player.visible = false;
obj_player.can_move = false;
instance_destroy();