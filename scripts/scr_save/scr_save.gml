function save_game()
{	;
	if(file_exists("save.ini")){
		file_delete("save.ini");
	}
	
	var pface = asset_get_index(obj_player.sprite_index);

	ini_open("save.ini");
	ini_write_string("Save1","roomID",room_get_name(room));
	ini_write_real("Save1","x",obj_player.x);
	ini_write_real("Save1","y",obj_player.y);
	ini_write_string("Save1","player_face",pface);
	ini_close();
	show_debug_message("Game Saved");
}
function load_game()
{	
	if(file_exists("save.ini"))
	{
		ini_open("save.ini");
		var r_name = ini_read_string("Save1", "roomID", "");

		obj_player.x = ini_read_real("Save1","x", 0);
		obj_player.y = ini_read_real("Save1","y", 0);
		obj_player.sprite_index = ini_read_string("Save1","player_face", "");
		
		
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
	}
}