/// @description obj_follower Step Event

if (!instance_exists(obj_player)) exit;

var _history = obj_player.pos_history;
if (!ds_exists(_history, ds_type_list)) exit;

var _history_size = ds_list_size(_history);

// 16 frame lag per index
var _delay_frame = (follower_index + 1) * 16;

// Clamp the index to safety so we never access an invalid index
var _lookup_idx = clamp(_delay_frame, 0, _history_size - 1);
var _target_pos = _history[| _lookup_idx];

if (is_struct(_target_pos)) {
    // Smooth transition tracking
    x = _target_pos.x;
    y = _target_pos.y;
    image_index = _target_pos.img_idx;
    
    // Direction calculation
    if (!variable_instance_exists(id, "base_sprite") || !sprite_exists(base_sprite)) {
        base_sprite = sprite_index;
    }
    
    if (sprite_exists(base_sprite) && variable_struct_exists(_target_pos, "sprite") && sprite_exists(_target_pos.sprite)) {
        var _player_sprite_name = sprite_get_name(_target_pos.sprite);
        var _my_base_name = sprite_get_name(base_sprite);
        
        _my_base_name = string_replace(_my_base_name, "_down", "");
        _my_base_name = string_replace(_my_base_name, "_left", "");
        _my_base_name = string_replace(_my_base_name, "_right", "");
        _my_base_name = string_replace(_my_base_name, "_up", "");
        
        var _target_suffix = "_down";
        if (string_ends_with(_player_sprite_name, "_left"))       _target_suffix = "_left";
        else if (string_ends_with(_player_sprite_name, "_right")) _target_suffix = "_right";
        else if (string_ends_with(_player_sprite_name, "_up"))    _target_suffix = "_up";
        
        var _resolved_sprite_index = asset_get_index(_my_base_name + _target_suffix);
        if (_resolved_sprite_index != -1 && sprite_exists(_resolved_sprite_index)) {
            sprite_index = _resolved_sprite_index;
        }
    }
    
    // Stop walking animation if the target coordinate is identical
    if (_lookup_idx + 1 < _history_size) {
        var _prev_pos = _history[| _lookup_idx + 1];
        if (is_struct(_prev_pos) && _target_pos.x == _prev_pos.x && _target_pos.y == _prev_pos.y) {
            image_index = 0; 
            image_speed = 0;
        } else {
            image_speed = 1; 
        }
    }
}

depth = -bbox_bottom;