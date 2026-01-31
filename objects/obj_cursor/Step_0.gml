// Follow selected inventory slot
var inv = get_inventory();
if (instance_exists(inv) && inv.is_visible) {
    var pos = inv.item_positions[inv.selected_index];
    x = pos[0];
    y = pos[1] - 40; // Position above the item
    
    // Blink timer
    blink_timer = (blink_timer + 1) % blink_speed;
} else {
    // Destroy if inventory doesn't exist or isn't visible
    instance_destroy();
}