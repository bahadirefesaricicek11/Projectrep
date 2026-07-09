var _dt = 1 / room_speed; 

switch (fade_state) {
    case "idle":
        break;
        
    case "fading_out":
        if (fade_timer > 0) {
            fade_timer -= _dt;
            var _vol = (fade_timer / fade_time) * max_volume;
            if (audio_exists(current_instance)) {
                audio_sound_gain(current_instance, _vol, 0);
            }
        } else {
            if (audio_exists(current_instance)) {
                audio_stop_sound(current_instance);
            }
            
            current_track = next_track;
            next_track = noone;
            
            if (current_track != noone) {
                current_instance = audio_play_sound(current_track, 10, true);
                audio_sound_gain(current_instance, 0, 0);
                fade_timer = 0;
                fade_state = "fading_in";
            } else {
                current_instance = noone;
                fade_state = "idle";
            }
        }
        break;
        
    case "fading_in":
        if (fade_timer < fade_time) {
            fade_timer += _dt;
            var _vol = (fade_timer / fade_time) * max_volume;
            if (audio_exists(current_instance)) {
                audio_sound_gain(current_instance, _vol, 0);
            }
        } else {
            if (audio_exists(current_instance)) {
                audio_sound_gain(current_instance, max_volume, 0);
            }
            fade_state = "idle";
        }
        break;
}