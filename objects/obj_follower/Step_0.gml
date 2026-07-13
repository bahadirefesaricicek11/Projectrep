/// @description obj_follower Step Event

if (instance_exists(obj_player)) {
    var _history = obj_player.pos_history;
    var _history_size = ds_list_size(_history);
    
    var _delay_frame = (follower_index + 1) * 15;
    
    if (_history_size > _delay_frame) {
        var _target_pos = _history[| _delay_frame];
        
        // --- THE FIX: Ensure the loaded history struct is structurally valid ---
        if (is_struct(_target_pos) && variable_struct_exists(_target_pos, "sprite")) {
            
            // Snap directly to the historical coordinate record
            x = _target_pos.x;
            y = _target_pos.y;
            
            // Dynamic Sprite Matching via String Parsing
            var _player_sprite_name = sprite_get_name(_target_pos.sprite);
            
            if (string_ends_with(_player_sprite_name, "_down")) {
                sprite_index = spr_npc_cartoon_down;
            } else if (string_ends_with(_player_sprite_name, "_left")) {
                sprite_index = spr_npc_cartoon_left;
            } else if (string_ends_with(_player_sprite_name, "_right")) {
                sprite_index = spr_npc_cartoon_right;
            } else if (string_ends_with(_player_sprite_name, "_up")) {
                sprite_index = spr_npc_cartoon_up;
            }
            
            // Match the sub-image frame for walking animation sync
            image_index = _target_pos.img_idx;
            
            // Stop animation if the follower isn't actively moving through space
            if (_delay_frame + 1 < _history_size) {
                var _prev_pos = _history[| _delay_frame + 1];
                if (is_struct(_prev_pos) && _target_pos.x == _prev_pos.x && _target_pos.y == _prev_pos.y) {
                    image_index = 0; 
                    image_speed = 0;
                } else {
                    image_speed = 1; 
                }
            }
        } else {
            // Fallback: If history data is corrupted or raw from a file load,
            // just snap them to the player directly until the log rebuilds safely.
            x = obj_player.x;
            y = obj_player.y;
        }
    }
    
    // Set depth dynamically so they layer correctly behind/in front of trees/walls
    depth = -bbox_bottom;
}