function scr_text() {
	
	var _name = global.plrName;
	var _amount = 0;
    
    if (instance_exists(obj_player)) {
        _name = obj_player.name;
		global.plrName = obj_player.name
    }
    if (instance_exists(obj_gold_stack)) {
        _amount = obj_gold_stack.amount;
    }
	
	global.text = {};
	
	
	//-----------------INTRO---------------------
	global.text[$ "intro_cutscene"] = [
		EXECUTE(function(textbox) {
			obj_textbox.has_background = false;
			obj_textbox.text_speed = 0.3;
		}),
		TEXT("Your name is " + _name + "."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("You used to live in this house"),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("with your brother and your mom."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("Your mother is sick."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("You dont know where your brother is."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("You can't remember what happened."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("You need to go home."),
		EXECUTE(function(textbox) {
			obj_introcutscene.change=true;
		}),
		TEXT("You woke up in the middle of nowhere."),
		EXECUTE(function(textbox) {
			obj_textbox.text_speed = 0.5;
			scr_start_game();
		}),
	];
	//-----------------INTRO---------------------
	

	//--------------------------------------
	global.text[$ "Save 1"] = [
		CHOICE("Do you want to save?",
			OPTION("Yes", "Save Chose Yes"),
			OPTION("No", "Save Chose No"))
	];

	global.text[$ "Save Chose Yes"] = [
		EXECUTE(function(textbox) {
			save_game();
		}),
		TEXT("Saved!")
	];
	//SAVE DIALOGUE ------------------------

	//---------------------------------------------
	//ITEM DIALOGUE--------------------------------
	//---------------------------------------------
	global.text[$ "Item"] = [
		CHOICE("What do you want to do with this item?",
			OPTION("Use", "Item 1"),
			OPTION("Drop", "Item 2"))
	];
	global.text[$ "Item 1"] = [
		CHOICE("Do you want to use this item?",
			OPTION("Yes", "Item 1 Chose Yes"),
			OPTION("No", "Item 1 Chose No"))
	];

	global.text[$ "Item 1 Chose Yes"] = [
		EXECUTE(function(textbox) {
			item_use();
		}),
	];
	global.text[$ "Item 2"] = [
		CHOICE("Do you want to drop this item?",
			OPTION("Yes", "Item 2 Chose Yes"),
			OPTION("No", "Item 2 Chose No"))
	];

	global.text[$ "Item 2 Chose Yes"] = [
		EXECUTE(function(textbox) {
			item_remove();
		}),
	];
	//-----------------------------------------------------------
	//ITEM DIALOGUE ---------------------------------------------
	//-----------------------------------------------------------
	
	global.text[$ "gold"] = [
		TEXT("You got" + string(_amount) + "gold !"),
		EXECUTE(function(textbox) {
			gold_add(_amount);
		}),
	];

	global.text[$ "Bed 1"] = [
		TEXT("This is my bed."),
		TEXT("I dont want to sleep.")
	];
	global.text[$ "Door 1"] = [
		TEXT("This Door is Locked."),
	];
	global.text[$ "Window 1"] = [
		TEXT("Nice view."),
	];

	global.text[$ "NPC 1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey " + _name,
			OPTION("Hey", "npc1 opt1"),
			OPTION("...", "npc1 opt2"))	
	];
	global.text[$ "npc1 opt1"] = [
		SPEAKER(spr_main_portrait, PORTRAIT_SIDE.LEFT),
		TEXT("Hey."),
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		TEXT("i want to change colors!"),
		EXECUTE(function(textbox) {
			inst_32E4B1DD.sprite_index = spr_npc_alternate;
			inst_32E4B1DD.text_id = "NPC1_ALTERNATIVE";
		})
	];

	global.text[$ "NPC1_ALTERNATIVE"] = [
		SPEAKER(spr_portrait_1_alternate, PORTRAIT_SIDE.LEFT),
		TEXT("Hey! i want to change again"),
		EXECUTE(function(textbox) {
			inst_32E4B1DD.sprite_index = spr_npc;
			inst_32E4B1DD.text_id = "NPC 1";
		})
	];



	global.text[$ "NPC 2"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey.",
			OPTION("Hey", "npc2 opt1"),
			OPTION("...", "npc2 opt2"))	
	];
	global.text[$ "npc2 opt1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("You wanna fight?",
			OPTION("sure", "npc2 opt1_1"),
			OPTION("no", "npc2 opt2"))	
	];

	global.text[$ "npc2 opt1_1"] = [
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
	global.text[$ "NPC 3"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("Hey.",
			OPTION("Hey", "npc3 opt1"),
			OPTION("...", "npc3 opt2"))	
	];
	global.text[$ "npc3 opt1"] = [
		SPEAKER(spr_portrait_1, PORTRAIT_SIDE.LEFT),
		CHOICE("You want stuff?",
			OPTION("sure", "npc3 opt1_1"),
			OPTION("no", "npc3 opt2"))	
	];

	global.text[$ "npc3 opt1_1"] = [
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

	global.text[$ "Trigger 1"] = [
		TEXT("There is nothing after this."),
		EXECUTE(function(textbox) {
			instance_destroy(obj_textbox_trigger);
		})
	];
	global.text[$ "Trigger 2"] = [
		TEXT("There is still nothing."),
		EXECUTE(function(textbox) {
			instance_destroy(obj_textbox_trigger);
		})
	];
	
}
