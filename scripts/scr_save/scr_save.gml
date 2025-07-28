function save_game()
{
	if(file_exists("save.ini")){
		file_delete("save.ini");
	}
	
	var _current_date = date_current_datetime()

	ini_open("save.ini");
	ini_write_string("SAVE","roomID",room_get_name(room));
	ini_write_string("SAVE","name",obj_player.name);
	ini_write_real("SAVE","Date", _current_date);
	ini_write_real("SAVE","x",obj_player.x);
	ini_write_real("SAVE","y",obj_player.y);
	ini_write_real("SAVE","player_face",obj_player.face);
	
	
	ini_close();
	show_debug_message("Game Saved");
}
function load_game()
{	
	
	if(file_exists("save.ini"))
	{
		
		
		ini_open("save.ini");
		var r_name = ini_read_string("SAVE", "roomID", "");
		obj_player.name = ini_read_string("SAVE","name","");
		global.date = ini_read_real("SAVE","Date", 0);
		obj_player.x = ini_read_real("SAVE","x", 0);
		obj_player.y = ini_read_real("SAVE","y", 0);
		
		ini_close();
		
		if r_name == ""	
		{
			room_goto(rm_side_screen);
		}
		else
		{
			var r = asset_get_index(r_name);
			if r != -1 and asset_get_type(r_name) == asset_room
			{
				room_goto(r);
			}
		}
		
		
		
		show_debug_message("Game Loaded");
		obj_player.can_move = true;
	}
}