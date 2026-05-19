function scr_camera_move_to(_x, _y, _speed) {
    obj_camera.cutscene_mode = true;
    obj_camera.target_x      = _x;
    obj_camera.target_y      = _y;
    obj_camera.lerp_speed    = _speed;
}

function scr_camera_release() {
    obj_camera.cutscene_mode = false;
}