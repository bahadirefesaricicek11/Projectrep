enum menu_page {
    main,       // 0
    settings,   // 1
    audio,      // 2
    graphics    // 3
}

enum menu_element_type {
    script_runner,
    page_transfer,
    slider,
    shift,
    toggle
}

// 1. Define the states (if you haven't already done this elsewhere)
enum GAME_STATE {
    PLAYING,
    MENU,
    BATTLE,
    CUTSCENE,
    TITLE_SCREEN
}

// 2. Initialize the global variable so it exists from microsecond one!
// If your game boots directly into the main menu room:
global.state = GAME_STATE.TITLE_SCREEN; 

// (Optional) If you are bypassing the main menu for testing and booting straight into a test room:
// global.state = GAME_STATE.PLAYING;