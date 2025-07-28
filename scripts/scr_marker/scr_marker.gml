function scr_marker(arg0, arg1, arg2)
{
    thismarker = instance_create_depth(arg0, arg1, 100, obj_marker);
    
    with (thismarker)
    {
        sprite_index = arg2;
        image_speed = 0;
    }
    
    return thismarker;
}
