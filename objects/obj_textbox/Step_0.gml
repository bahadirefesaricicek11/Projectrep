
text_progress = min(text_progress + text_speed, text_length);


cursorLevitate = dsin(cursorTime);
cursorTime += leviRate;

// ... (Keep your text_progress accumulation here) ...

if (input_delay > 0) {
    input_delay--;
    exit;
}

// Check if the current line of text has finished typing out
if (text_progress == text_length) {
    
    // --- NEW: AUTO-ADVANCE LOGIC ---
    if (is_auto_advance) {
        auto_advance_timer++;
        
        if (auto_advance_timer >= auto_advance_max_delay) {
            auto_advance_timer = 0; // Reset the timer
            next();                 // Move to the next text block automatically
        }
        exit; // Exit the event early so player input below isn't read!
    }
    // --------------------------------
    
    // Your original manual player input logic goes here:
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
else if (InputPressed(INPUT_VERB.ACCEPT) || InputPressed(INPUT_VERB.CANCEL)) {
    // Only allow manual text acceleration if auto-advance is turned OFF
    if (!is_auto_advance && text_skippable == true) {
        text_progress = text_length;
    }
}