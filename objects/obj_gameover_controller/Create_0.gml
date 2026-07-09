
// Initialize choices
// --- CHOICE PROMPT INITIALIZATION ---
choice_active = true;
menu_choice = 0; // 0 = CONTINUE, 1 = GIVE UP

// Cursor physics configuration
cursor_x = 0;       // Actual X coordinate drawn on screen
cursor_y = 0;       // Actual Y coordinate drawn on screen
cursor_target_x = 0; // The coordinate the cursor is actively chasing

// Run your internal text engine
if (script_exists(asset_get_index("startDialogue"))) {
    startDialogue("gameover");
} else {
    show_debug_message("CRITICAL: startDialogue function missing!");
}

// --- CONFETTI SYSTEM INITIALIZATION ---
confetti_list = [];
var _total_confetti = 25; 

for (var _i = 0; _i < _total_confetti; _i++) {
    var _colors = [c_red, c_yellow, c_lime, c_aqua, c_fuchsia, c_orange];
    array_push(confetti_list, {
        x: random_range(0, room_width),
        y: random_range(-100, -10),
        vspeed: random_range(0.5, 1.0),
        hspeed: random_range(-2.5, 0.5),
        gravity: random_range(0.05, 0.12),
        scale_x: random_range(0.5, 1.2), // Used to simulate 3D paper flipping
        color: _colors[irandom(array_length(_colors) - 1)],
        angle: random(360),
        rot_speed: random_range(-4, 2),
        oscillation_speed: random_range(0.01, 0.1),
        oscillation_timer: random(100)
    });
}

// --- FLOATING SPR_GOOFY SYSTEM ---
goofy_x = room_width / 2;
goofy_y = room_height / 2 - 50; // Centered, slightly elevated

goofy_timer_x = 0;
goofy_timer_y = 50; // Offset start so it moves in an oval path, not a diagonal line

// Tweak these values to change the movement behavior
goofy_drift_speed_x = 0.03; 
goofy_drift_speed_y = 0.02;
goofy_range_x = 40;  // How far left and right it floats
goofy_range_y = 25;  // How far up and down it floats

// --- GOOFY ANIMATION TRACKING ---
goofy_frame = 0;             // The playback index head
goofy_anim_speed = 0.15;     // Tweak this number to change how fast the animation cycles