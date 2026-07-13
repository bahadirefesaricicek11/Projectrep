/// @desc scr_game_database - Runs automatically at game boot
show_debug_message("DATA SYSTEM: Initializing Master Game Registries...");
// --- 2. ENEMY TYPES REGISTRY ---
global.enemy_database = {
    slime: {
        name: "Slime",
        max_hp: 30,
        hp: 30,
        atk: 2,
        def: 1,
        
        // --- MERCY ENGINE PROPERTIES ---
        mercy: 20,
        max_mercy: 100,
        can_spare : false,
        is_spared : false,
        interact_options: ["Check", "Flatter", "Poke"],
        
        xp_value: 15,
        gold_value: 10,
        sprite: spr_slime
    },
    strong_slime: {
        name: "Strong Slime",
        max_hp: 50,
        hp: 50,
        atk: 18,
        def: 4,
        
        // --- MERCY ENGINE PROPERTIES ---
        mercy: 0,
        max_mercy: 150,
        can_spare : false,
        is_spared : false,
        interact_options: ["Check", "Mock", "Feed Biscuit"],
        
        xp_value: 35,
        gold_value: 25,
        sprite: spr_slime_dad
    }
};

// --- 2b. INTERACT EFFECTS REGISTRY ---
// Maps each interact sub-option name (as used in an enemy's interact_options array)
// to its mercy effect and flavor text. The battle script looks these up by name,
// so adding a brand-new interact option to any enemy just means adding an entry here —
// no battle-script code changes needed.
//
// "{name}" in flavor text gets swapped for the target enemy's name at battle time.
// "Check" doesn't need an entry: it's handled specially in the battle script
// (reveals ATK/DEF, never changes mercy).
//
// NOTE: these are starting defaults — tune mercy_delta to taste.
global.interact_effects = {
    Flatter: {
        mercy_delta: 25,
        flavor: "compliments {name}'s gooey shine!"
    },
    Poke: {
        mercy_delta: 10,
        flavor: "pokes {name} curiously."
    },
    Mock: {
        mercy_delta: -15,
        flavor: "mocks {name}'s wobbly shape. It doesn't seem to appreciate that."
    },
    "Feed Biscuit": {
        mercy_delta: 35,
        flavor: "feeds {name} a biscuit. It wobbles happily!"
    }
};

// --- 3. OVERWORLD ENCOUNTER GROUPS ---
global.encounter_database = {
    slime_easy: {
        weight_total: 100,
        pools: [
            { enemies: ["slime"],                   weight: 50 },
            { enemies: ["slime", "slime"],          weight: 35 },
            { enemies: ["slime", "slime", "slime"], weight: 15 }
        ]
    },
    forest_ambush: {
        weight_total: 100,
        pools: [
            { enemies: ["slime", "strong_slime"],                 weight: 70 },
            { enemies: ["strong_slime", "strong_slime", "slime"], weight: 30 }
        ]
    }
};
show_debug_message("DATA SYSTEM: Registries loaded successfully.");
