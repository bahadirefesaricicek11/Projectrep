function scr_send_nameScreen(){
    room_goto(rm_nameScreen);
}

function scr_start_game(){
    global.state = GAME_STATE.PLAYING;
	obj_player.x = 255;
	obj_player.y = 180;
	
	// 1. Wipe the master room database and loading queues
    global.room_states = {};
    global.load_followers = []; 
    
    // 2. Clear out the live Player and their internal party arrays
    if (instance_exists(obj_player)) 
    {
        with (obj_player) 
        {
            // Clear the actual party array so it stops tracking old followers
            if (variable_instance_exists(id, "party_allies")) {
                party_allies = []; 
            }
        }
    }
    
    // 3. Destroys any active follower instances floating around the current room
    if (instance_exists(obj_follower)) 
    {
        with (obj_follower) instance_destroy(id, false);
    }
    
    // 5. Clear transient scene and battle engine data
    global.active_battle_enemies = [];
    global.is_loading_save = false;
    
    // 6. Send the player back to the very first gameplay level
    room_goto(rm_forest_1);
}