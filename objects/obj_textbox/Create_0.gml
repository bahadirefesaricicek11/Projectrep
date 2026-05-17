max_input_delay = 0;
input_delay = max_input_delay;

margin = 8;
padding = 8;
width = display_get_gui_width() - margin * 2;
height = (display_get_gui_height() - margin)/3;

x = (display_get_gui_width() - width) / 2;
y = display_get_gui_height() - height - margin;

text_font = Project_Font;
text_color = c_white;
text_speed = 0.3;
text_x = padding + 20;
text_y = padding;
text_width = width - padding * 2;

has_background = true;

text_skippable = true;

portrait_x = padding + 20;
portrait_y = padding;

option_x = padding;
option_y = padding * -2.5;
option_spacing = 25;
option_selection_indent = 24;
option_width = 53;
option_height = 24;
option_text_x = 5;
option_text_y = 3;
option_text_color = c_white;

actions = [];
current_action = -1;

text = "";
text_progress = 0;
text_length = 0;

portrait_sprite = -1;
portrait_width = sprite_get_width(spr_portrait);
portrait_height = sprite_get_height(spr_portrait);
portrait_side = PORTRAIT_SIDE.LEFT;

enum PORTRAIT_SIDE {
	LEFT,
	RIGHT
}

speaker_name = "";
speaker_width = sprite_get_width(spr_name);
speaker_height = sprite_get_height(spr_name);

options = [];
current_option = 0;
option_count = 0;

var topic = "";

setTopic = function(topic) {
	actions = global.text[$ topic];
	current_action = -1;
		
	next();
}

next = function() {
	current_action++;
	if (current_action >= array_length(actions)) {
		instance_destroy();
		obj_player.can_move = true;
	}
	else {
		actions[current_action].act(id);
	}
}

setText = function(newText) {
	text = newText;
	text_length = string_length(newText);
	text_progress = 0;
}

selectLerp = current_option;
cursorLevitate = 0;
cursorTime = 0;
leviRate = 10;