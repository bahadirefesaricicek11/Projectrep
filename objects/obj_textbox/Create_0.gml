max_input_delay = 0;
input_delay = max_input_delay;
sequence_to_resume = noone;

image_speed = 0.05;

margin = 4;
padding = 8;
width = display_get_gui_width() - (margin + 44);
height = ((display_get_gui_height() - margin)/2.5);

x = (display_get_gui_width() - width) / 2;
y = display_get_gui_height() - height - margin;

text_font = Project_Font;
text_color = c_white;
text_speed = 0.3;
text_x = padding + 5;
text_y = padding;
text_width = width - padding * 2;

has_background = true;
background = spr_textbox;
option_background = spr_option;

is_auto_advance = false;
auto_advance_max_delay = 90;
auto_advance_timer = 0;

text_skippable = true;

portrait_x = padding +3;
portrait_y = padding +2;

option_x = 0;
option_y = padding * -1.5;
option_spacing = 22;
option_selection_indent = 24;
option_height = 20;
option_text_x = 8;
option_text_y = 0;
option_text_color = c_white;

actions = [];
current_action = -1;

text = "";
text_progress = 0;
text_length = 0;

// --- PAUSE & EFFECTS MAP ADDITIONS ---
pause_timer = 0;
effects_map = [];

portrait_sprite = -1;
portrait_width = sprite_get_width(spr_portrait);
portrait_height = sprite_get_height(spr_portrait);

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
        if (variable_instance_exists(id, "sequence_to_resume") && sequence_to_resume != noone) {
            layer_sequence_play(sequence_to_resume);
        } else {
            if (instance_exists(obj_player)) obj_player.can_move = true;
        }
        
        instance_destroy();
    }
    else {
        actions[current_action].act(id);
    }
}

setText = function(newText) {
    pause_timer = 0; // Clear residual pauses from previous dialogue box
    
    var parsed = parse_text_effects(newText);
    text = parsed.clean_text;
    effects_map = parsed.effects;
    
    text_length = string_length(text);
    text_progress = 0;
}

selectLerp = current_option;
cursorLevitate = 0;
cursorTime = 0;
leviRate = 10;

scr_text();