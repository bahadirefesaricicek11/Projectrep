// Feather disable all

function __InputTrace()
{
    // 1. Build the full trace string from all passed arguments
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    // Output standard log to the console
    show_debug_message("Input: " + _string);
    
    // 2. Perform your custom notification intercept logic
    var _lower_string = string_lower(_string);
    
    // A. Check for "disconnected" FIRST
    if (string_pos("disconnected", _lower_string) > 0) {
        var _notif = instance_create_layer(0, 0, "Instances", obj_notification);
        _notif.text = "Controller Lost";
    }
    
    // B. Check if a device is connected
    else if (string_pos("connected", _lower_string) > 0) {
        if (argument_count > 1) {
            // Find the gamepad index argument (Input typically passes it as a numeric argument)
            var _pad_index = undefined;
            for (var _j = 0; _j < argument_count; _j++) {
                if (is_numeric(argument[_j])) {
                    _pad_index = argument[_j];
                    break;
                }
            }
            
            if (_pad_index != undefined) {
                var _raw_desc = gamepad_get_description(_pad_index);
                var _desc = string_lower(_raw_desc);
                
                // FILTER 1: Clear out common virtual PC audio/video mixers
                if (string_pos("virtual", _desc) > 0 || 
                    string_pos("audio", _desc) > 0 || 
                    string_pos("streaming", _desc) > 0 ||
                    string_pos("sonar", _desc) > 0) 
                {
                    show_debug_message("Notification Silenced: Suppressed virtual driver hook.");
                    exit; 
                }
                
                // FILTER 2: Clear out dormant Bluetooth nodes that are turned off
                if (_raw_desc == "" || gamepad_button_count(_pad_index) <= 0 || gamepad_axis_count(_pad_index) <= 0) {
                    show_debug_message("Notification Silenced: Suppressed sleeping Bluetooth node.");
                    exit;
                }
            }
        }
        
        // This line only runs if it's a real physical device
        var _notif = instance_create_layer(0, 0, "Instances", obj_notification);
        _notif.text = "Controller Paired";
    }
}