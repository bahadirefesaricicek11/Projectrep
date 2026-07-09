name = global.player_name;
global.player_hp = 10;
global.player_hp_max = 100;
global.player_attack = 45;
global.player_defense = 0;
global.player_gold = 0;

/// Inside obj_player Create Event
party_allies = []; // Starts empty (Solo player mode)
pos_history = ds_list_create();

gamepad_set_axis_deadzone(1, 0.5)

spd = 1.5;
walk_spd = 1.5;
run_spd = 2.5;
run = false


can_move = true;
can_open_menu = true;
can_open_inventory = true;
xspd = 0;
yspd = 0;


sprite[FACE_RIGHT] = spr_player_right;
sprite[FACE_UP] = spr_player_up;
sprite[FACE_LEFT] = spr_player_left;
sprite[FACE_DOWN] = spr_player_down;

face = FACE_DOWN;