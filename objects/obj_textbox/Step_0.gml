
text_progress = min(text_progress + text_speed, text_length);

cursorLevitate = dsin(cursorTime);
cursorTime += leviRate;

if (input_delay > 0) {
	input_delay--;
	exit;
}

if (text_progress == text_length) {
	if (option_count > 0) {
		
		var change = InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP);
		if (change != 0) {
			current_option += change;
		
			if (current_option < 0)
				current_option = option_count - 1;
			else if (current_option >= option_count)
				current_option = 0;
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
	text_progress = text_length;
}
