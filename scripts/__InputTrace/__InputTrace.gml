function __InputTrace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Input: " + _string);
    var _lower_string = string_lower(_string);
    
    // 1. Check for "disconnected" FIRST
    if (string_pos("disconnected", _lower_string) > 0) {
        var _notif = instance_create_layer(0, 0, "Instances", obj_notification);
        _notif.text = "Controller Lost";
    }
    // 2. ONLY if it's not disconnected, check if it's connected
    else if (string_pos("connected", _lower_string) > 0) {
        var _notif = instance_create_layer(0, 0, "Instances", obj_notification);
        _notif.text = "Controller Paired";
    }
}