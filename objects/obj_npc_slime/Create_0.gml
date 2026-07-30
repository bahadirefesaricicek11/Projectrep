/// @description obj_npc_slime Create Event
event_inherited(); // runs obj_npc's Create Event first: sets has_joined, ally_key, battle_blueprint, etc.

// Check if this specific squad has already been wiped out.
// global.slime_ambush_completed is set ONLY in the "killed" outcome of
// scr_check_slime_results() (scr_battle_functions) — NOT for "negotiated" or "fled",
// since in both of those cases this NPC should still exist (just with different
// dialogue, or unchanged so the fight can be retried).
if (variable_global_exists("slime_ambush_completed") && global.slime_ambush_completed == true) {
    instance_destroy(); // They are dead, don't spawn them
}

text_id = "slime_trio"; // default: pre-battle dialogue that starts the ambush.
// If the battle was already resolved as "negotiated", scr_check_slime_results()
// overrides this to "slime_post_negotiated" from obj_player's Room Start, which
// always runs AFTER this Create Event has already finished — so that override
// correctly sticks.
