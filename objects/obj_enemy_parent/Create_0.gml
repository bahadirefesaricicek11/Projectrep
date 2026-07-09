/// @description Baseline Overworld Logic
walk_speed = 1.5;
chase_speed = 2.5;
target_x = x;
target_y = y;

ai_state = ENEMY_AI.IDLE;
wander_timer = room_speed * random_range(1, 3);
detection_radius = 120;

// This key will be defined by child objects to identify who they are
db_key = "slime"; 
combat_stats = undefined;