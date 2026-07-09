function play_music(_sound, _force = false){
    if (!instance_exists(obj_music_manager)) return;
    
    with (obj_music_manager) {
        // PROTECTION: If we are already playing OR already fading into this exact song, DO NOTHING.
        if ((current_track == _sound || next_track == _sound) && !_force) return;
        
        // If no music is playing currently, skip fade out and go straight to fade in
        if (current_track == noone || _force) {
            if (audio_exists(current_instance)) audio_stop_sound(current_instance);
            current_track = _sound;
            if (_sound != noone) {
                current_instance = audio_play_sound(current_track, 10, true);
                audio_sound_gain(current_instance, 0, 0);
                fade_timer = 0;
                fade_state = "fading_in";
            }
        } else {
            // Standard crossfade trigger
            next_track = _sound;
            fade_timer = fade_time; 
            fade_state = "fading_out";
        }
    }
}