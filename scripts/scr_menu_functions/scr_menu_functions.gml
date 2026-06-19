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
	CARD_SELECTION,
    CUTSCENE,
    TITLE_SCREEN,
	GAMEOVER
}

global.state = GAME_STATE.TITLE_SCREEN;