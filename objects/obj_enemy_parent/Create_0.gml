// --- OVERWORLD AI VARIABLES ---
walk_speed = 1.5;
chase_speed = 2.5;
target_x = x;
target_y = y;

// Simple state machine for overworld behavior
enum ENEMY_AI { IDLE, WANDER, CHASE }
ai_state = ENEMY_AI.IDLE;

// Timers for wandering
wander_timer = room_speed * random_range(1, 3);
detection_radius = 120; // Distance to spot the player

// --- COMBAT STATS (READ BY THE BATTLE CONTROLLER) ---
// Child objects will overwrite these in their own Create Events
combat_stats = {
    name: "Generic Enemy",
    max_hp: 30,
    hp: 30,
    atk: 8,
    def: 3,
    spd: 6,
    xp_value: 15,
    gold_value: 10
};