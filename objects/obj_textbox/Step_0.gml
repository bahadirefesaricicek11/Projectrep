// Update cursor floating math
cursorLevitate = dsin(cursorTime);
cursorTime += leviRate;

// Manage initial input delay gate
if (input_delay > 0) {
    input_delay--;
    exit;
}

// 1. Tick down active pause timer
if (variable_instance_exists(id, "pause_timer") && pause_timer > 0) {
    pause_timer--;
    exit; // Halt typewriter progression while paused
}

// 2. Advance typewriter progress
if (text_progress < text_length) {
    var _prev_idx = floor(text_progress);
    
    text_progress += text_speed;
    
    // Clamp to length so text_progress >= text_length evaluates cleanly
    if (text_progress >= text_length) {
        text_progress = text_length;
    }
    
    var _curr_idx = floor(text_progress);
    
    // Check for pause tag on newly revealed character
    if (_curr_idx > _prev_idx && _curr_idx <= text_length) {
        if (variable_instance_exists(id, "effects_map") && array_length(effects_map) >= _curr_idx) {
            var _char_data = effects_map[_curr_idx - 1];
            if (variable_struct_exists(_char_data, "pause") && _char_data.pause > 0) {
                pause_timer = _char_data.pause;
            }
        }
    }
}

// --- INPUT & BRANCHING ---
if (text_progress == text_length) {
    
    if (is_auto_advance) {
        auto_advance_timer++;
        
        if (auto_advance_timer >= auto_advance_max_delay) {
            auto_advance_timer = 0;
            next();
        }
        exit;
    }
    
    if (option_count > 0) {
        var change = InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP);
        if (change != 0) {
            current_option += change;
            if (current_option < 0) current_option = option_count - 1;
            else if (current_option >= option_count) current_option = 0;
        }
        
        if (InputPressed(INPUT_VERB.ACCEPT)) {
            var option = options[current_option];
            options = [];
            option_count = 0;
            option.act(id);
        }
    }
    else if (InputPressed(INPUT_VERB.ACCEPT)) {
        next();
    }
}
else if (InputPressed(INPUT_VERB.CANCEL)) {
    if (!is_auto_advance && text_skippable == true) {
        text_progress = text_length;
        pause_timer = 0; // Instantly dump active pauses if skipped
    }
}