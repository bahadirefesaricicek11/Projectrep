#macro UI_BOX_PADDING 20
#macro UI_COL_WIDTH 160
#macro UI_LINE_HEIGHT 20
#macro UI_TEXT_SCALE 0.60
/// HP box layout constants (relative to box top-left, box is 56x64)
#macro HPBOX_NAME_X            12
#macro HPBOX_NAME_Y            4

#macro HPBOX_PORTRAIT_X        7
#macro HPBOX_PORTRAIT_Y        28
#macro HPBOX_PORTRAIT_MAX_W    33
#macro HPBOX_PORTRAIT_MAX_H    36

#macro HPBOX_ROLLER_X    62
#macro HPBOX_ROLLER_Y    38
#macro HPBOX_ROLLER_STRIDE 11

#macro HPBOX_BUFF_X            70
#macro HPBOX_BUFF_Y            55
#macro HPBOX_BUFF_W            16
#macro HPBOX_BUFF_H            16

// --- FLEE CONFIG ---
// Chance (0-1) a normal Flee attempt actually succeeds. Doesn't apply at all to
// unfleeable encounters (see MAX_ENCOUNTER_GROUP_SIZE and global.battle_id below).
#macro FLEE_SUCCESS_CHANCE 0.65
// Encounters with this many enemies or more (i.e. a "full group") can't be fled from
// at all, regardless of FLEE_SUCCESS_CHANCE — tune this if your encounter pools in
// global.encounter_database ever spawn larger groups than 3.
#macro MAX_ENCOUNTER_GROUP_SIZE 3

// --- BATTLE TEXT TYPEWRITER CONFIG ---
// Characters revealed per frame. Was hardcoded to 0.5 (30 chars/sec at 60fps) —
// lowered for a more readable pace. Tune to taste.
#macro BATTLE_TEXT_TYPE_SPEED 0.25

// --- CLOVER CRIT METER CONFIG ---
// Player-only crit meter (allies don't have one). Rises 1 leaf per completed round,
// capped at 4. Each leaf adds this much crit chance, so a full meter (4 leaves) is a
// guaranteed crit. Consumed back to 0 the moment a crit actually triggers.
#macro CLOVER_CRIT_CHANCE_PER_LEAF 0.25
#macro CLOVER_CRIT_DAMAGE_MULT 1.5

// --- HIT FLASH CONFIG ---
// Frames a sprite flashes white (additive blend, no shader needed) after taking damage.
#macro HIT_FLASH_DURATION 8

// --- MENU NAVIGATION FEEL CONFIG ---
// Frames of cooldown after any accepted directional menu input, before another
// directional input is accepted. Smooths out menu navigation regardless of whether
// InputPressed fires once per press or continuously while held.
#macro MENU_NAV_COOLDOWN_FRAMES 8


enum BATTLE_STATE {
    PLAYER_INPUT,
    TURN_SORTING,
    ACTION_EXECUTION,
    ACTION_RESOLUTION,
    TURN_PROCESSING,
    ENEMY_TURN,
    VICTORY,
    GAMEOVER,
    DODGE_WINDOW    // NEW: Block-Tales-style QTE window before an enemy attack lands
}
enum BATTLE_MENU {
    MAIN,
    TARGET_SELECT,
    INTERACT,
    TAKE_ACTION,
	ACTION_SELECT,
    ITEM_USE,
    ITEM_TARGET_SELECT,
    HIT_BAR
}
enum ENEMY_AI {
    IDLE,
    WANDER,
    CHASE
}


function battle_system_init() {
    global.card_pool = [
        { name: "Warrior's Will", buff_type: "atk",    value: 5,  desc: "+5 ATK for this battle",       icon_sprite: spr_card_icons, icon_frame: 1 },
        { name: "Iron Wall",     buff_type: "def",    value: 3,  desc: "+3 DEF for this battle",       icon_sprite: spr_card_icons, icon_frame: 0 },
        { name: "Titan's Blood",  buff_type: "max_hp", value: 20, desc: "+20 Max HP for this battle",   icon_sprite: spr_card_icons, icon_frame: 3 }
    ];

    global.selected_cards = []; 
    global.active_battle_enemies = [];
    global.overworld_room = noone; 
    
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_max_hp = 0;
    
    global.battle_spawn_queue = [];
    global.saved_gui_w = 0;
    global.saved_gui_h = 0;
    
    // NEW: identifies which scripted encounter (if any) is currently running, and what
    // its outcome was. "none" means "no scripted encounter is pending a result check" —
    // scr_check_slime_results() (and any future scr_check_*_results()) uses this to know
    // whether it's the one that should react, and clears it back to "none" once handled
    // so it only ever fires once per encounter.
    global.battle_id = "none";
    global.battle_result = "none"; // "killed" / "negotiated" / "fled"
    
    // Slime ambush encounter tracking. slime_ambush_completed is checked by
    // obj_npc_slime's own Create Event to refuse to (re)spawn once the squad has
    // actually been killed — see scr_check_slime_results.
    global.slime_ambush_completed = false;
    global.secret_boss_unlocked = false;
}

function battle_trigger_room_transition(_enemy_id_array) {
    global.battle_spawn_queue = _enemy_id_array;
    global.overworld_room = room; 
	
    room_goto(rm_battle); 
}

function battle_setup_card_selection() {
    global.state = GAME_STATE.CARD_SELECTION;
    global.selected_cards = [];
    
    var _pool_size = array_length(global.card_pool);
    var _temp_pool = array_create(_pool_size);
    array_copy(_temp_pool, 0, global.card_pool, 0, _pool_size);
    
    // Fixed: array_shuffle operates in-place. Do not assign it back.
    array_shuffle(_temp_pool);
    
    var _cards_to_select = min(3, _pool_size);
    for (var _i = 0; _i < _cards_to_select; _i++) {
        var _base_card = _temp_pool[_i];
        
        array_push(global.selected_cards, {
            card_info: _base_card,
            is_revealed: false,
            x: 0, 
            y: 0, 
            width: 76,              
            height: 120,            
            icon_sprite: _base_card.icon_sprite,
            icon_frame: _base_card.icon_frame
        });
    }
}

function battle_apply_card_buff(_card_info) {
    if (_card_info.buff_type == "atk")    global.battle_buff_atk += _card_info.value;
    if (_card_info.buff_type == "def")    global.battle_buff_def += _card_info.value;
    if (_card_info.buff_type == "max_hp") global.battle_buff_max_hp += _card_info.value;
    
    global.selected_cards = [];
    global.state = GAME_STATE.BATTLE;
    
    // Safety check: Ensure the controller actually exists before calling events on it
    if (instance_exists(obj_battle_controller)) {
        with (obj_battle_controller) {
            event_user(0); 
        }
    } else {
        show_debug_message("Warning: obj_battle_controller not found yet. Buff applied globally.");
    }
}

function battle_cleanup_and_return() {
    global.battle_buff_atk = 0;
    global.battle_buff_def = 0;
    global.battle_buff_max_hp = 0;
    
    global.selected_cards = [];
    global.active_battle_enemies = [];
    global.battle_spawn_queue = [];
    
    global.state = GAME_STATE.PLAYING;
    
    if (room_exists(global.overworld_room)) {
        room_goto(global.overworld_room);
    }
}

function battle_generate_party(_encounter_key) {
    if (!variable_global_exists("encounter_database") || !variable_struct_exists(global.encounter_database, _encounter_key)) {
        return ["slime"]; 
    }
    
    var _data = global.encounter_database[$ _encounter_key];
    
    // Fixed: irandom_range(1, 100) can break if weight_total is 100 but items add up to 99 due to human error.
    // Optimized to use standard 0-indexing layout matching custom pool calculations.
    var _roll = irandom(_data.weight_total - 1);
    var _current_weight = 0;
    var _pool_count = array_length(_data.pools);
    
    for (var _i = 0; _i < _pool_count; _i++) {
        var _option = _data.pools[_i];
        _current_weight += _option.weight;
        
        if (_roll < _current_weight) {
            return _option.enemies; 
        }
    }
    
    return _data.pools[0].enemies; // Default fallback to first pool item instead of a hardcoded string
}

function battle_kill_enemy(_index) {
    if (_index >= 0 && _index < array_length(global.active_battle_enemies)) {
        var _dead_enemy = global.active_battle_enemies[_index];
        
        // 1. Remove the instance pointer from your logic array first
        array_delete(global.active_battle_enemies, _index, 1);
        
        // 2. Safely trigger death VFX / destruction on the actual object instance
        if (instance_exists(_dead_enemy)) {
            with (_dead_enemy) {
                // Insert death animation/fade shader triggers here
                instance_destroy();
            }
        }
    }
}

function battle_spawn_hit_particles(_x, _y, _color) {
    if (!instance_exists(obj_battle_controller)) exit;
    
    // Safety fallback color
    var _p_color = (argument_count > 2) ? _color : c_white;
    var _count = irandom_range(10, 15);
    
    for (var _i = 0; _i < _count; _i++) {
        var _dir = random(360);
        var _spd = random_range(1.5, 4);
        var _p_life = irandom_range(20, 35);
        
        var _particle = {
            type: "particle", // <-- CRITICAL: MUST MATCH STEP/DRAW EVENTS EXACTLY
            x: _x,
            y: _y,
            hspeed: lengthdir_x(_spd, _dir),
            vspeed: lengthdir_y(_spd, _dir),
            gravity: 0.12,
            life: _p_life,
            max_life: _p_life, // NEW: Draw GUI uses this to fade accurately (life/max_life)
            color: _p_color,
            size: irandom_range(2, 4)
        };
        
        array_push(obj_battle_controller.popup_numbers, _particle);
    }
}

/// scr_generate_party_formation(member_count)
/// Builds the battle position array for the party based on a simple formation rule:
/// slot 0 = main player (front), slots 1+ = allies stacked vertically behind.
function scr_generate_party_formation(_member_count) {
    var _positions = [];

    // --- Formation config: tweak these to reshape the whole layout at once ---
    var _front_x = 31;        // main player x
    var _front_y = 80;        // main player y

    var _ally_x = 75;         // all allies share this x
    var _ally_start_y = 105;  // first ally's y
    var _ally_spacing_y = 50; // vertical gap between allies

    for (var _i = 0; _i < _member_count; _i++) {
        if (_i == 0) {
            array_push(_positions, { x: _front_x, y: _front_y });
        } else {
            var _ally_index = _i - 1;
            array_push(_positions, {
                x: _ally_x,
                y: _ally_start_y + (_ally_index * _ally_spacing_y)
            });
        }
    }

    return _positions;
}

/// @desc Draws a solid, gapless ring (annulus) as real filled geometry via triangle
/// strip — reliable at any radius/thickness, unlike stacking draw_circle outlines,
/// which can show visible gaps or inconsistent thickness at larger sizes.
function draw_ring_solid(_x, _y, _inner_radius, _outer_radius, _color, _alpha = 1.0) {
    var _segments = 48; // smoothness; cheap enough for a HUD-sized element
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= _segments; _i++) {
        var _angle = (_i / _segments) * 360;
        var _ox = _x + lengthdir_x(_outer_radius, _angle);
        var _oy = _y + lengthdir_y(_outer_radius, _angle);
        var _ix = _x + lengthdir_x(_inner_radius, _angle);
        var _iy = _y + lengthdir_y(_inner_radius, _angle);
        draw_vertex_color(_ox, _oy, _color, _alpha);
        draw_vertex_color(_ix, _iy, _color, _alpha);
    }
    draw_primitive_end();
}

/// scr_draw_sprite_fit(sprite, frame, box_x, box_y, max_w, max_h, color, alpha)
/// Draws a sprite scaled down (never up) to fit within max_w x max_h,
/// anchored to the bottom-left corner of that zone — regardless of the
/// sprite's own origin point (works for top-left, center, or any origin).
function scr_draw_sprite_fit(_sprite, _frame, _box_x, _box_y, _max_w, _max_h, _color, _alpha) {
    if (!sprite_exists(_sprite)) return;

    var _spr_w = sprite_get_width(_sprite);
    var _spr_h = sprite_get_height(_sprite);
    if (_spr_w <= 0 || _spr_h <= 0) return;

    var _fit_scale = min(1.0, min(_max_w / _spr_w, _max_h / _spr_h));

    var _target_left = _box_x;
    var _target_top   = _box_y + _max_h - (_spr_h * _fit_scale);

    // sprite_get_xoffset/yoffset return the origin's distance from the sprite's
    // own top-left corner, in unscaled sprite pixels — this works no matter
    // where the origin actually is (top-left, center, bottom-center, etc.)
    var _origin_x = sprite_get_xoffset(_sprite) * _fit_scale;
    var _origin_y = sprite_get_yoffset(_sprite) * _fit_scale;

    draw_sprite_ext(_sprite, _frame, _target_left + _origin_x, _target_top + _origin_y, _fit_scale, _fit_scale, 0, _color, _alpha);
}
/// @desc Battle Background Configuration Mapping

function battle_get_background_sprite() {
    switch (global.overworld_room) {
        case rm_forest_1:
        case rm_forest_2:
			return spr_bg_icon_tree;

        default:
            return spr_bg_icon_default;
    }
}
function battle_get_background_color() {
    switch (global.overworld_room) {
        case rm_forest_1:
        case rm_forest_2:
			return make_color_rgb(25, 51, 45);

        default:
            return make_color_rgb(20, 15, 35);
    }
}

/**
 * @desc Spawns an enemy instance and populates all runtime variables from the master database
 * @param {String} _enemy_key The key name in global.enemy_database (e.g., "slime")
 * @param {Real} _x Target x position in the battle room
 * @param {Real} _y Target y position in the battle room
 * @param {Asset.GMObject} _object_index The object asset to instantiate (defaults to obj_battle_enemy_parent)
 * @return {Id.Instance} The created enemy instance ID
 */
function battle_spawn_enemy(_enemy_key, _x, _y, _object_index = obj_battle_enemy_parent) {
    // 1. Safety check: Verify the database and key exist
    if (!variable_global_exists("enemy_database") || !variable_struct_exists(global.enemy_database, _enemy_key)) {
        show_debug_message("ERROR: Enemy key '" + string(_enemy_key) + "' not found in database. Falling back to default slime.");
        _enemy_key = "slime";
    }
    
    var _data = global.enemy_database[$ _enemy_key];
    
    // 2. Prepare deep copies of dynamic reference types (Arrays/Structs) safely BEFORE injection
    var _final_interact = ["Check"];
    if (variable_struct_exists(_data, "interact_options") && is_array(_data.interact_options)) {
        var _len = array_length(_data.interact_options);
        _final_interact = array_create(_len);
        array_copy(_final_interact, 0, _data.interact_options, 0, _len);
    }

    // 3. Construct injection payload. 
    // These variables are guaranteed to exist BEFORE the instance's Create Event executes.
    var _init_vars = {
        enemy_id : _enemy_key,
        name : variable_struct_exists(_data, "name") ? _data.name : "Unknown Enemy",
        max_hp : variable_struct_exists(_data, "max_hp") ? _data.max_hp : 10,
        hp : variable_struct_exists(_data, "max_hp") ? _data.max_hp : 10,
        atk : variable_struct_exists(_data, "atk") ? _data.atk : 1,
        def : variable_struct_exists(_data, "def") ? _data.def : 0,
        xp_value : variable_struct_exists(_data, "xp_value") ? _data.xp_value : 0,
        gold_value : variable_struct_exists(_data, "gold_value") ? _data.gold_value : 0,
        sprite_index : variable_struct_exists(_data, "sprite") ? _data.sprite : asset_get_index("spr_default_enemy_fallback"),
        
        // Mercy engine properties
        mercy : 0,
        max_mercy : variable_struct_exists(_data, "max_mercy") ? _data.max_mercy : 100,
        can_spare : false,
        is_spared : false,
        interact_options : _final_interact
    };
    
    // 4. Create the instance with safe pre-packaged data injection
    var _inst = instance_create_depth(_x, _y, 0, _object_index, _init_vars);
    
    // 5. Register into your global tracking array safely
    if (variable_global_exists("active_battle_enemies") && is_array(global.active_battle_enemies)) {
        array_push(global.active_battle_enemies, _inst);
    } else {
        show_debug_message("Warning: global.active_battle_enemies array not initialized. Instance spawned unregistered.");
    }
    
    return _inst;
}

/**
 * @desc Starts the scripted slime ambush encounter. Sets global.battle_id so
 * scr_check_slime_results() (called from obj_player's Room Start once the player is
 * back in the overworld) knows this specific scripted battle is the one to react to,
 * as opposed to any other battle — scripted or random — that might happen later.
 */
function scr_start_slime_battle() {
    global.battle_id = "slime_ambush";
    global.battle_result = "none"; // defensive reset, in case a previous battle left a stale value
    battle_trigger_room_transition(["slime", "slime", "slime"]);
}

/**
 * @desc Reacts to how the slime ambush battle actually ended. Safe to call every time
 * the player enters any room (it no-ops unless global.battle_id == "slime_ambush"),
 * and clears the flag once handled so it can never fire twice for the same battle.
 */
function scr_check_slime_results() {
    if (global.battle_id != "slime_ambush") return;
    
    switch (global.battle_result) {
        case "killed":
            // Conditions met: They chose violence
            global.secret_boss_unlocked = true;
            
            // The squad is gone for good — obj_npc_slime's own Create Event checks
            // this same flag to refuse to (re)spawn on any FUTURE room load. But this
            // function runs from Room Start, which always fires AFTER every instance's
            // Create Event has already run — so on THIS first return trip, the NPC
            // would already exist (having just failed to see the flag in time) unless
            // we also destroy it directly, right here, right now.
            global.slime_ambush_completed = true;
            with (obj_npc_slime) {
                instance_destroy();
            }
            break;
            
        case "negotiated":
            // Settled peacefully: "Everything normal" — the NPC stays, so
            // global.slime_ambush_completed is deliberately NOT set here.
            global.secret_boss_unlocked = false;
            
            // FIX: was a hardcoded instance ID (inst_3E43B7A1), which isn't stable
            // across room edits or reloads. `with (obj_npc_slime)` finds whichever
            // instance(s) actually exist in the CURRENT room instead — the same
            // pattern already used elsewhere in this project (e.g. `with (obj_follower)`).
            // Runs AFTER obj_npc_slime's own Create Event (which sets its default
            // text_id), since Room Start always fires after every instance's Create
            // Event has already completed — so this correctly overrides it.
            with (obj_npc_slime) {
                text_id = "slime_post_negotiated";
            }
            break;
            
        case "fled":
            // Ran away: Slimes are still there waiting — same as negotiated,
            // global.slime_ambush_completed stays unset so the NPC keeps existing
            // and the fight can be retried.
            global.secret_boss_unlocked = false;
            break;
    }
    
    // Clear flag to avoid continuous triggers
    global.battle_id = "none";
}
