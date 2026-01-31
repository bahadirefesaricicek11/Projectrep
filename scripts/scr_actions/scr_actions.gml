#macro TEXT new TextAction
#macro SPEAKER new SpeakerAction
#macro CHOICE new ChoiceAction
#macro OPTION new OptionAction
#macro GOTO new GotoAction
#macro EXECUTE new ExecuteAction

function DialogueAction() constructor {
	act = function() { };
}

function TextAction(_text) : DialogueAction() constructor {
	text = _text;

	act = function(textbox) {
		textbox.setText(text);
	}
}

function SpeakerAction(_sprite = undefined, _side = undefined): DialogueAction() constructor {
	sprite = _sprite;
	side = _side;

	act = function(textbox) {
		
		if (!is_undefined(sprite))
			textbox.portrait_sprite = sprite;
			
		if (!is_undefined(side))
			textbox.portrait_side = side;
			
		textbox.next();
	}
}

function ChoiceAction(_text) : DialogueAction() constructor {
	text = _text;

	options = [];
	for (var i = 1; i < argument_count; i++)
		array_push(options, argument[i]);

	act = function(textbox) {
		textbox.setText(text);
		textbox.options = options;
		textbox.option_count = array_length(options);
		textbox.current_option = 0;
	}
}

function OptionAction(_text, _topic): DialogueAction() constructor {
	text = _text;
	topic = _topic;

	act = function(textbox) {
		textbox.setTopic(topic);
	}
}

function GotoAction(_topic): DialogueAction() constructor {
	topic = _topic;

	act = function(textbox) {
		textbox.setTopic(topic);
	}
}
function ExecuteAction(_action): DialogueAction() constructor {
	action = _action;
	
	act = function(textbox) {
		action(textbox);
		obj_textbox.next();
	}
}
