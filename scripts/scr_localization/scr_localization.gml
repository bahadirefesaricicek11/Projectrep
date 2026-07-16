// Global initialization variables
global.locale_data = {};
global.current_locale = "en";

function load_locale(locale_code) {
    // Reverted: Use direct local engine tree addressing
    var _file_path = "localization/" + locale_code + ".json"; 
    
    if (!file_exists(_file_path)) {
        show_debug_message("Localization file not found: " + _file_path);
        return false;
    }
    
    var _buffer = buffer_load(_file_path);
    var _json_string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    try {
        global.locale_data = json_parse(_json_string);
        global.current_locale = locale_code;
        return true;
    } catch (_exception) {
        show_debug_message("JSON Parsing Error: " + _exception.message);
        return false;
    }
}

/// @desc Translates a dot-notation key path
function __(key_path, args = []) {
    var _keys = string_split(key_path, ".");
    var _current_node = global.locale_data;
    
    var _count = array_length(_keys);
    for (var i = 0; i < _count; i++) {
        var _k = _keys[i];
        if (variable_struct_exists(_current_node, _k)) {
            _current_node = _current_node[$ _k];
        } else {
            return "[" + key_path + "]";
        }
    }
    
    if (!is_string(_current_node)) return "Invalid Path: [" + key_path + "]";
    
    var _arg_count = array_length(args);
    if (_arg_count > 0) {
        for (var j = 0; j < _arg_count; j++) {
            _current_node = string_replace_all(_current_node, "{" + string(j) + "}", string(args[j]));
        }
    }
    
    return _current_node;
}