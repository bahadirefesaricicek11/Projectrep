function scr_start_slime_dad_cutscene(_bush_x, _bush_y) {

    // Disable player
    obj_player.can_move = false;

    // Spawn Slime Dad hidden in bushes
    var _sd = instance_create_layer(_bush_x, _bush_y, "Instances", obj_slime_dad);

    // Reset dialogue flag
    global.cutscene_dialogue_done = false;

    // Create the controller
    var _ctrl = instance_create_layer(0, 0, "Instances", obj_cutscene_controller);

    // ── EVENT 1: Camera pans to bushes ──────────────────────────────
    _ctrl.enqueue(
        // ready? yes when camera is close enough to bush
        function() {
            var _camW = camera_get_view_width(view_camera[0]);
            var _camH = camera_get_view_height(view_camera[0]);
            var _cx   = obj_camera.x + _camW / 2;
            var _cy   = obj_camera.y + _camH / 2;
            return point_distance(_cx, _cy, _bush_x, _bush_y) < 8;
        },
        function() {
            scr_camera_move_to(_bush_x, _bush_y, 0.06);
        }
    );

    // ── EVENT 2: Scene 1 dialogue (silhouette in bushes) ───────────
    _ctrl.enqueue(
        function() { return global.cutscene_dialogue_done; },
        function() {
            global.cutscene_dialogue_done = false;
            startDialogue("slime_dad_scene1");
        }
    );

    // ── EVENT 3: Slime Dad jumps out ───────────────────────────────
    _ctrl.enqueue(
        function() { return _sd.jump_done; },
        function() {
            _sd.state = SLIME_DAD_STATE.JUMPING;
        }
    );

    // ── EVENT 4: Camera moves to midpoint ──────────────────────────
    _ctrl.enqueue(
        function() {
            var _camW = camera_get_view_width(view_camera[0]);
            var _camH = camera_get_view_height(view_camera[0]);
            var _mid_x = (obj_player.x + _sd.x) / 2;
            var _mid_y = (obj_player.y + _sd.y) / 2;
            var _cx    = obj_camera.x + _camW / 2;
            var _cy    = obj_camera.y + _camH / 2;
            return point_distance(_cx, _cy, _mid_x, _mid_y) < 8;
        },
        function() {
            var _mid_x = (obj_player.x + _sd.x) / 2;
            var _mid_y = (obj_player.y + _sd.y) / 2;
            scr_camera_move_to(_mid_x, _mid_y, 0.05);
        }
    );

    // ── EVENT 5: Scene 2 dialogue (full reveal, anger) ─────────────
    _ctrl.enqueue(
        function() { return global.cutscene_dialogue_done; },
        function() {
            global.cutscene_dialogue_done = false;
            _sd.state = SLIME_DAD_STATE.IDLE;
            startDialogue("slime_dad_scene2");
        }
    );

    // ── EVENT 6: Camera returns to player ──────────────────────────
    _ctrl.enqueue(
        function() {
            var _camW = camera_get_view_width(view_camera[0]);
            var _camH = camera_get_view_height(view_camera[0]);
            var _cx   = obj_camera.x + _camW / 2;
            var _cy   = obj_camera.y + _camH / 2;
            return point_distance(_cx, _cy, obj_player.x, obj_player.y) < 8;
        },
        function() {
            scr_camera_release();
        }
    );

    // ── EVENT 7: Trigger combat ─────────────────────────────────────
    _ctrl.enqueue(
        function() { return true; }, // instant
        function() {
            // Trigger your combat system here
            // e.g. obj_battle_manager.start_battle(_sd);
            // or room_goto(rm_battle);
            obj_player.can_move = false; // combat takes over
        }
    );

    // Start the cutscene
    _ctrl.start();
}