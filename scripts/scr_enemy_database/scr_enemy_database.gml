
global.enemy_database = {
    slime: {
        name: "Slime",
        hp: 30,
        max_hp: 30,
        sprite: spr_slime
    },
    strong_slime: {
        name: "Strong Slime",
        hp: 50,
        max_hp: 50,
        sprite: spr_slime_dad
    },
};

global.encounter_database = {
    
    // Encounter ID: "slime_easy"
    slime_easy: {
        weight_total: 100,
        pools: [
            { enemies: ["slime"],                 weight: 50 }, // 50% chance for 1 Slime
            { enemies: ["slime", "slime"],         weight: 35 }, // 35% chance for 2 Slimes
            { enemies: ["slime", "slime", "slime"], weight: 15 }  // 15% chance for 3 Slimes
        ]
    },
    
    // Encounter ID: "forest_ambush"
    forest_ambush: {
        weight_total: 100,
        pools: [
            { enemies: ["slime", "strong_slime"],         weight: 70 }, // 70% chance
            { enemies: ["strong_slime", "strong_slime", "slime"], weight: 30 }  // 30% chance
        ]
    }
};