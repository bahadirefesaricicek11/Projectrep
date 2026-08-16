// ---------------- STEP EVENT ----------------
if (phase == "TELL") {
    tell_timer += 1 / room_speed;
    if (tell_timer >= tell_duration) {
        phase = "ARENA";
        // Stagger each attacker's start instead of all beginning at pattern_timer 0 --
        // with 2+ enemies attacking together, every variant's first beat is authored
        // at time 0.00, so without this they'd all spawn on the same frame and read
        // as one duplicated attack instead of separate ones.
        var _stagger_delay = 0.25;
        for (var a = 0; a < array_length(attackers); a++) attackers[a].pattern_timer = -(a * _stagger_delay);
    }
    exit;
}

if (phase == "ARENA") {
    // --- avatar horizontal movement (accelerated, not instant) ---
    // Uses jujuadams Input v10, matching the rest of your input handling.
    var _h = InputCheck(INPUT_VERB.RIGHT) - InputCheck(INPUT_VERB.LEFT);
    var _target_hspeed = _h * move_max_speed;
    if (avatar_hspeed < _target_hspeed) {
        avatar_hspeed = min(avatar_hspeed + (_h != 0 ? move_accel : move_decel), _target_hspeed);
    } else if (avatar_hspeed > _target_hspeed) {
        avatar_hspeed = max(avatar_hspeed - (_h != 0 ? move_accel : move_decel), _target_hspeed);
    }
    avatar_x = clamp(avatar_x + avatar_hspeed, box_l, box_r);
    if (avatar_x <= box_l || avatar_x >= box_r) avatar_hspeed = 0; // don't keep "pushing" against the wall

    // --- jump input (buffered + coyote time) ---
    // Edge-triggered on purpose -- InputPressed fires once on the exact press
    // frame, so holding the button doesn't repeat-jump.
    var _jump_pressed = InputPressed(INPUT_VERB.ACCEPT);
    var _jump_held     = InputCheck(INPUT_VERB.ACCEPT);

    if (avatar_grounded) coyote_timer = coyote_max;
    else if (coyote_timer > 0) coyote_timer -= 1;

    if (_jump_pressed) {
        if (avatar_grounded || coyote_timer > 0) {
            // Grounded (or just barely left the ground) -- this press means jump.
            jump_buffer_timer = jump_buffer_max;
        } else {
            // Already airborne and past coyote time -- this is a deliberate SECOND
            // press, not the button still being held from the original jump. Treat
            // it as a parry attempt.
            parry_press_buffer_timer = parry_press_buffer_max;
        }
    } else if (jump_buffer_timer > 0) {
        jump_buffer_timer -= 1;
    }
    if (parry_press_buffer_timer > 0) parry_press_buffer_timer -= 1;

    if (jump_buffer_timer > 0 && (avatar_grounded || coyote_timer > 0)) {
        avatar_vspeed = jump_speed;
        avatar_grounded = false;
        coyote_timer = 0;
        jump_buffer_timer = 0;
        jump_active = true;
    }

    // Variable jump height -- release early while still ascending and the jump
    // gets cut short. Only applies once per jump (jump_active flag) so it can't
    // keep chipping away at vspeed every single frame.
    if (jump_active && avatar_vspeed < 0 && !_jump_held) {
        avatar_vspeed *= jump_cut_multiplier;
        jump_active = false;
    }

    // --- parry (separate from jump) ---
    // Only true if you deliberately pressed again while airborne (see above),
    // not just because the jump button happens to still be held down.
    var _parry_ready = parry_press_buffer_timer > 0;

    // --- gravity + one-way platform landing ---
    // Jump apex height at these physics values is roughly jump_speed^2 / (2*gravity)
    // = 49 / 1.0 =~ 49px (was ~51px with the old slower physics) -- platforms at
    // -35 are still comfortably reachable. If you change jump_speed/gravity_val
    // again, re-check platform.y against this formula.
    //
    // Hang-time: gravity is reduced while avatar_vspeed is near zero (i.e. near the
    // top of the arc), giving a real, brief window at the peak instead of the avatar
    // passing through the apex on a single frame. This is what actually widens the
    // parry window spatially -- the bigger _parry_radius above only helps once
    // you're already near the beat, this is what gives you time to line up with it.
    var _prev_y = avatar_y;
    var _was_grounded = avatar_grounded;
    var _near_apex = (abs(avatar_vspeed) < 1.5);
    avatar_vspeed += _near_apex ? (gravity_val * 0.35) : gravity_val;
    var _next_y = avatar_y + avatar_vspeed;

    avatar_grounded = false;
    if (avatar_vspeed >= 0) { // only land while falling/stationary -- lets you jump up THROUGH a platform from below
        for (var s = 0; s < array_length(platforms); s++) {
            var _surf = platforms[s];
            if (avatar_x >= _surf.x1 && avatar_x <= _surf.x2 && _prev_y <= _surf.y && _next_y >= _surf.y) {
                _next_y = _surf.y;
                avatar_vspeed = 0;
                avatar_grounded = true;
                break;
            }
        }
    }
    if (_next_y < box_t) { // simple ceiling
        _next_y = box_t;
        avatar_vspeed = max(avatar_vspeed, 0);
    }
    avatar_y = _next_y;

    // Landing squash -- fires the instant you go from airborne to grounded.
    if (avatar_grounded && !_was_grounded) {
        landing_squash_timer = landing_squash_max;
        jump_active = false;
    }
    if (landing_squash_timer > 0) landing_squash_timer -= 1;

    // --- run every attacker's pattern concurrently ---
    // (Beats stay at their correct gameplay height -- see scr_draw_battle_arena for
    // how attackers are told apart visually instead, via a per-attacker color tint.
    // An earlier version of this nudged beat height per attacker for visual
    // separation, but that shifted "ground" beats away from the avatar's actual
    // standing height for any lane but the center one, breaking their collision.)
    var _all_spawned = true;
    for (var a = 0; a < array_length(attackers); a++) {
        var _atk = attackers[a];
        _atk.pattern_timer += 1 / room_speed;
        var _finished = scr_run_attack_pattern(_atk.pattern, _atk.pattern_timer, beats, box_r, ground_y, a);
        _atk.done_spawning = _finished;
        if (!_finished) _all_spawned = false;
    }

    // --- update + collide beats against the avatar ---
    var _hit_radius = 12;   // bumped from 10 -- beats move faster now, keep this comfortably above per-frame movement so hits/parries can't skip through
    var _parry_radius = 22; // deliberately more forgiving than _hit_radius -- parrying is the skill move and should reward attempts, not require pixel-perfect apex timing
    for (var i = array_length(beats) - 1; i >= 0; i--) {
        var _beat = beats[i];
        _beat.x += lengthdir_x(_beat.spd, _beat.dir);
        _beat.y += lengthdir_y(_beat.spd, _beat.dir);

        var _dist = point_distance(_beat.x, _beat.y, avatar_x, avatar_y);
        var _remove = false;

        if (_beat.parryable && _dist <= _parry_radius && _parry_ready) {
            parry_press_buffer_timer = 0; // consume it -- one press parries one beat
            parries += 1;
            if (variable_global_exists("crit_meter")) global.crit_meter += 10;
            avatar_vspeed = parry_hop_speed; // little bounce off the parry
            avatar_grounded = false;
            _remove = true;

            // Local feedback -- unmistakable right at the avatar, not just a number
            // over at the HP box.
            parry_flash_timer = 12;
            array_push(local_popups, {
                x: avatar_x, y: avatar_y - 20,
                text: "PARRY!", color: c_yellow,
                life: 30, max_life: 30
            });
        } else if (_dist <= _hit_radius) {
            var _ai = _beat.attacker_index;
            if (_ai >= 0 && _ai < array_length(attackers)) {
                attackers[_ai].hits_taken += 1;

                // REAL-TIME DAMAGE: applied the instant this hit lands, not deferred
                // to when the arena ends. Reaches directly into the controller's
                // party_members/popup_numbers/screenshake_amount.
                var _atk = attackers[_ai];
                if (instance_exists(obj_battle_controller) && instance_exists(_atk.actor)) {
                    var _t_idx = _atk.target_index;
                    var _target = obj_battle_controller.party_members[_t_idx];
                    if (_target.hp > 0) {
                        var _is_guarding = variable_struct_exists(_target, "is_defending") ? _target.is_defending : false;
                        var _damage = max(1, _atk.actor.atk - _target.def);
                        if (_is_guarding) _damage = ceil(_damage * 0.5);

                        _target.hp = max(0, _target.hp - _damage);
                        _target.hit_flash_timer = HIT_FLASH_DURATION;

                        // Local feedback -- flash + callout right at the avatar, plus a
                        // small knockback/hitstun so getting hit has actual physical
                        // weight instead of the beat just silently vanishing.
                        hit_flash_timer = 10;
                        avatar_vspeed = -2.5; // small knock-up
                        array_push(local_popups, {
                            x: avatar_x, y: avatar_y - 20,
                            text: string(_damage), color: c_red,
                            life: 30, max_life: 30
                        });

                        // No popup at the HP box for the player getting hit -- the
                        // local callout right above IS the feedback now. Screenshake
                        // stays (it's not text, and still helps sell the impact).
                        // This is deliberately one-sided: damage the PLAYER deals TO
                        // enemies elsewhere in the codebase still pops up normally --
                        // only the player's own "I got hit"/"I dodged" popups at the
                        // HP box were removed.
                        obj_battle_controller.screenshake_amount = 3;
                    }
                }
            }
            _remove = true;
        } else if (_beat.x < box_l - 40) {
            _remove = true; // drifted clear off the left edge, cull it
        }

        if (_remove) array_delete(beats, i, 1);
    }

    if (_all_spawned && array_length(beats) == 0) {
        done = true;
    }

    // --- decay local feedback ---
    if (hit_flash_timer > 0) hit_flash_timer -= 1;
    if (parry_flash_timer > 0) parry_flash_timer -= 1;
    for (var i = array_length(local_popups) - 1; i >= 0; i--) {
        var _pop = local_popups[i];
        _pop.y -= 0.6;
        _pop.life -= 1;
        if (_pop.life <= 0) array_delete(local_popups, i, 1);
    }
}
