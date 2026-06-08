var inv = get_inventory();
if (instance_exists(inv) && inv.is_visible) {
    var pos = inv.item_positions[inv.selected_index];
    x = pos[0];
    y = pos[1] - 40;
    
    blink_timer = (blink_timer + 1) % blink_speed;
} else {
    instance_destroy();
}