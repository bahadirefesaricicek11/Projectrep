function startDialogue(topic) {
	if (instance_exists(obj_textbox))
		return;
		
	var inst = instance_create_depth(x, y, -999, obj_textbox);
	inst.setTopic(topic);
}

function type(x, y, text, progress, width) {
    
    static previous_progress = 0;
    static last_sound_time = 0;
    
    if (progress > previous_progress) {
        var ctime = get_timer();
        
        var new_char = string_char_at(text, progress);
        
        if (new_char != " " && new_char != "\n") {
			
            if (ctime - last_sound_time > 60000) { 
                
                audio_play_sound(snd_text_default, 1, false);
                last_sound_time = ctime;
            }
        }
    }
    previous_progress = progress;
    
    
    var draw_x = 0;
    var draw_y = 0;
    
    for (var i = 1; i <= progress; i++) {
        var char = string_char_at(text, i);
    
        if (char == "\n") {
            draw_x = 0;
            draw_y += string_height("A")-8;
        }
        else if (char == " ") {
            draw_x += string_width(char);
            
            var word_width = 0;
            for (var ii = i + 1; ii <= string_length(text); ii++) {
                var word_char = string_char_at(text, ii);
                
                if (word_char == "\n" || word_char == " ")
                    break;
                
                word_width += string_width(word_char);
                if (draw_x + word_width > width) {
                    draw_x = 0;
                    draw_y += string_height("A")-8;
                    break;
                }
            }
        }
        else {
            draw_text(x + draw_x, y + draw_y-4, char);
            draw_x += string_width(char);
        }
    }
}