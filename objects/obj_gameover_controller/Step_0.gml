// Step Event of obj_gameover_controller
if (InputPressed(INPUT_VERB.ACCEPT)) {
    if (script_exists(load_game)) {
        load_game();
    } else {
        // Fallback safety trigger in case data layer is uninitialized
        game_restart(); 
    }
}