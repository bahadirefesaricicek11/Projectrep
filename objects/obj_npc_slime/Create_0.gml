event_inherited();

// Check if this specific squad has already been wiped out
if (variable_global_exists("slime_ambush_completed") && global.slime_ambush_completed == true) {
    instance_destroy(); // They are dead, don't spawn them
}

text_id = "slime_trio";