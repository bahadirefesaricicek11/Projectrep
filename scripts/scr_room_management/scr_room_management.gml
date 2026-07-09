function save_room() {
    var _room_key = room_get_name(room);
    var _saved_instances = [];
    
    var _types_count = array_length(global.saveables); 
    for (var i = 0; i < _types_count; i++) {
        var _target_object = global.saveables[i];
        
        with (_target_object) {
            var _data = {
                object_index: object_index,
                x: x,
                y: y,
                hp: variable_instance_exists(id, "hp") ? hp : undefined,
                is_opened: variable_instance_exists(id, "is_opened") ? is_opened : undefined,
                
                amount: variable_instance_exists(id, "amount") ? amount : undefined,
                item: variable_instance_exists(id, "item") ? item : undefined,
				
                text_id: variable_instance_exists(id, "text_id") ? text_id : "",
            };
            array_push(_saved_instances, _data);
        }
    }
    
    struct_set(global.room_states, _room_key, _saved_instances);
}

function load_room() {
    var _room_key = room_get_name(room);
    
    if (!struct_exists(global.room_states, _room_key)) return;
    
    var _saved_instances = struct_get(global.room_states, _room_key);
    
    var _types_count = array_length(global.saveables);
    for (var i = 0; i < _types_count; i++) {
        with (global.saveables[i]) {
            instance_destroy(id, false);
        }
    }
    
    var _inst_count = array_length(_saved_instances);
    for (var i = 0; i < _inst_count; i++) {
        var _data = _saved_instances[i];
        
        var _layer = layer_get_name(variable_instance_exists(id, "layer") ? layer : "Instances");
        var _inst = instance_create_layer(_data.x, _data.y, _layer, _data.object_index);
        
        with (_inst) {
            if (_data.hp != undefined) hp = _data.hp;
            if (_data.is_opened != undefined) is_opened = _data.is_opened;
			if (_data.amount != undefined) amount = _data.amount;
			if (_data.item != undefined) item = _data.item;
			if (_data.text_id != "") text_id = _data.text_id;
        }
    }
}