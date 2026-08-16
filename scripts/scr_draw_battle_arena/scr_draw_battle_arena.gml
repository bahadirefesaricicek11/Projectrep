// ============================================================
// scr_draw_battle_arena(arena)
// Draws the attack arena (TELL flash, floor, avatar, beats). Called explicitly
// from obj_battle_controller's Draw GUI event, as the very last thing it does --
// NOT from obj_battle_arena's own Draw GUI event. This was the fix for the arena
// not being visible: draw order between two separate instances' own Draw GUI
// events wasn't behaving predictably in this project, so instead of relying on
// depth/layer sorting, the controller now draws the arena itself, deterministically
// last, guaranteeing it's always in front. obj_battle_arena still owns all the
// actual state, physics, and collision logic in its own Step event -- only the
// drawing moved here.
// ============================================================

/// @function scr_draw_battle_arena(arena)
function scr_draw_battle_arena(_arena) {
    with (_arena) {
        if (phase == "TELL") {
            var _pulse = 0.5 + 0.5 * sin(current_time / 60);
            draw_set_alpha(_pulse);
            draw_set_color(c_red);
            draw_rectangle(box_l - 6, box_t - 6, box_r + 6, ground_y + 6, true);
            draw_set_alpha(1);
            draw_set_halign(fa_center);
            draw_set_color(c_white);
            draw_text_transformed((box_l + box_r) / 2, box_t - 20, "INCOMING!", 0.6, 0.6, 0);
            draw_set_halign(fa_left);
        } else if (phase == "ARENA") {
            draw_set_color(c_black);
            draw_rectangle(box_l, box_t, box_r, ground_y, false);
            draw_set_color(c_ltgray);
            draw_rectangle(box_l, box_t, box_r, ground_y, true);

            // floor + platforms -- platforms[0] is always the main floor
            for (var p = 0; p < array_length(platforms); p++) {
                var _surf = platforms[p];
                draw_set_color(p == 0 ? c_ltgray : c_white);
                draw_line_width(_surf.x1, _surf.y, _surf.x2, _surf.y, p == 0 ? 1 : 3);
            }

            // Non-parryable beats get a color per attacker (cycling through a small
            // palette) so simultaneous enemies read as distinct attacks instead of
            // looking duplicated. Parryable beats always stay yellow regardless of
            // attacker -- that color is a gameplay signal, not a per-enemy identity,
            // and should read the same no matter who's attacking.
            var _attacker_palette = [c_white, c_orange, c_fuchsia, c_lime];
            for (var i = 0; i < array_length(beats); i++) {
                var _beat = beats[i];
                // Drawn 5px above the true collision y -- ground beats sit exactly ON
                // the floor boundary for collision purposes, so drawing them at that
                // exact y renders half the circle below the box's bottom edge. This is
                // cosmetic only; hit detection in Step still uses the real _beat.y.
                var _draw_y = _beat.y - 5;
                if (_beat.parryable) {
                    var _bpulse = 0.6 + 0.4 * sin(current_time / 80);
                    draw_set_alpha(_bpulse);
                    draw_set_color(c_yellow);
                    draw_circle(_beat.x, _draw_y, 10, true);
                    draw_set_alpha(1);
                    draw_set_color(c_yellow);
                } else {
                    var _tint = _attacker_palette[_beat.attacker_index mod array_length(_attacker_palette)];
                    draw_set_color(_tint);
                }
                draw_circle(_beat.x, _draw_y, 6, false);
            }

            // Avatar -- flashes and briefly grows on a hit (red) or parry (gold),
            // instead of always being the same static aqua dot regardless of what
            // just happened to it. A tiny random jitter during the flash window
            // gives hits a bit of physical "impact" shake too.
            var _avatar_color = c_aqua;
            var _avatar_radius = 7;
            var _shake_x = 0;
            var _shake_y = 0;
            if (hit_flash_timer > 0) {
                _avatar_color = c_red;
                _avatar_radius = 9;
                _shake_x = random_range(-2, 2);
                _shake_y = random_range(-2, 2);
            } else if (parry_flash_timer > 0) {
                _avatar_color = c_yellow;
                _avatar_radius = 9;
            }
            draw_set_color(_avatar_color);
            // Squash on landing (wide/flat), stretch a little on the way up/down --
            // a plain circle that never deforms is a big part of why movement can
            // feel dead/static even when the underlying motion is fine.
            var _squash_t = landing_squash_timer / landing_squash_max; // 1 = just landed, 0 = normal
            var _xscale = 1 + (_squash_t * 0.5) - clamp(-avatar_vspeed / 12, -0.15, 0.15);
            var _yscale = 1 - (_squash_t * 0.4) + clamp(-avatar_vspeed / 12, -0.15, 0.15);
            draw_ellipse(
                avatar_x + _shake_x - (_avatar_radius * _xscale), avatar_y - 8 + _shake_y - (_avatar_radius * _yscale),
                avatar_x + _shake_x + (_avatar_radius * _xscale), avatar_y - 8 + _shake_y + (_avatar_radius * _yscale),
                false
            );

            // Local callouts ("HIT!" / damage number in red, "PARRY!" in gold) --
            // float up and fade at the avatar's position, impossible to miss since
            // it happens right where you're already looking.
            for (var i = 0; i < array_length(local_popups); i++) {
                var _pop = local_popups[i];
                var _alpha = clamp(_pop.life / _pop.max_life, 0, 1);
                draw_set_alpha(_alpha);
                draw_set_color(_pop.color);
                draw_set_halign(fa_center);
                draw_text_transformed(_pop.x, _pop.y, _pop.text, 0.5, 0.5, 0);
                draw_set_halign(fa_left);
                draw_set_alpha(1);
            }

            draw_set_halign(fa_center);
            draw_set_color(c_white);
            draw_text_transformed((box_l + box_r) / 2, box_t - 20, "Left/Right + Jump to dodge, jump into yellow to parry!", 0.4, 0.4, 0);
            draw_set_halign(fa_left);
        }
        draw_set_color(c_white);
    }
}
