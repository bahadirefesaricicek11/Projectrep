var _camW = camera_get_view_width(view_camera[0]);
var _camH = camera_get_view_height(view_camera[0]);

if (!cutscene_mode) {
    // Normal: snap to player
    if (instance_exists(obj_player)) {
        x = obj_player.x - _camW / 2;
        y = obj_player.y - _camH / 2;
    }
} else {
    // Cutscene: lerp toward scripted target
    x = lerp(x, target_x - _camW / 2, lerp_speed);
    y = lerp(y, target_y - _camH / 2, lerp_speed);
}

x = clamp(x, 0, room_width  - _camW);
y = clamp(y, 0, room_height - _camH);

camera_set_view_pos(view_camera[0], x, y);
surface_resize(
    application_surface,
    camera_get_view_width(view_camera[0]),
    camera_get_view_height(view_camera[0])
);