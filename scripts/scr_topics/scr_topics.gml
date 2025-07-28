global.topics = {};

//--------------------------------------
global.topics[$ "Save 1"] = [
	CHOICE("Do you want to save?",
		OPTION("Yes", "Save Chose Yes"),
		OPTION("No", "Save Chose No"))
];

global.topics[$ "Save Chose Yes"] = [
	TEXT("Saved!"),
	EXECUTE(function(textbox) {
		save_game();
	})
];
//SAVE DIALOGUE ------------------------

global.topics[$ "Bed 1"] = [
	TEXT("This is my bed."),
	TEXT("I dont want to sleep.")
];
global.topics[$ "Door 1"] = [
	TEXT("This Door is Locked."),
];
global.topics[$ "Window 1"] = [
	TEXT("Nice view."),
];

global.topics[$ "NPC 1"] = [
	SPEAKER("Dumbass nigger", spr_portrait_1, PORTRAIT_SIDE.LEFT),
	TEXT("Niggers," + global.plrName),
];
global.topics[$ "NPC 2"] = [
	TEXT("Still yo."),
];

global.topics[$ "Trigger 1"] = [
	TEXT("There is nothing after this."),
	EXECUTE(function(textbox) {
		instance_destroy(obj_textbox_trigger);
	})
];
global.topics[$ "Trigger 2"] = [
	TEXT("There is still nothing."),
	EXECUTE(function(textbox) {
		instance_destroy(obj_textbox_trigger);
	})
];
