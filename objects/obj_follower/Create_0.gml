/// @description obj_follower Create Event

// ONLY set it to 0 if it hasn't been assigned by the spawning loop yet!
if (!variable_instance_exists(id, "follower_index")) {
    follower_index = 0;
}

base_sprite = sprite_index;
image_speed = 0;