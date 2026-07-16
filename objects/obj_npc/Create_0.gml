/// @description obj_npc Create Event
text_id = ""; // Set this to "susie_talk" or whatever in the room editor
has_joined = false;

// Which entry in global.ally_database this NPC's battle stats AND overworld follower
// sprite come from. This matches party_recruit_npc's own convention exactly (it reads
// _npc_inst.ally_key, falling back to "Whitey" if unset) — stored here in display
// case ("Whitey"), the same case party_allies actually holds; the lowercase
// normalization for database lookups happens at lookup time, not storage time, in
// obj_player's Room Start, battle_arena_setup, and party_recruit_npc.
// Change this one line per NPC instance instead of retyping their whole stat block —
// the actual numbers (hp/atk/def/sprite/sprite_idle) now live in ONE place:
// global.ally_database in scr_game_database. Rebalance Whitey, and you only ever
// edit it there.
ally_key = "Whitey";

// Kept for backward compatibility with any code that still reads battle_blueprint
// directly. This just mirrors whatever's in the database for this ally_key, so it's
// never a second source of truth; it's generated FROM the database, not typed by hand.
battle_blueprint = (variable_global_exists("ally_database") && struct_exists(global.ally_database, string_lower(ally_key)))
    ? global.ally_database[$ string_lower(ally_key)]
    : {
        name: "Ally",
        hp: 100, max_hp: 100,
        atk: 10, def: 5,
        clover_leaves: 0,
        sprite: spr_npc,
        sprite_idle: spr_npc
      };
