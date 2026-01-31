function scr_topics() {
	
	var _name = global.plrName;
    
    if (instance_exists(obj_player)) {
        _name = obj_player.name;
		global.plrName = obj_player.name
    }
	
	global.topics = {};

	//--------------------------------------
	global.topics[$ "Save 1"] = [
		CHOICE("Do you want to save?",
			OPTION("Yes", "Save Chose Yes"),
			OPTION("No", "Save Chose No"))
	];

	global.topics[$ "Save Chose Yes"] = [
		EXECUTE(function(textbox) {
			save_game();
		}),
		TEXT("Saved!")
	];
	//SAVE DIALOGUE ------------------------

	//---------------------------------------------
	//ITEM DIALOGUE--------------------------------
	//---------------------------------------------
	global.topics[$ "Item"] = [
		CHOICE("What do you want to do with this item?",
			OPTION("Use", "Item 1"),
			OPTION("Drop", "Item 2"))
	];
	global.topics[$ "Item 1"] = [
		CHOICE("Do you want to use this item?",
			OPTION("Yes", "Item 1 Chose Yes"),
			OPTION("No", "Item 1 Chose No"))
	];

	global.topics[$ "Item 1 Chose Yes"] = [
		EXECUTE(function(textbox) {
			item_use();
		}),
	];
	global.topics[$ "Item 2"] = [
		CHOICE("Do you want to drop this item?",
			OPTION("Yes", "Item 2 Chose Yes"),
			OPTION("No", "Item 2 Chose No"))
	];

	global.topics[$ "Item 2 Chose Yes"] = [
		EXECUTE(function(textbox) {
			item_remove();
		}),
	];
	//-----------------------------------------------------------
	//ITEM DIALOGUE ---------------------------------------------
	//-----------------------------------------------------------

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
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey " + obj_player.name,
			OPTION("Hey", "npc1 opt1"),
			OPTION("...", "npc1 opt2"))	
	];
	global.topics[$ "npc1 opt1"] = [
		SPEAKER(spr_main_portrait, PORTRAIT_SIDE.LEFT),
		TEXT("Hey."),
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		TEXT("i want to change colors!"),
		EXECUTE(function(textbox) {
			inst_32E4B1DD.sprite_index = spr_npc_alternate;
			inst_32E4B1DD.text_id = "NPC1_ALTERNATIVE";
		})
	];

	global.topics[$ "NPC1_ALTERNATIVE"] = [
		SPEAKER(spr_portrait_1_alternate, PORTRAIT_SIDE.LEFT),
		TEXT("Hey! i want to change again"),
		EXECUTE(function(textbox) {
			inst_32E4B1DD.sprite_index = spr_npc;
			inst_32E4B1DD.text_id = "NPC 1";
		})
	];



	global.topics[$ "NPC 2"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey.",
			OPTION("Hey", "npc2 opt1"),
			OPTION("...", "npc2 opt2"))	
	];
	global.topics[$ "npc2 opt1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("You wanna fight?",
			OPTION("sure", "npc2 opt1_1"),
			OPTION("no", "npc2 opt2"))	
	];

	global.topics[$ "npc2 opt1_1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		TEXT("i wont."),
		TEXT("here take this."),
		EXECUTE(function(textbox) {
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
			item_add(global.item_list.apple);
		})
	];
	global.topics[$ "NPC 3"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey.",
			OPTION("Hey", "npc3 opt1"),
			OPTION("...", "npc3 opt2"))	
	];
	global.topics[$ "npc3 opt1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("You want stuff?",
			OPTION("sure", "npc3 opt1_1"),
			OPTION("no", "npc3 opt2"))	
	];

	global.topics[$ "npc3 opt1_1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		TEXT("here take this."),
		EXECUTE(function(textbox) {
			item_add(global.item_list.iron_helmet);
			item_add(global.item_list.iron_chestplate);
			item_add(global.item_list.iron_bottom);
			item_add(global.item_list.normal_shield);
			item_add(global.item_list.iron_sword);
		})
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
}
