function save_game()
{
	if(file_exists("invData.ini"))
	{
		file_delete("invData.ini")	
	}
	
	
	var _invData = json_stringify(obj_item_manager.inv);
	var _invDataENCD = base64_encode(_invData);
	
	ini_open("invData.ini");
	ini_write_string("INVENTORY","data", _invDataENCD);
	ini_close();
	
	if(file_exists("save.ini")){
		file_delete("save.ini");
	}
	
	var _current_date = date_current_datetime()
	

	ini_open("save.ini");
	ini_write_string("SAVE","roomID",room_get_name(room));
	ini_write_string("SAVE","Name",obj_player.name);
	ini_write_real("SAVE","Health",global.player_hp);
	ini_write_real("SAVE","Gold",global.player_gold);
	
	ini_write_real("SAVE","Date", _current_date);
	ini_write_real("SAVE","x",obj_player.x);
	ini_write_real("SAVE","y",obj_player.y);
	ini_write_real("SAVE","player_face",obj_player.face);
	
	ini_close();
	show_debug_message("Game Saved");
	
	
	if(file_exists("someone.txt")){
		file_delete("someone.txt");
	}
	
	ini_open("someone.txt");
	ini_write_string("Message", "TEXT", "01001000 01000001 01001110 01001101 01000001 01001011 01000001 01010010")
	ini_close();
}
function load_game()
{	
	if(file_exists("invData.ini"))
	{
		ini_open("invData.ini");
		var _invENCD = ini_read_string("INVENTORY", "data", "");
		var invdataDCD = base64_decode(_invENCD);
		obj_item_manager.inv = json_parse(invdataDCD);
		ini_close();
	}
	
	if(file_exists("save.ini"))
	{
		
		
		
		ini_open("save.ini");
		var r_name = ini_read_string("SAVE", "roomID", "");
		obj_player.name = ini_read_string("SAVE","Name","");
		global.player_hp = ini_read_real("SAVE", "Health", 0);
		global.player_gold = ini_read_real("SAVE", "Gold", 0);
		
		global.date = ini_read_real("SAVE","Date", 0);
		obj_player.x = ini_read_real("SAVE","x", 0);
		obj_player.y = ini_read_real("SAVE","y", 0);
		ini_close();
		
		
		if r_name == ""	
		{
			room_goto(rm_menuRoom);
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

function save_settings()
{
	if(file_exists("settings.ini")){
		file_delete("settings.ini");
	}
	
    var _master = audio_get_master_gain(0); 
    var _vfx    = audio_group_get_gain(audiogroup_sound);
    var _ost    = audio_group_get_gain(audiogroup_music);
    var _flscrn = window_get_fullscreen();
    
    ini_open("settings.ini");
    ini_write_real("SETTINGS", "MASTER", _master);
    ini_write_real("AUSETTINGSDIO", "SFX", _vfx);
    ini_write_real("SETTINGS", "MUSIC",  _ost);
    ini_write_real("SETTINGS", "FULLSCREEN", _flscrn);
    ini_close();
}

function load_settings()
{
    if (file_exists("settings.ini"))
    {
        ini_open("settings.ini");
    
	    // Read your audio settings...
	    global.vol_master = ini_read_real("SETTINGS", "MASTER", 1);
	    global.vol_sfx = ini_read_real("SETTINGS", "SFX", 1);
	    global.vol_music = ini_read_real("SETTINGS", "MUSIC", 1);
    
	    // Read and apply the fullscreen setting
	    var _fs = ini_read_real("SETTINGS", "FULLSCREEN", 0);
	    if (_fs == 1) {
	        window_set_fullscreen(true);
	    } else {
	        window_set_fullscreen(false);
	    }
    
	    ini_close();
	}
}
	
	
	