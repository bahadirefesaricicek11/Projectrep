/// @description obj_follower Step Event

if (instance_exists(obj_player)) {
    var _history = obj_player.pos_history;
    var _history_size = ds_list_size(_history);
    
    // Determine how far back in time this specific follower needs to look
    // Follower 0 looks 25 frames back. Follower 1 looks 50 frames back.
    var _delay_frame = (follower_index + 1) * 10;
    
    if (_history_size > _delay_frame) {
        var _target_pos = _history[| _delay_frame];
        
        // Snap directly to the historical coordinate record
        x = _target_pos.x;
        y = _target_pos.y;
        
        // Optional: Match the animations or directional sprites of the player history
        // If your follower uses separate directional sprites, you can parse them here.
        image_index = _target_pos.img_idx;
    }
    
    // Set depth dynamically so they layer correctly behind/in front of trees/walls
    depth = -bbox_bottom;
}