// =========================================================================
// MASTER GAME DATA REGISTRY (THE ONLY PLACE YOU EDIT STATS AND VALUES)
// =========================================================================


// --- 2. ENEMY TYPES REGISTRY ---
global.enemy_database = {
    slime: {
        name: "Slime",
        max_hp: 30,
        hp: 30,
        atk: 12,
        def: 1,
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
        xp_value: 35,
        gold_value: 25,
        sprite: spr_slime_dad
    }
};

// --- 3. OVERWORLD ENCOUNTER GROUPS ---
global.encounter_database = {
    slime_easy: {
        weight_total: 100,
        pools: [
            { enemies: ["slime"],                 weight: 50 },
            { enemies: ["slime", "slime"],         weight: 35 },
            { enemies: ["slime", "slime", "slime"], weight: 15 }
        ]
    },
    forest_ambush: {
        weight_total: 100,
        pools: [
            { enemies: ["slime", "strong_slime"],         weight: 70 },
            { enemies: ["strong_slime", "strong_slime", "slime"], weight: 30 }
        ]
    }
};