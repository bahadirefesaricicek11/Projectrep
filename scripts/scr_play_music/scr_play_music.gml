function scr_play_music(_sound_index, _loop = true) {
    if (!audio_is_playing(_sound_index)) {
        audio_play_sound(_sound_index, 10, _loop);
    }
}