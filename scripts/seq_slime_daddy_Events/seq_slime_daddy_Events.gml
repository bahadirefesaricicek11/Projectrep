function canmove() {
    if (instance_exists(obj_player)) {
        obj_player.can_move = true;
        obj_player.visible = true;
    }
}

function seq_moment_trigger_textbox() {
    // 1. Find the sequence element on your Instances layer safely
    var _layer_id = layer_get_id("Instances");
    var _seq_elements = layer_get_all_elements(_layer_id);
    var _my_seq_element_id = noone;
    
    // Loop through elements on the layer to find our playing sequence
    for (var i = 0; i < array_length(_seq_elements); i++) {
        if (layer_get_element_type(_seq_elements[i]) == layerelementtype_sequence) {
            _my_seq_element_id = _seq_elements[i];
            break;
        }
    }

    // 2. Pause the sequence track using the safe element ID
    if (_my_seq_element_id != noone) {
        layer_sequence_pause(_my_seq_element_id);
    }
    
    // 3. Force create the textbox at absolute coordinates (0,0) safely 
    // without using 'id', passing the sequence ID directly
    if (!instance_exists(obj_textbox)) {
        var inst = instance_create_depth(0, 0, -999, obj_textbox);
        inst.sequence_to_resume = _my_seq_element_id;
        inst.setTopic("slime_daddy_cutscene_1");
    }
}