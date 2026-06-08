enum menu_page {
    main,
    settings,
    audio,
    graphics
}

enum menu_element_type {
    script_runner,
    page_transfer,
    slider,
    shift,
    toggle
}

enum GAME_STATE {
    PLAYING,
    MENU,
    BATTLE,
    CUTSCENE,
    TITLE_SCREEN
}

global.state = GAME_STATE.TITLE_SCREEN;