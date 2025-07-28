// The one function that you need to call!
// Creates a textbox and starts a conversation.
// @param topic - What topic the dialogue box should use
function startDialogue(topic) {
	if (instance_exists(obj_textbox))
		return;
		
	var inst = instance_create_depth(x, y, -999, obj_textbox);
	inst.setTopic(topic);
}

function type(x, y, text, progress, width) {
    // Static variables persist between calls
    static previous_progress = 0;
    static last_sound_time = 0;
    
    // Only play sounds when progressing forward (not when rewinding)
    if (progress > previous_progress) {
        var ctime = get_timer();
        
        // Get the newly added character
        var new_char = string_char_at(text, progress);
        
        // Only play sound for visible characters (not spaces or newlines)
        if (new_char != " " && new_char != "\n" && ctime - last_sound_time > 10000) {
            // Play typing sound with slight pitch variation for realism
			if !audio_is_playing(snd_text_default)
			{
				audio_play_sound(snd_text_default, 0, false);
			}
            
			last_sound_time = ctime;
        }
    }
    previous_progress = progress;
    
    // Text drawing logic
    var draw_x = 0;
    var draw_y = 0;
    
    for (var i = 1; i <= progress; i++) {
        var char = string_char_at(text, i);
    
        // Handle normal line breaks
        if (char == "\n") {
            draw_x = 0;
            draw_y += string_height("A");
        }
        // Handle word wrapping
        else if (char == " ") {
            draw_x += string_width(char);
            
            var word_width = 0;
            for (var ii = i + 1; ii <= string_length(text); ii++) {
                var word_char = string_char_at(text, ii);
                
                // Stop at next whitespace
                if (word_char == "\n" || word_char == " ")
                    break;
                
                // Check if word would exceed width
                word_width += string_width(word_char);
                if (draw_x + word_width > width) {
                    draw_x = 0;
                    draw_y += string_height("A");
                    break;
                }
            }
        }
        // Draw regular characters
        else {
            draw_text(x + draw_x, y + draw_y, char);
            draw_x += string_width(char);
        }
    }
}