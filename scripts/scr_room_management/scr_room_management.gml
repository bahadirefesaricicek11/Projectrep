function save_room() {
    var _room_key = room_get_name(room);
    
    // Clear existing array for this room to prevent duplicate instances accumulation
    var _saved_instances = [];
    
    var _types_count = array_length(global.saveables); 
    for (var i = 0; i < _types_count; i++) {
        var _target_object = global.saveables[i];
        
        with (_target_object) {
            // OPTIONAL: Skip purely static objects (solids, trees, bushes) that don't change state
            if (object_index == obj_solid || object_index == obj_big_tree || object_index == obj_bush) {
                continue;
            }
            
            var _data = {
                object_name: object_get_name(object_index),
                x: x,
                y: y
            };
            
            // Only add non-default / non-null fields to keep JSON compact
            if (layer != -1 && layer_exists(layer)) {
                var _lname = layer_get_name(layer);
                if (_lname != "Instances") _data.layer_name = _lname;
            }
            
            if (image_xscale != 1) _data.xscale = image_xscale;
            if (image_yscale != 1) _data.yscale = image_yscale;
            if (depth != -y) _data.depth = depth; // Only save depth if overridden from standard -y sorting
            
            // Conditional State Properties (Only write if assigned)
            if (variable_instance_exists(id, "hp") && hp != undefined) _data.hp = hp;
            if (variable_instance_exists(id, "is_opened") && is_opened != undefined) _data.is_opened = is_opened;
            if (variable_instance_exists(id, "amount") && amount != undefined) _data.amount = amount;
            if (variable_instance_exists(id, "text_id") && text_id != "") _data.text_id = text_id;
            
            // Item Handle
            if (variable_instance_exists(id, "item")) {
                if (is_struct(item) && struct_exists(item, "name_key")) {
                    var _key = string_replace(item.name_key, "items.", "");
                    _data.item_id = string_replace(_key, ".name", "");
                } else if (is_string(item) && item != "") {
                    _data.item_id = item;
                }
            }

            array_push(_saved_instances, _data);
        }
    }
    
    struct_set(global.room_states, _room_key, _saved_instances);
}

function load_room() {
    var _room_key = room_get_name(room);
    if (!struct_exists(global.room_states, _room_key)) return;
    
    var _saved_instances = struct_get(global.room_states, _room_key);
    
    // Destroy dynamic saveable instances to prevent duplicates
    var _types_count = array_length(global.saveables);
    for (var i = 0; i < _types_count; i++) {
        // Skip destroying room-editor static geometry if you excluded them from save_room
        if (global.saveables[i] == obj_solid || global.saveables[i] == obj_big_tree || global.saveables[i] == obj_bush) {
            continue;
        }
        
        with (global.saveables[i]) {
            instance_destroy(id, false);
        }
    }
    
    // Re-instantiate saved objects
    var _inst_count = array_length(_saved_instances);
    for (var i = 0; i < _inst_count; i++) {
        var _data = _saved_instances[i];
        
        var _layer = struct_exists(_data, "layer_name") ? _data.layer_name : "Instances";
        if (is_real(_layer) || !layer_exists(_layer)) _layer = "Instances";
        
        var _object_asset = asset_get_index(_data.object_name);
        if (_object_asset != -1) {
            var _inst = instance_create_layer(_data.x, _data.y, _layer, _object_asset);
            
            with (_inst) {
                image_xscale = struct_exists(_data, "xscale") ? _data.xscale : 1;
                image_yscale = struct_exists(_data, "yscale") ? _data.yscale : 1;
                if (struct_exists(_data, "depth")) depth = _data.depth;
                
                // Safe property hydration
                if (struct_exists(_data, "hp")) hp = _data.hp;
                if (struct_exists(_data, "is_opened")) is_opened = _data.is_opened;
                if (struct_exists(_data, "amount")) amount = _data.amount;
                if (struct_exists(_data, "text_id")) text_id = _data.text_id;
                
                if (struct_exists(_data, "item_id")) {
                    if (variable_global_exists("item_list") && struct_exists(global.item_list, _data.item_id)) {
                        var _template = variable_struct_get(global.item_list, _data.item_id);
                        item = new create_item(
                            _template.name_key, _template.description_key, _template.price,
                            _template.icon, _template.effect, _template.heal_amount,
                            _template.rarity, _template.itemType, _template.canDrop
                        );
                    } else {
                        item = _data.item_id;
                    }
                }
            }
        }
    }
    
    if (variable_global_exists("battle_id") && global.battle_id != "none") {
        if (is_callable(scr_check_slime_results)) scr_check_slime_results();
    }
}