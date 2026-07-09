display_set_gui_size(384,216);


// --- Room-Based Music Management ---
if (room == rm_gameOver) {
    play_music(msc_game_over);
}
else if (room == rm_menuRoom) {
    play_music(msc_menu);
}
else if (room == rm_introCutscene) {
    play_music(msc_first_cutscene_theme);
}
