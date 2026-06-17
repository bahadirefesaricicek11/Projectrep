// STATE GATE: Freeze completely if not in the overworld
if (global.state != GAME_STATE.PLAYING) {
    image_speed = 0; // Stop sprite animations
    exit;
}

// Resume animation speed when playing
image_speed = 1;

// --- OVERWORLD AI BEHAVIOR ---
var _player_exists = instance_exists(obj_player);
var _dist_to_player = _player_exists ? point_distance(x, y, obj_player.x, obj_player.y) : 99999;

switch (ai_state) {
    case ENEMY_AI.IDLE:
        // Countdown to wander
        wander_timer--;
        if (wander_timer <= 0) {
            ai_state = ENEMY_AI.WANDER;
            wander_timer = room_speed * random_range(2, 4);
            // Pick a random spot nearby to walk to
            target_x = x + random_range(-64, 64);
            target_y = y + random_range(-64, 64);
        }
        
        // Check for player detection
        if (_dist_to_player <= detection_radius) {
            ai_state = ENEMY_AI.CHASE;
        }
        break;

    case ENEMY_AI.WANDER:
        // Move toward target spot
        if (point_distance(x, y, target_x, target_y) > 4) {
            var _dir = point_direction(x, y, target_x, target_y);
            x += lengthdir_x(walk_speed, _dir);
            y += lengthdir_y(walk_speed, _dir);
            
            // Flip sprite based on direction
            if (lengthdir_x(walk_speed, _dir) != 0) {
                image_xscale = sign(lengthdir_x(walk_speed, _dir));
            }
        } else {
            ai_state = ENEMY_AI.IDLE;
        }
        
        // Check for player detection
        if (_dist_to_player <= detection_radius) {
            ai_state = ENEMY_AI.CHASE;
        }
        break;

    case ENEMY_AI.CHASE:
        // If player is lost, go back to idle
        if (_dist_to_player > detection_radius * 1.5 || !_player_exists) {
            ai_state = ENEMY_AI.IDLE;
            break;
        }
        
        // Move directly toward player
        var _dir = point_direction(x, y, obj_player.x, obj_player.y);
        x += lengthdir_x(chase_speed, _dir);
        y += lengthdir_y(chase_speed, _dir);
        
        if (lengthdir_x(chase_speed, _dir) != 0) {
            image_xscale = sign(lengthdir_x(chase_speed, _dir));
        }
        break;
}