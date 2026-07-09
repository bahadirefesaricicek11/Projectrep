/// @desc Saves game... duh.
function save_game()
{
    if (script_exists(save_room())) 
    {
        script_execute(save_room());
    }

    if (file_exists("save.ini")) file_delete("save.ini");
    
    ini_open("save.ini");
    
    ini_write_string("PLAYER", "Name", global.player_name);
    ini_write_real("PLAYER", "Health", global.player_hp);
    ini_write_real("PLAYER", "Gold", global.player_gold);
    ini_write_real("PLAYER", "Date", date_current_datetime());
    
    ini_write_string("SPAWN", "roomID", room_get_name(room));
    ini_write_real("SPAWN", "x", instance_exists(obj_player) ? obj_player.x : 0);
    ini_write_real("SPAWN", "y", instance_exists(obj_player) ? obj_player.y : 0);
    ini_write_real("SPAWN", "player_face", instance_exists(obj_player) ? obj_player.face : 0);
    
    var _inv_string = json_stringify(obj_item_manager.inv);
    ini_write_string("INVENTORY", "data", base64_encode(_inv_string));
    
    var _follower_list = [];
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "party_allies")) 
    {
        var _count = array_length(obj_player.party_allies);
        for (var i = 0; i < _count; i++) 
        {
            var _follower_entry = obj_player.party_allies[i];
            var _save_struct = { object_name: "obj_follower", sprite_name: "noone" };
            
            if (instance_exists(_follower_entry)) {
                _save_struct.object_name = object_get_name(_follower_entry.object_index);
                _save_struct.sprite_name = sprite_get_name(_follower_entry.sprite_index);
            } else if (object_exists(_follower_entry)) {
                _save_struct.object_name = object_get_name(_follower_entry);
            } else if (is_struct(_follower_entry)) {
                if (struct_exists(_follower_entry, "object_name")) _save_struct.object_name = _follower_entry.object_name;
                if (struct_exists(_follower_entry, "sprite"))      _save_struct.sprite_name = sprite_get_name(_follower_entry.sprite);
            }
            array_push(_follower_list, _save_struct);
        }
    }
    ini_write_string("PARTY", "followers", base64_encode(json_stringify(_follower_list)));
    
    var _room_db_string = json_stringify(global.room_states);
    ini_write_string("WORLD_STATE", "rooms", base64_encode(_room_db_string));
    
    ini_close();
    show_debug_message("Game State Saved Seamlessly.");
    
    if (file_exists("someone.txt")) file_delete("someone.txt");
    var _txt = file_text_open_write("someone.txt");
    file_text_write_string(_txt, "01001000 01000001 01001110 01001101 01000001 01001011 01000001 01010010");
    file_text_close(_txt);
}

/// @desc Aint gon tell this one
function load_game()
{   
    if (!file_exists("save.ini")) return false;
    
    ini_open("save.ini");
    
    global.state = GAME_STATE.PLAYING;
    global.active_battle_enemies = []; 
    shader_reset(); 
    draw_set_alpha(1.0);
    draw_set_color(c_white);
    
    global.player_name = ini_read_string("PLAYER", "Name", "Player");
    global.player_hp   = ini_read_real("PLAYER", "Health", 100);
    global.player_gold = ini_read_real("PLAYER", "Gold", 0);
    global.date        = ini_read_real("PLAYER", "Date", 0);
    
    var _room_name    = ini_read_string("SPAWN", "roomID", "");
    global.load_x    = ini_read_real("SPAWN", "x", 0);
    global.load_y    = ini_read_real("SPAWN", "y", 0);
    global.load_face = ini_read_real("SPAWN", "player_face", 0);
    
    var _inv_raw = ini_read_string("INVENTORY", "data", "");
    if (_inv_raw != "") obj_item_manager.inv = json_parse(base64_decode(_inv_raw));
    
    var _fol_raw = ini_read_string("PARTY", "followers", "");
    global.load_followers = (_fol_raw != "") ? json_parse(base64_decode(_fol_raw)) : [];
    
    var _rooms_raw = ini_read_string("WORLD_STATE", "rooms", "");
    if (_rooms_raw != "") {
        global.room_states = json_parse(base64_decode(_rooms_raw));
    } else {
        global.room_states = {};
    }
    
    ini_close();
    
    if (instance_exists(obj_battle_controller)) {
        with (obj_battle_controller) instance_destroy();
    }
    
    audio_stop_all();
    if (variable_instance_exists(obj_music_manager, "current_track")) {
        obj_music_manager.current_track = noone;
    }
    
    if (_room_name == "") 
    {
        room_goto(rm_menuRoom);
    }
    else
    {
        var _target_room = asset_get_index(_room_name);
        if (_target_room != -1 && asset_get_type(_room_name) == asset_room)
        {
            global.is_loading_save = true;
            room_goto(_target_room); 
        }
    }
    return true;
}

function save_settings()
{
    if (file_exists("settings.ini")) file_delete("settings.ini");
    
    ini_open("settings.ini");
    ini_write_real("SETTINGS", "MASTER", audio_get_master_gain(0));
    ini_write_real("SETTINGS", "SFX", audio_group_get_gain(audiogroup_sound));
    ini_write_real("SETTINGS", "MUSIC", audio_group_get_gain(audiogroup_music));
    ini_write_real("SETTINGS", "FULLSCREEN", window_get_fullscreen());
    ini_write_real("SETTINGS", "LANGUAGE", global.setting_language);
    ini_close();
}

function load_settings()
{
    global.setting_language = 0; 
    
    if (file_exists("settings.ini"))
    {
        ini_open("settings.ini");
        global.vol_master = ini_read_real("SETTINGS", "MASTER", 1);
        global.vol_sfx    = ini_read_real("SETTINGS", "SFX", 1);
        global.vol_music  = ini_read_real("SETTINGS", "MUSIC", 1);
        global.fullscreen = ini_read_real("SETTINGS", "FULLSCREEN", 0);
        global.setting_language = ini_read_real("SETTINGS", "LANGUAGE", 0);
        ini_close();
        
        window_set_fullscreen(global.fullscreen == 1);
    }
    
    load_locale(global.setting_language == 1 ? "tr" : "en");
}