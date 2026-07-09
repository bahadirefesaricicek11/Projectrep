/// @description Process Menu Input & Object Physics
var _key_left  = InputPressed(INPUT_VERB.LEFT);
var _key_right = InputPressed(INPUT_VERB.RIGHT);
var _key_conf  = InputPressed(INPUT_VERB.ACCEPT);

// 1. Wait until your dialogue system object self-destructs or finishes
if (!instance_exists(obj_textbox)) {
    choice_active = true;
}

// --- UPDATE GOOFY ANIMATION HEAD ---
if (sprite_exists(goofy)) {
    // Increments frame by anim speed and loops back to 0 when it hits the maximum frame count
    goofy_frame = (goofy_frame + goofy_anim_speed) % sprite_get_number(goofy);
}

// 2. Process selection inputs once choices display
if (choice_active) {
    if (_key_left || _key_right) {
        menu_choice = (menu_choice == 0) ? 1 : 0;
    }
    
    // Define lerp target milestones based on GUI layout metrics
    var _center_x    = 384 / 2;
    var _prompt_y    = 216 / 2 + 10;
    var _btn_y       = _prompt_y + 15;
    var _left_btn_x  = _center_x - 60;
    var _right_btn_x = _center_x + 60;

    // Point the cursor to the active button position
    if (menu_choice == 0) {
        cursor_target_x = _left_btn_x - 45;
    } else {
        cursor_target_x = _right_btn_x - 45;
    }
    cursor_y = _btn_y;

    // Execute Smooth Lerp Engine
    if (cursor_x == 0) cursor_x = cursor_target_x; 
    cursor_x = lerp(cursor_x, cursor_target_x, 0.2);
    
	if (_key_conf) {
	    if (menu_choice == 0) {
	        // CHOICE: CONTINUE -> Start the migration sequence
        
	        // 1. Permanently wipe out the old battle controller so it cannot run ghost code
	        if (instance_exists(obj_battle_controller)) {
	            with(obj_battle_controller) instance_destroy();
	        }
	        if (instance_exists(obj_textbox)) {
	            with(obj_textbox) instance_destroy();
	        }
        
	        // 2. Clear out the phantom enemy arrays completely
	        global.active_battle_enemies = [];
        
	        // 3. Fire your file system load logic to trigger room_goto()
	        load_game();
        
	        // NOTE: DO NOT call instance_destroy() here! 
	        // Let this object live for one more frame so it can clean up in the Room End event.
	        exit;
	    } 
	    else {
	        // CHOICE: GIVE UP -> Bounce to main menu
	        if (instance_exists(obj_battle_controller)) {
	            with(obj_battle_controller) instance_destroy();
	        }
	        global.state = GAME_STATE.PLAYING; 
	        global.active_battle_enemies = []; 
        
	        if (room_exists(rm_menuRoom)) {
	            room_goto(rm_menuRoom);
	        } else {
	            game_end(); 
	        }
	        instance_destroy();
	        exit;
	    }
	}
}

// --- UPDATE CONFETTI PHYSICS ---
var _c_count = array_length(confetti_list);
for (var _i = 0; _i < _c_count; _i++) {
    var _c = confetti_list[_i];
    
    _c.vspeed += _c.gravity;
    _c.y += _c.vspeed;
    
    _c.oscillation_timer += _c.oscillation_speed;
    _c.x += _c.hspeed + sin(_c.oscillation_timer) * 0.5;
    
    _c.angle += _c.rot_speed;
    _c.scale_x = sin(_c.oscillation_timer * 2);

    if (_c.y > display_get_gui_height() + 20) {
        _c.y = random_range(-50, -10);
        _c.x = random_range(0, display_get_gui_width());
        _c.vspeed = random_range(2.0, 4.0);
    }
}

// --- UPDATE GOOFY FLOATING VECTOR ---
goofy_timer_x += goofy_drift_speed_x;
goofy_timer_y += goofy_drift_speed_y;

current_goofy_x = goofy_x + sin(goofy_timer_x) * goofy_range_x;
current_goofy_y = goofy_y + cos(goofy_timer_y) * goofy_range_y;