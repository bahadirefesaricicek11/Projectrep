/// @desc Saves game state split across player.json and world.json (with Equipment Support)
function save_game()
{
    // 1. Run room save logic to update global.room_states
    if (is_callable(save_room)) 
    {
        save_room();
    }
    else if (script_exists(asset_get_index("save_room")))
    {
        script_execute(asset_get_index("save_room"));
    }

    // Helper method to convert an item struct into a serialized ID/count struct
    var _serialize_item = function(_item) {
        if (!is_struct(_item)) return undefined;
        
        var _db_key = string_replace(_item.name_key, "items.", "");
        _db_key = string_replace(_db_key, ".name", "");
        
        return {
            id: _db_key,
            count: struct_exists(_item, "count") ? _item.count : 1
        };
    };

    // 2. Map inventory references
    var _inv_save = [];
    var _inv_length = array_length(obj_item_manager.inv);
    
    for (var i = 0; i < _inv_length; i++) {
        var _item = obj_item_manager.inv[i];
        var _packed = _serialize_item(_item);
        if (_packed != undefined) array_push(_inv_save, _packed);
    }

    // 3. Map Equipped Items Array (Maintains exact 5-slot index mapping)
    var _equipped_save = [];
    if (instance_exists(obj_item_manager) && variable_instance_exists(obj_item_manager, "equipped")) {
        var _eq_len = array_length(obj_item_manager.equipped);
        for (var i = 0; i < _eq_len; i++) {
            var _eq_item = obj_item_manager.equipped[i];
            array_push(_equipped_save, _serialize_item(_eq_item));
        }
    }

    // 4. Construct PLAYER DATA STRUCT
    var _player_data = {
        player: {
            name: global.player_name,
            hp: global.player_hp,
            gold: global.player_gold,
            date: date_current_datetime()
        },
        spawn: {
            room_name: room_get_name(room),
            x: instance_exists(obj_player) ? obj_player.x : 0,
            y: instance_exists(obj_player) ? obj_player.y : 0,
            face: instance_exists(obj_player) ? obj_player.face : 0
        },
        inventory: _inv_save,
        equipped: _equipped_save,
        party: []
    };

    // Serialize Followers into player struct
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "party_allies")) 
    {
        var _count = array_length(obj_player.party_allies);
        for (var i = 0; i < _count; i++) 
        {
            var _follower_entry = obj_player.party_allies[i];
            var _save_struct = { object_name: "obj_follower", sprite_name: "noone" };
            
            if (is_string(_follower_entry)) 
            {
                _save_struct.object_name = _follower_entry;
            } 
            else if (is_struct(_follower_entry)) 
            {
                if (struct_exists(_follower_entry, "object_name")) _save_struct.object_name = _follower_entry.object_name;
                if (struct_exists(_follower_entry, "sprite"))      _save_struct.sprite_name = sprite_get_name(_follower_entry.sprite);
            } 
            else if (_follower_entry != noone && _follower_entry != undefined) 
            {
                if (instance_exists(_follower_entry)) 
                {
                    _save_struct.object_name = object_get_name(_follower_entry.object_index);
                    _save_struct.sprite_name = sprite_get_name(_follower_entry.sprite_index);
                } 
                else if (object_exists(_follower_entry)) 
                {
                    _save_struct.object_name = object_get_name(_follower_entry);
                }
            }
            array_push(_player_data.party, _save_struct);
        }
    }

    // 5. Construct WORLD DATA STRUCT
    var _world_data = {
        world_state: global.room_states
    };

    // --- SAVE PLAYER.JSON ---
    var _p_json = json_stringify(_player_data, true);
    var _p_buffer = buffer_create(string_byte_length(_p_json), buffer_fixed, 1);
    buffer_write(_p_buffer, buffer_text, _p_json);
    
    SparkleSave("player.json", _p_buffer, function(_status) {
        if (_status) show_debug_message("player.json saved successfully.");
        else show_debug_message("CRITICAL: Failed to save player.json!");
    });
    buffer_delete(_p_buffer);

    // --- SAVE WORLD.JSON ---
    var _w_json = json_stringify(_world_data, true);
    var _w_buffer = buffer_create(string_byte_length(_w_json), buffer_fixed, 1);
    buffer_write(_w_buffer, buffer_text, _w_json);
    
    SparkleSave("world.json", _w_buffer, function(_status) {
        if (_status) show_debug_message("world.json saved successfully.");
        else show_debug_message("CRITICAL: Failed to save world.json!");
    });
    buffer_delete(_w_buffer);

    // Easter egg file
    if (file_exists("someone.txt")) file_delete("someone.txt");
    var _txt = file_text_open_write("someone.txt");
    file_text_write_string(_txt, "01001000 01000001 01001110 01001101 01000001 01001011 01000001 01010010");
    file_text_close(_txt);
}

/// @desc Loads game state asynchronously using SparkleStore (player.json & world.json)
function load_game()
{   
    SparkleLoad("player.json", function(_p_status, _p_buffer) {
        if (!_p_status) {
            show_debug_message("Load failed: player.json could not be loaded or does not exist.");
            if (buffer_exists(_p_buffer)) buffer_delete(_p_buffer);
            return;
        }
        
        buffer_seek(_p_buffer, buffer_seek_start, 0);
        var _player_data = json_parse(buffer_read(_p_buffer, buffer_text));
        buffer_delete(_p_buffer); 
        
        // Unpack Player and Spawn data
        var _player = struct_exists(_player_data, "player") ? _player_data.player : {};
        global.player_name = struct_get_active(_player, "name", "Player");
        global.player_hp   = struct_get_active(_player, "hp", 100);
        global.player_gold = struct_get_active(_player, "gold", 0);
        global.date        = struct_get_active(_player, "date", 0);
        
        var _spawn = struct_exists(_player_data, "spawn") ? _player_data.spawn : {};
        var _target_room_name = struct_get_active(_spawn, "room_name", "");
        global.load_x    = struct_get_active(_spawn, "x", 0);
        global.load_y    = struct_get_active(_spawn, "y", 0);
        global.load_face = struct_get_active(_spawn, "face", 0);

        // Helper method to reconstruct an item struct from a saved ID
        var _instantiate_item = function(_saved_item) {
            if (!is_struct(_saved_item) || !struct_exists(_saved_item, "id")) return undefined;
            
            var _item_id = _saved_item.id;
            var _template = variable_struct_get(global.item_list, _item_id);
            
            if (_template != undefined) {
                var _real_item = new create_item(
                    _template.name_key,
                    _template.description_key,
                    _template.price,
                    _template.icon,
                    _template.effect,
                    _template.heal_amount,
                    _template.rarity,
                    _template.itemType,
                    _template.canDrop
                );
                _real_item.count = struct_exists(_saved_item, "count") ? _saved_item.count : 1;
                return _real_item;
            } else {
                show_debug_message("WARNING: Failed to find global.item_list registry entry for ID: " + string(_item_id));
                return undefined;
            }
        };

        // Unpack Inventory
        if (struct_exists(_player_data, "inventory")) {
            var _saved_inv = _player_data.inventory;
            var _new_inv = [];
            
            for (var i = 0; i < array_length(_saved_inv); i++) {
                var _real_item = _instantiate_item(_saved_inv[i]);
                if (_real_item != undefined) {
                    array_push(_new_inv, _real_item);
                }
            }
            obj_item_manager.inv = _new_inv;
            obj_item_manager.inv_length = array_length(_new_inv);
        }

        // Unpack Equipped Items Array (Rebuilds 5-slot array)
        if (struct_exists(_player_data, "equipped")) {
            var _saved_eq = _player_data.equipped;
            var _new_eq = array_create(obj_item_manager.max_equipped_length, undefined);
            
            var _count = min(array_length(_saved_eq), obj_item_manager.max_equipped_length);
            for (var i = 0; i < _count; i++) {
                _new_eq[i] = _instantiate_item(_saved_eq[i]);
            }
            obj_item_manager.equipped = _new_eq;
        }
        
        // Unpack Followers
        global.load_followers = struct_exists(_player_data, "party") ? _player_data.party : [];
        
        // Load world.json in nested callback
        var _room_to_load = _target_room_name;
        
        SparkleLoad("world.json", method({ target_room: _room_to_load }, function(_w_status, _w_buffer) {
            if (!_w_status) {
                show_debug_message("CRITICAL: SparkleStore failed to load world.json.");
                if (buffer_exists(_w_buffer)) buffer_delete(_w_buffer);
                return;
            }
            
            buffer_seek(_w_buffer, buffer_seek_start, 0);
            var _world_data = json_parse(buffer_read(_w_buffer, buffer_text));
            buffer_delete(_w_buffer);
            
            // Unpack World States
            global.room_states = struct_exists(_world_data, "world_state") ? _world_data.world_state : {};
            
            // Reset engine/visual states
            global.state = GAME_STATE.PLAYING;
            global.active_battle_enemies = []; 
            shader_reset(); 
            draw_set_alpha(1.0);
            draw_set_color(c_white);
            
            if (instance_exists(obj_battle_controller)) {
                with (obj_battle_controller) instance_destroy();
            }
            
            audio_stop_all();
            if (variable_instance_exists(obj_music_manager, "current_track")) {
                obj_music_manager.current_track = noone;
            }
            
            // Execute room transition
            var _rm_name = target_room;
            if (_rm_name == "") 
            {
                room_goto(rm_menuRoom);
            }
            else
            {
                var _target_room = asset_get_index(_rm_name);
                if (_target_room != -1 && asset_get_type(_rm_name) == asset_room)
                {
                    global.is_loading_save = true;
                    room_goto(_target_room); 
                }
            }
            
            show_debug_message("Asynchronous Multi-File Loading Complete!");
        }));
    });
    
    return true;
}

// Simple null-coalescing helper to keep variable loading safe
function struct_get_active(_struct, _key, _default) {
    if (struct_exists(_struct, _key)) {
        return struct_get(_struct, _key);
    }
    return _default;
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
        
        window_enable_borderless_fullscreen(true);
        window_set_fullscreen(global.fullscreen == 1);
    }
    
    load_locale(global.setting_language == 1 ? "tr" : "en");
}