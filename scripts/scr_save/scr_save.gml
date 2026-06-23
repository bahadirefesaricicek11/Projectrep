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
	
	var _current_date = date_current_datetime();
	
	ini_open("save.ini");
	ini_write_string("SAVE","Name",global.player_name);
	ini_write_real("SAVE","Health",global.player_hp);
	ini_write_real("SAVE","Gold",global.player_gold);
	
	ini_write_real("DATA","Date", _current_date);
	ini_write_string("DATA","roomID",room_get_name(room));
	ini_write_real("DATA","x",obj_player.x);
	ini_write_real("DATA","y",obj_player.y);
	ini_write_real("DATA","player_face",obj_player.face);
	
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
        
        // 1. Read from "SAVE" section headers
        global.player_name = ini_read_string("SAVE","Name","");
        global.player_hp = ini_read_real("SAVE", "Health", 0);
        global.player_gold = ini_read_real("SAVE", "Gold", 0);
        
        // 2. Read from the correct "DATA" section headers
        var r_name = ini_read_string("DATA", "roomID", "");
        global.date = ini_read_real("DATA","Date", 0);
        var _target_x = ini_read_real("DATA","x", 0);
        var _target_y = ini_read_real("DATA","y", 0);
        
        ini_close();
        
        // 3. COMPLETE VISUAL RESET Pipeline
        shader_reset(); 
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        
        // Exterminate the persistent battle controller immediately during reloading
        if (instance_exists(obj_battle_controller)) {
            with (obj_battle_controller) {
                instance_destroy();
            }
        }
        
        // Force kill any residual active combat enemy entities
        if (variable_global_exists("active_battle_enemies") && is_array(global.active_battle_enemies)) {
            var _e_count = array_length(global.active_battle_enemies);
            for (var _e = 0; _e < _e_count; _e++) {
                var _enemy = global.active_battle_enemies[_e];
                if (instance_exists(_enemy)) {
                    instance_destroy(_enemy);
                }
            }
        }
        
        // 4. RESTORE WINDOW LAYOUT INTERFACE SCALE
        global.state = GAME_STATE.PLAYING; 
        display_set_gui_size(499, 280); 
        
        // 5. Run Room Restoration
        if (r_name == "")    
        {
            room_goto(rm_menuRoom);
        }
        else
        {
            var r = asset_get_index(r_name);
            if (r != -1 && asset_get_type(r_name) == asset_room)
            {
                room_goto(r);
                
                // 6. Enforce Overworld Instantiation coordinates
                if (instance_exists(obj_player)) {
                    obj_player.x = _target_x;
                    obj_player.y = _target_y;
                    obj_player.can_move = true;
                    obj_player.visible = true;
                    obj_player.image_alpha = 1.0;
                } else {
                    global.load_x = _target_x;
                    global.load_y = _target_y;
                }
            }
        }
        show_debug_message("Game Loaded. Canvas layer state cleared out completely.");
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
    ini_write_real("SETTINGS", "SFX", _vfx);
    ini_write_real("SETTINGS", "MUSIC",  _ost);
    ini_write_real("SETTINGS", "FULLSCREEN", _flscrn);
    ini_close();
}

function load_settings()
{
    if (file_exists("settings.ini"))
    {
        ini_open("settings.ini");
    
	    global.vol_master = ini_read_real("SETTINGS", "MASTER", 0);
	    global.vol_sfx = ini_read_real("SETTINGS", "SFX", 0);
	    global.vol_music = ini_read_real("SETTINGS", "MUSIC", 0);
    
	    global.fullscreen = ini_read_real("SETTINGS", "FULLSCREEN", 0);
	    if (global.fullscreen == 1) {
	        window_set_fullscreen(true);
	    } else {
	        window_set_fullscreen(false);
	    }
    
	    ini_close();
	}
}
	
	
	