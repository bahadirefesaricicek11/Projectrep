/// @description Initialize Slime Stats Directly From Registry
event_inherited(); 

db_key = "Slime"; // Matches the key in global.enemy_database

// Pull stats directly from master registry safely
if (variable_struct_exists(global.enemy_database, db_key)) {
    var _base = variable_struct_get(global.enemy_database, db_key);
    
    combat_stats = {
        name: _base.name,
        max_hp: _base.max_hp,
        hp: _base.max_hp,
        atk: _base.atk,
        def: _base.def,
        xp_value: _base.xp_value,
        gold_value: _base.gold_value
    };
}

// Customize unique overworld speeds for Slimes
walk_speed = 2.0; 
chase_speed = 3.5;
encounter_id = "forest_ambush";