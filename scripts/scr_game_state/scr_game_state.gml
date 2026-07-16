enum GAME_STATE {
    PLAYING,
    MENU,
    BATTLE,
    CARD_SELECTION,
    CUTSCENE,
    TITLE_SCREEN,
    GAMEOVER
}

/// @desc Safely updates global.state and handles side effects
/// @param {real} target_state The GAME_STATE enum constant
function set_game_state(target_state) {
    if (global.state == target_state) exit;
    
    // 1. CLEANUP OLD STATE
    switch (global.state) {
        case GAME_STATE.PLAYING:
            // Stop the player from sliding when transitioning to menus/battles
            if (instance_exists(obj_player)) {
                obj_player.hspeed = 0;
                obj_player.vspeed = 0;
            }
            break;
    }
    
    // 2. SET NEW STATE
    global.state = target_state;
    
    // 3. INITIALIZE NEW STATE
    switch (global.state) {
        case GAME_STATE.BATTLE:
            // Perform any automatic battle scene UI resets here
            break;
    }
}