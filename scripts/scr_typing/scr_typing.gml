function startDialogue(topic, _sequence_element_id = noone) {
    if (instance_exists(obj_textbox))
        return;
        
    var spawn_x = variable_instance_exists(id, "x") ? x : 0;
    var spawn_y = variable_instance_exists(id, "y") ? y : 0;
        
    var inst = instance_create_depth(spawn_x, spawn_y, -999, obj_textbox);
    
    inst.sequence_to_resume = _sequence_element_id; 
    
    inst.setTopic(topic);
}

function type(x, y, text, progress, width) {
    static previous_char_index = 0;
    static last_sound_time = 0;
    
    var current_char_index = floor(progress);
    
    // --- TYPEWRITER AUDIO PLAYBACK ---
    // Play sound ONLY when stepping onto a NEW integer character index
    if (current_char_index > previous_char_index && current_char_index <= string_length(text)) {
        var ctime = get_timer();
        var new_char = string_char_at(text, current_char_index);
        
        if (new_char != " " && new_char != "\n") {
            // Rate-limit sound slightly (60,000 microseconds = 60ms)
            if (ctime - last_sound_time > 60000) { 
                audio_play_sound(snd_text_default, 1, false);
                last_sound_time = ctime;
            }
        }
    }
    previous_char_index = current_char_index;
    
    // --- TEXT DRAWING PREPARATION ---
    var _base_scale = 0.75; 
    var draw_x = 0;
    var draw_y = 0;
    
    var timer_sec = get_timer() / 1000000;
    
    var has_effects = variable_instance_exists(id, "effects_map") && is_array(effects_map);
    var default_font = draw_get_font();
    
    // --- UNIFORM LINE STEP ---
    draw_set_font(default_font);
    var line_step = string_height("A") * _base_scale;
    
    // Render loop up to the current revealed character count
    for (var i = 1; i <= current_char_index; i++) {
        var char = string_char_at(text, i);
        
        // Retrieve character-specific font & scale overrides
        var char_font = default_font;
        var char_custom_scale = 1.0; 
        
        if (has_effects && (i - 1) < array_length(effects_map)) {
            char_font = effects_map[i - 1].font;
            char_custom_scale = effects_map[i - 1].scale; 
        }
        draw_set_font(char_font);
        
        var final_scale = _base_scale * char_custom_scale;
        
        // Handle newlines
        if (char == "\n") {
            draw_x = 0;
            draw_y += line_step;
        }
        // Handle spaces & word-wrapping lookahead
        else if (char == " ") {
            draw_x += string_width(char) * final_scale;
            
            var word_width = 0;
            for (var ii = i + 1; ii <= string_length(text); ii++) {
                var word_char = string_char_at(text, ii);
                if (word_char == "\n" || word_char == " ")
                    break;
                
                var lookahead_font = default_font;
                var lookahead_custom_scale = 1.0;
                if (has_effects && (ii - 1) < array_length(effects_map)) {
                    lookahead_font = effects_map[ii - 1].font;
                    lookahead_custom_scale = effects_map[ii - 1].scale;
                }
                draw_set_font(lookahead_font);
                
                var lookahead_final_scale = _base_scale * lookahead_custom_scale;
                word_width += string_width(word_char) * lookahead_final_scale;
                
                if (draw_x + word_width > width) {
                    draw_x = 0;
                    draw_y += line_step;
                    break;
                }
            }
            draw_set_font(char_font);
        }
        // Handle printable characters
        else {
            var offset_x = 0;
            var offset_y = 0;
            
            var c_tl = c_white, c_tr = c_white, c_bl = c_white, c_br = c_white;
            
            if (has_effects && (i - 1) < array_length(effects_map)) {
                var effect = effects_map[i - 1];
                
                c_tl = effect.color_tl;
                c_tr = effect.color_tr;
                c_bl = effect.color_bl;
                c_br = effect.color_br;
                
                // Baseline alignment offset calculation
                if (char_font != default_font || char_custom_scale != 1.0) {
                    draw_set_font(default_font);
                    var default_height = string_height("A") * _base_scale;
                    
                    draw_set_font(char_font);
                    var custom_height = string_height("A") * final_scale;
                    
                    offset_y += (default_height - custom_height);
                }
                
                // Shake Effect
                if (effect.shake) {
                    offset_x += random_range(-1, 1);
                    offset_y += random_range(-1, 1);
                }
                
                // Wave Effect
                if (effect.wave) {
                    var wave_speed = 8;
                    var wave_frequency = 0.5;
                    var wave_amplitude = 1.5;
                    offset_y += sin((timer_sec * wave_speed) + (i * wave_frequency)) * wave_amplitude;
                }
                
                // Rainbow Effect
                if (effect.rainbow) {
                    var hue = (timer_sec * 120 + (i * 10)) % 255;
                    var rainbow_col = make_color_hsv(hue, 220, 255);
                    c_tl = rainbow_col;
                    c_tr = rainbow_col;
                    c_bl = rainbow_col;
                    c_br = rainbow_col;
                }
            }
            
            // Render character
            draw_text_transformed_color(
                x + draw_x + offset_x, 
                y + draw_y - 2 + offset_y, 
                char, 
                final_scale, 
                final_scale, 
                0, 
                c_tl, 
                c_tr, 
                c_bl, 
                c_br, 
                1.0 
            );
            
            draw_x += string_width(char) * final_scale;
        }
    }
    
    // Reset canvas draw state
    draw_set_font(default_font);
    draw_set_color(c_white);
}