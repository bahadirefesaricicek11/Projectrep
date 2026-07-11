function scr_start_slime_battle() {
    battle_trigger_room_transition(["slime", "slime", "slime"]);
}

function scr_check_slime_results() {
    if (global.battle_id == "slime_ambush") {
        
        switch (global.battle_result) {
            case "killed":
                // Conditions met: They chose violence
                global.secret_boss_unlocked = true;
                break;
                
            case "negotiated":
                // Settled peacefully: "Everything normal"
                global.secret_boss_unlocked = false;
                inst_3E43B7A1.text_id = "slime_post_negotiated";
                break;
                
            case "fled":
                // Ran away: Slimes are still there waiting
                global.secret_boss_unlocked = false;
                break;
        }
        
        // Clear flag to avoid continuous triggers
        global.battle_id = "none"; 
    }
}