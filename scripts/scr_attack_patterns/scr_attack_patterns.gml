// ============================================================
// ATTACK PATTERN FORMAT (platformer version, variant pools)
// Each enemy now has a POOL of possible attacks (not one fixed pattern) --
// scr_get_attack_pattern_for() picks a random variant each time that enemy
// attacks, then applies a small timing/position jitter on top so even repeats
// of the same variant don't feel identical. Add more variants to an enemy's
// pool any time by writing a new scr_atkpattern_<enemy>_<name>() function and
// adding it to that enemy's array in scr_get_attack_pattern_for().
//
// COORDINATES: x = horizontal offset from the spawn edge (usually 0 -- beats
// spawn at the right edge and travel left). y = height offset from the ground,
// negative = up in the air. dir 180 = moving left (the norm).
// ============================================================

/// @function AttackBeat(time, type, x, y, dir, spd, parryable, dmg)
/// @description One spawn event inside an attack pattern.
function AttackBeat(_time, _type, _x, _y, _dir, _spd, _parryable, _dmg) constructor {
    time      = _time;
    type      = _type;      // "ground" | "float" -- purely cosmetic tag right now
    x         = _x;
    y         = _y;
    dir       = _dir;
    spd       = _spd;
    parryable = _parryable;
    dmg       = _dmg;       // unused directly, damage comes from the attacker's own atk stat
    spawned   = false;      // internal, do not set manually
}

/// @function scr_jitter_pattern(pattern)
/// @description Nudges each beat's timing and height slightly at random so the
/// same variant doesn't play back identically every time it's picked. Re-sorts
/// by time afterward since the jitter can shuffle spawn order slightly.
function scr_jitter_pattern(_pattern) {
    for (var i = 0; i < array_length(_pattern); i++) {
        var _b = _pattern[i];
        _b.time = max(0, _b.time + random_range(-0.08, 0.08));
        _b.y += random_range(-6, 6);
    }
    array_sort(_pattern, function(_a, _b) { return _a.time - _b.time; });
    return _pattern;
}

/// @function scr_atkpattern_TEMPLATE()
/// @description Copy this per variant. Return an array of AttackBeat.
function scr_atkpattern_TEMPLATE() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "ground",  0,   0, 180, 2.0, false, 0)); // jump over
    array_push(_p, new AttackBeat(0.60, "ground",  0,   0, 180, 2.0, false, 0)); // jump over
    array_push(_p, new AttackBeat(1.30, "float",   0, -50, 180, 2.5, true,  0)); // jump into to parry
    return _p;
}

// ------------------------------------------------------------
// SLIME -- five variants, picked randomly. Add more any time.
//
// Speeds were bumped up significantly from the first pass (was 1.8-2.6px/frame
// over a 240px box -- close to a full second of reaction time per beat, with
// only 3 sparse beats total, which is why it didn't feel like there was
// anything to actually dodge). Also added a genuine non-parryable floating
// hazard type: previously EVERY floating beat was parryable, so there was no
// real penalty for jumping carelessly -- a non-parryable float actually
// punishes that, forcing you to read the pattern instead of just spamming jump.
//
// GAP TIMING NOTE: coyote time + jump buffering + variable jump height together
// made a single well-spaced ground beat almost impossible to actually get hit
// by -- a well-timed jump has generous forgiveness on both ends, so with ~0.4s+
// between beats there was always enough time to land and reset. Gaps below were
// tightened so consecutive ground beats land close to (or inside) actual jump
// airtime (~0.47s at current physics), forcing real timing instead of "jump
// whenever, you'll be fine."
// ------------------------------------------------------------

/// @function scr_atkpattern_slime_hop_lunge()
function scr_atkpattern_slime_hop_lunge() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "ground", 0,   0, 180, 3.2, false, 0));
    array_push(_p, new AttackBeat(0.30, "ground", 0,   0, 180, 3.2, false, 0)); // was 0.40 -- tightened
    array_push(_p, new AttackBeat(0.65, "float",  0, -45, 180, 3.0, true,  0)); // parryable
    return _p;
}

/// @function scr_atkpattern_slime_double_lunge()
/// @description Fast, no parry window -- purely a dodge/platform-timing check,
/// four hops in quick succession instead of a slower three.
function scr_atkpattern_slime_double_lunge() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "ground", 0, 0, 180, 3.6, false, 0));
    array_push(_p, new AttackBeat(0.20, "ground", 0, 0, 180, 3.6, false, 0)); // was 0.22
    array_push(_p, new AttackBeat(0.40, "ground", 0, 0, 180, 3.6, false, 0)); // was 0.44
    array_push(_p, new AttackBeat(0.60, "ground", 0, 0, 180, 3.6, false, 0)); // was 0.66
    return _p;
}

/// @function scr_atkpattern_slime_high_parry()
/// @description Leads with the parry beat instead of ending on it, then two
/// quick ground hops -- so players can't just learn "parry is always last".
function scr_atkpattern_slime_high_parry() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "float",  0, -45, 180, 2.8, true,  0)); // parryable
    array_push(_p, new AttackBeat(0.50, "ground", 0,   0, 180, 3.4, false, 0)); // was 0.55
    array_push(_p, new AttackBeat(0.75, "ground", 0,   0, 180, 3.4, false, 0)); // was 0.85 -- tightened gap to previous beat
    return _p;
}

/// @function scr_atkpattern_slime_mixed_rhythm()
/// @description Alternates "you must jump" (ground) with "you must stay
/// grounded" (non-parryable float), so spam-jumping the whole attack gets you
/// hit by the float beat instead of clearing everything blind.
function scr_atkpattern_slime_mixed_rhythm() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "ground", 0,   0, 180, 3.4, false, 0)); // jump this
    array_push(_p, new AttackBeat(0.28, "float",  0, -28, 180, 3.4, false, 0)); // was 0.35 -- DON'T jump this one, stay grounded
    array_push(_p, new AttackBeat(0.60, "ground", 0,   0, 180, 3.4, false, 0)); // was 0.75 -- jump this
    array_push(_p, new AttackBeat(0.95, "float",  0, -45, 180, 2.8, true,  0)); // was 1.10 -- parryable finisher
    return _p;
}

/// @function scr_atkpattern_slime_frenzy_hop()
/// @description The slime's "signature" harder attack -- three rapid hops with
/// essentially no recovery gap between them (tighter than the standard variants),
/// so clearing it requires actual short-hop timing rather than one big jump,
/// capped with a parryable lunge. This is a real attack meant to appear in normal
/// play (it's in the pool below), not a QA-only pattern -- a legitimate "this
/// enemy is doing something dangerous" moment rather than a checklist.
function scr_atkpattern_slime_frenzy_hop() {
    var _p = [];
    array_push(_p, new AttackBeat(0.00, "ground", 0, 0, 180, 3.6, false, 0));
    array_push(_p, new AttackBeat(0.18, "ground", 0, 0, 180, 3.8, false, 0)); // tight -- needs a short hop, not a full-height jump
    array_push(_p, new AttackBeat(0.36, "ground", 0, 0, 180, 4.0, false, 0));
    array_push(_p, new AttackBeat(0.85, "float",  0, -45, 180, 3.2, true,  0)); // parryable finisher, breathing room before it
    return _p;
}

/// @function scr_get_attack_pattern_for(actor)
/// @description Picks a random variant from the actor's pattern pool, jitters
/// it, and returns it. Anything not listed falls back to the template pool so
/// nothing breaks mid-development.
function scr_get_attack_pattern_for(_actor) {
    // Debug override -- set global.debug_force_test_pattern = true (F1 toggles it,
    // see the check near the top of obj_battle_controller's Step event) to force
    // EVERY enemy attack to run scr_atkpattern_slime_frenzy_hop specifically,
    // instead of a random pick from the pool. This is a REAL attack that's also
    // in the normal pool below, not a separate QA-only pattern -- so what you're
    // testing is exactly what players will actually see in play, just guaranteed
    // instead of left to chance. No jitter here on purpose -- deterministic makes
    // it easier to spot bugs.
    if (variable_global_exists("debug_force_test_pattern") && global.debug_force_test_pattern) {
        return scr_atkpattern_slime_frenzy_hop();
    }

    if (!instance_exists(_actor)) return scr_jitter_pattern(scr_atkpattern_TEMPLATE());

    var _pool = [scr_atkpattern_TEMPLATE]; // default pool, just the template

    switch (_actor.object_index) {
        case obj_slime:
            _pool = [
                scr_atkpattern_slime_hop_lunge,
                scr_atkpattern_slime_double_lunge,
                scr_atkpattern_slime_high_parry,
                scr_atkpattern_slime_mixed_rhythm,
                scr_atkpattern_slime_frenzy_hop
            ];
            break;
    }

    var _pick = _pool[irandom(array_length(_pool) - 1)];
    return scr_jitter_pattern(_pick());
}

// ------------------------------------------------------------
// EXECUTOR -- call from obj_battle_arena during its ARENA phase, once per attacker.
// Spawns into out_beats (a plain array on the arena instance), tagged with which
// attacker each beat belongs to so damage can be resolved per-enemy.
// ------------------------------------------------------------

/// @function scr_run_attack_pattern(pattern, timer, out_beats, spawn_x, ground_y, attacker_index)
/// @description Pushes any beats whose time has come into out_beats.
/// @returns true once every beat in the pattern has been spawned
function scr_run_attack_pattern(_pattern, _timer, _out_beats, _spawn_x, _ground_y, _attacker_index = 0) {
    var _all_spawned = true;
    for (var i = 0; i < array_length(_pattern); i++) {
        var _b = _pattern[i];
        if (!_b.spawned) {
            if (_timer >= _b.time) {
                _b.spawned = true;
                array_push(_out_beats, {
                    beat_type      : _b.type,
                    x              : _spawn_x + _b.x,
                    y              : _ground_y + _b.y,
                    dir            : _b.dir,
                    spd            : _b.spd,
                    parryable      : _b.parryable,
                    attacker_index : _attacker_index
                });
            } else {
                _all_spawned = false;
            }
        }
    }
    return _all_spawned;
}
