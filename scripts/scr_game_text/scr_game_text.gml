function scr_game_text(_text_id){
	switch(_text_id) {
		case "bed 1":
		scr_text("This is my bed.");
		scr_text("I dont want to sleep.");
		break;
		
		
		case "npc 1":
		scr_text("Yo wadup gang");
		break;
		
		case "npc 2":
		scr_text("why u follow me dawg");
		break;
		
		
		case "trigger 1":
		scr_text("there is nothing after this point");
		break;
		
		case "trigger 2":
		scr_text("there is still nothing after this point");
		break;
		
		
		
		case "save 1":
			scr_text("Do You want to save?");
			scr_option("Yes", "save - yes");
			scr_option("No", "save - no");
		break;
		
		case "save - yes":
			scr_text("Saved!");
			save_game()
		break;
		
		case "save - no":
			scr_text("Closing...");
			instance_destroy(obj_textbox)
		break;
		
	}
}

