// --- 2c. ALLY ROSTER REGISTRY ---
// Mirrors global.enemy_database: one canonical stat block per recruitable ally,
// keyed by a short lowercase id. This is now the SINGLE source of truth for an
// ally, covering both battle stats (hp/atk/def/etc., used by the battle arena
// setup) AND overworld follower data (sprite_idle, used when obj_player spawns
// an obj_follower for this ally). Previously these lived in two separate places
// (an embedded battle_blueprint per-NPC, and a separate global.ally_db keyed by
// display name) — merged here so a stat only ever needs tuning in one spot.
//
// sprite_idle should be the "_down" facing variant of the ally's walking sprite
// (e.g. spr_whitey_down) — obj_follower's Step event strips the _down/_left/
// _right/_up suffix from whatever base sprite you give it and re-adds the right
// one based on the player's current facing, so as long as all four directional
// sprites exist under a consistent base name, this one entry point is enough.
global.ally_database = {
    whitey: {
        name: "Whitey",
        hp: 80,
        max_hp: 80,
        atk: 80,
        def: 4,
        clover_leaves: 3,
        sprite: spr_npc_portrait,      // battle portrait
        sprite_idle: spr_npc           // TODO: point this at Whitey's actual overworld walking sprite (e.g. spr_whitey_down)
    },
    bob: {
        name: "Bob",
        hp: 80,
        max_hp: 80,
        atk: 80,
        def: 4,
        clover_leaves: 3,
        sprite: spr_npc_portrait,
		sprite_idle: spr_npc
    }
};