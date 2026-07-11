/// @description Core Battle & Selection Loop

// --- 1. SCREENSHAKE DECAY ---
if (screenshake_amount > 0) {
    screenshake_amount = max(0, screenshake_amount - 0.5);
}

/// @desc Dead Simple Integer Updates

if (room == rm_battle) 
{
    // 1. Scroll by 1 whole pixel per frame (Zero shaking)
    bg_scroll_x += 1;
    bg_scroll_y += 1; 
    
    // 2. Reset back to 0 exactly when we cross a cell size
    if (bg_scroll_x >= 28) bg_scroll_x = 0;
    if (bg_scroll_y >= 36) bg_scroll_y = 0;
    
    // 3. Slow down the master wiggle speed dramatically (Changed from 0.02 to 0.005)
    bg_wiggle_timer += 0.04;
}

// --- 2. HP ODOMETER ROLLING ENGINE ---
var _party_count = array_length(party_members);

for (var _i = 0; _i < _party_count; _i++) {
    var _member = party_members[_i];
    
    if (_member.display_hp != _member.hp) {
        // FIX: Calculate the dynamic roll speed INSIDE the loop, AFTER _member is defined
        var _base_roll_speed = max(0.25, abs(_member.hp - _member.display_hp) * 0.1);
        
        var _diff = _member.hp - _member.display_hp;
        var _step = sign(_diff) * _base_roll_speed;
        
        if (abs(_diff) <= abs(_step)) {
            _member.display_hp = _member.hp;
        } else {
            _member.display_hp += _step;
        }
    }
}

// --- 2b. ENEMY HP ODOMETER ROLLING ENGINE ---
var _enemy_count = array_length(global.active_battle_enemies);
var _enemy_roll_speed = 0.25;

for (var _e_idx = 0; _e_idx < _enemy_count; _e_idx++) {
    var _enemy_inst = global.active_battle_enemies[_e_idx];
    if (instance_exists(_enemy_inst) && variable_instance_exists(_enemy_inst, "display_hp")) {
        if (_enemy_inst.display_hp != _enemy_inst.hp) {
            var _e_diff = _enemy_inst.hp - _enemy_inst.display_hp;
            var _e_step = sign(_e_diff) * _enemy_roll_speed;
            
            if (abs(_e_diff) <= abs(_e_step)) {
                _enemy_inst.display_hp = _enemy_inst.hp;
            } else {
                _enemy_inst.display_hp += _e_step;
            }
        }
    }
}

// --- 3. POPUP NUMBERS MECHANICAL MANAGEMENT ---
if (variable_instance_exists(id, "popup_numbers") && is_array(popup_numbers)) {
    for (var _i = array_length(popup_numbers) - 1; _i >= 0; _i--) {
        var _p = popup_numbers[_i];
        if (is_undefined(_p) || _p == noone || !is_struct(_p)) {
            array_delete(popup_numbers, _i, 1);
            continue;
        }
        
        if (variable_struct_exists(_p, "life")) {
            _p.life -= 1;
            if (_p.life <= 0) {
                array_delete(popup_numbers, _i, 1);
                continue;
            }
            
            var _type = variable_struct_exists(_p, "type") ? _p.type : "number";
            
            if (_type == "jumping_number") {
                if (!variable_struct_exists(_p, "ground_y")) {
                    _p.ground_y = _p.y + 25;
                }
                
                _p.x += _p.hspeed;
                _p.y += _p.vspeed;
                _p.vspeed += _p.gravity; 
                
                if (_p.y > _p.ground_y) {
                    _p.y = _p.ground_y;
                    _p.vspeed = -(_p.vspeed * 0.35);
                    _p.hspeed *= 0.75;
                }
            } else {
                _p.y -= 0.35;
            }
        }
    }
}

// --- 4. NATIVE INPUT ENGINE WITH SUB-STATE DECOUPLING ---
var _key_left  = false, _key_right = false, _key_up = false, _key_down = false, _key_conf = false, _key_back = false;

if (variable_instance_exists(id, "battle_sub_state") && (battle_sub_state == BATTLE_STATE.VICTORY || battle_sub_state == BATTLE_STATE.GAMEOVER)) {
    _key_conf = InputPressed(INPUT_VERB.ACCEPT);
} else {
    _key_left  = InputPressed(INPUT_VERB.LEFT);
    _key_right = InputPressed(INPUT_VERB.RIGHT);
    _key_up    = InputPressed(INPUT_VERB.UP);
    _key_down  = InputPressed(INPUT_VERB.DOWN);
    _key_conf  = InputPressed(INPUT_VERB.ACCEPT); 
    _key_back  = InputPressed(INPUT_VERB.CANCEL);
}

// ==========================================
// STATE LOGIC: CARD SELECTION
// ==========================================
if (global.state == GAME_STATE.CARD_SELECTION) {
    var _card_count = array_length(global.selected_cards);
    if (_card_count > 0) {
        if (card_intro_timer < 1.0) card_intro_timer += 0.03;
        
        if (!variable_instance_exists(id, "card_choice_locked") || !card_choice_locked) {
            if (_key_left) {
                card_cursor = (card_cursor - 1 + _card_count) % _card_count;
            }
            if (_key_right) {
                card_cursor = (card_cursor + 1) % _card_count;
            }
            
            if (_key_conf) {
                var _chosen_card = global.selected_cards[card_cursor];
                if (!_chosen_card.is_revealed) {
                    card_choice_locked = true;
                    global.chosen_battle_card = _chosen_card;
                    
                    var _card_w = 76; 
                    var _spacing = 12;
                    var _total_w = (_card_count * _card_w) + ((_card_count - 1) * _spacing);
                    var _start_x = (display_get_gui_width() - _total_w) / 2;
                    
                    chosen_card_start_x = _start_x + (card_cursor * (_card_w + _spacing));
                    chosen_card_start_y = (display_get_gui_height() - 120) / 2;
                    
                    for (var _i = 0; _i < _card_count; _i++) {
                        global.selected_cards[_i].is_revealed = true;
                    }
                    
                    card_reveal_timer = 60;
                    exit;
                }
            }
        }
        else if (!in_card_transition) {
            card_flip_angle = lerp(card_flip_angle, 0, 0.15);
            if (card_reveal_timer > 0) {
                card_reveal_timer--;
            } else {
                in_card_transition = true;
                transition_timer = 0;
            }
        }
    }
    
    if (in_card_transition) {
        if (transition_timer < transition_duration) {
            transition_timer++;
        } else {
            in_card_transition = false;
            card_choice_locked = false;
            card_intro_timer = 0;
            card_flip_angle = 180;
            card_reveal_timer = -1;
            
            var _chosen_card_struct = global.chosen_battle_card.card_info;
            var _leader = party_members[0];
            if (_chosen_card_struct.buff_type == "atk")    _leader.atk += _chosen_card_struct.value;
            if (_chosen_card_struct.buff_type == "def")    _leader.def += _chosen_card_struct.value;
            if (_chosen_card_struct.buff_type == "max_hp") _leader.max_hp += _chosen_card_struct.value;
            
            global.active_combat_buffs[0] = _chosen_card_struct;
            var _leftover_index = 0;
            var _total_pool_cards = array_length(global.selected_cards);
            
            for (var _i = 0; _i < _total_pool_cards; _i++) {
                var _checked_card = global.selected_cards[_i];
                if (_checked_card != global.chosen_battle_card) {
                    var _ally_party_idx = 1 + _leftover_index;
                    if (_ally_party_idx < party_max_members) {
                        var _ally = party_members[_ally_party_idx];
                        var _ally_card_data = _checked_card.card_info;
                        
                        if (_ally_card_data.buff_type == "atk")    _ally.atk += _ally_card_data.value;
                        if (_ally_card_data.buff_type == "def")    _ally.def += _ally_card_data.value;
                        if (_ally_card_data.buff_type == "max_hp") _ally.max_hp += _ally_card_data.value;
                        
                        global.active_combat_buffs[_ally_party_idx] = _ally_card_data;
                    }
                    _leftover_index++;
                }
            }
            
            global.state = GAME_STATE.BATTLE;
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            menu_stage = BATTLE_MENU.MAIN;
            menu_cursor = 0;
            party_input_index = 0;
        }
    }
    exit;
}

// ==========================================
// STATE LOGIC: ACTIVE TURNS / ARENA COMBAT
// ==========================================
if (global.state == GAME_STATE.BATTLE) {
    
    // --- CRITERIA A: CHECK FOR GAME OVER ---
    var _all_dead = true;
    var _p_count = array_length(party_members);
    
    for (var _p = 0; _p < _p_count; _p++) {
        var _member = party_members[_p];
        if ((is_struct(_member) || instance_exists(_member)) && _member.hp > 0) {
            _all_dead = false;
            break;
        }
    }
    
    if (_all_dead && battle_sub_state != BATTLE_STATE.GAMEOVER) {
        battle_sub_state = BATTLE_STATE.GAMEOVER;
        battle_text = ""; 
    
        var _e_count = array_length(global.active_battle_enemies);
        for (var _e = 0; _e < _e_count; _e++) {
            var _enemy = global.active_battle_enemies[_e];
            if (instance_exists(_enemy)) instance_destroy(_enemy);
        }
    
        global.state = GAME_STATE.PLAYING; 
        room_goto(rm_gameOver);
        instance_destroy(); 
        exit;
    }

    // --- CRITERIA B: CHECK FOR VICTORY ---
    var _enemies_alive = false;
    var _e_count = array_length(global.active_battle_enemies);
    
    for (var _e = 0; _e < _e_count; _e++) {
        var _enemy = global.active_battle_enemies[_e];
        // MODIFIED: An enemy is only "active" if they have HP left AND haven't been spared yet
        if (instance_exists(_enemy) && _enemy.hp > 0 && (!variable_instance_exists(_enemy, "is_spared") || !_enemy.is_spared)) {
            _enemies_alive = true;
            break;
        }
    }
    
    if (!_enemies_alive && battle_sub_state != BATTLE_STATE.VICTORY && battle_sub_state != BATTLE_STATE.GAMEOVER) {
        battle_sub_state = BATTLE_STATE.VICTORY;
        text_char_count = 0; 
        battle_text = "Victory! You won the battle!"; 
        _key_conf = false;
        for (var _e = 0; _e < _e_count; _e++) {
            var _enemy = global.active_battle_enemies[_e];
            if (instance_exists(_enemy)) {
                _enemy.is_dead = true;
            }
        }
    }
    
    // --- TEXT PACING ACCELERATOR ---
    if (battle_text != "" && text_char_count < string_length(battle_text)) {
        text_char_count += 0.5;
    }

    // ------------------------------------------
    // SUB-STATE 1: PLAYER INPUT LATCHING
    // ------------------------------------------
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT) {
        
        if (party_input_index >= party_max_members) {
            battle_sub_state = BATTLE_STATE.TURN_SORTING;
            exit;
        }
        
        if (party_members[party_input_index].hp <= 0) {
            party_input_index++;
            if (party_input_index >= party_max_members) {
                battle_sub_state = BATTLE_STATE.TURN_SORTING;
            }
            exit;
        }
        
        if (menu_stage == BATTLE_MENU.HIT_BAR) {
            hit_bar_progress -= hit_bar_speed;
            var _current_actor = party_members[party_input_index];
            
            if (hit_bar_progress <= 0) {
                _current_actor.chosen_hit_multiplier = 0.0;
                _current_actor.chosen_hit_verdict = "MISS";
                
                party_input_index++; 
                menu_stage = BATTLE_MENU.MAIN;
                menu_cursor = 0;
                if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
            }
            
            if (_key_conf) {
                var _distance = abs(hit_bar_progress - hit_bar_target);
                if (_distance <= 0.04) {
                    _current_actor.chosen_hit_multiplier = 2.0;
                    _current_actor.chosen_hit_verdict = "PERFECT!";
                } else if (_distance <= 0.12) {
                    _current_actor.chosen_hit_multiplier = 1.2;
                    _current_actor.chosen_hit_verdict = "GOOD";
                } else {
                    _current_actor.chosen_hit_multiplier = 0.6;
                    _current_actor.chosen_hit_verdict = "WEAK";
                }
                
                party_input_index++;
                menu_stage = BATTLE_MENU.MAIN;
                menu_cursor = 0;
                if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
            }
            exit;
        }
        
        switch (menu_stage) {
            case BATTLE_MENU.MAIN:
                var _max_actions = 4;
                if (_key_left)  menu_cursor = (menu_cursor - 1 + _max_actions) % _max_actions;
                if (_key_right) menu_cursor = (menu_cursor + 1) % _max_actions;
                
                if (_key_conf) {
                    var _current_actor = party_members[party_input_index];
                    switch (menu_cursor) {
                        case 0: 
                            menu_stage = BATTLE_MENU.TARGET_SELECT;
                            menu_context = "fight";
                            _current_actor.chosen_action_type = "fight";
                            _current_actor.chosen_sub_action  = "";
                            break;
                        case 1: 
                            // Interact now targets an enemy FIRST, then shows that
                            // specific enemy's interact_options list (different enemy
                            // types have different options, e.g. slime vs strong_slime).
                            menu_stage = BATTLE_MENU.TARGET_SELECT;
                            menu_context = "interact_pick_target";
                            break;
                        case 2: 
                            menu_stage = BATTLE_MENU.TAKE_ACTION;
                            break;
                        case 3: 
                            menu_stage = BATTLE_MENU.ITEM_USE;
                            break;
                    }
                    menu_cursor = 0;
                    _key_conf = false; 
                }
                break;
                
            case BATTLE_MENU.TARGET_SELECT:
                var _enemy_count = array_length(global.active_battle_enemies);
                if (_enemy_count > 0) {
                    var _cols = 2;
                    if (_key_right) {
                        if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _enemy_count && global.active_battle_enemies[menu_cursor + 1].hp > 0) menu_cursor += 1;
                        _key_right = false;
                    }
                    if (_key_left) {
                        if (menu_cursor % _cols > 0 && global.active_battle_enemies[menu_cursor - 1].hp > 0) menu_cursor -= 1;
                        _key_left = false;
                    }
                    if (_key_down) {
                        if (menu_cursor + _cols < _enemy_count && global.active_battle_enemies[menu_cursor + _cols].hp > 0) menu_cursor += _cols;
                        _key_down = false;
                    }
                    if (_key_up) {
                        if (menu_cursor - _cols >= 0 && global.active_battle_enemies[menu_cursor - _cols].hp > 0) menu_cursor -= _cols;
                        _key_up = false;
                    }

                    if (global.active_battle_enemies[menu_cursor].hp <= 0) {
                        for (var _i = 0; _i < _enemy_count; _i++) {
                            if (global.active_battle_enemies[_i].hp > 0) {
                                 menu_cursor = _i;
                                 break;
                            }
                        }
                    }

                    if (_key_back) {
                        // "interact_pick_target" is the entry point of the Interact flow now,
                        // so backing out of it goes all the way back to MAIN.
                        menu_stage = BATTLE_MENU.MAIN;
                        menu_cursor = (menu_context == "interact_pick_target") ? 1 : 0; 
                        _key_back = false; 
                        exit;
                    }
                    
                    if (_key_conf) {
                        targeted_enemy_index = menu_cursor;
                        var _target = global.active_battle_enemies[targeted_enemy_index];
                        
                        if (instance_exists(_target) && _target.hp > 0) {
                            var _current_actor = party_members[party_input_index];
                            if (menu_context == "fight") {
                                _current_actor.chosen_target_index = targeted_enemy_index;
                                menu_stage = BATTLE_MENU.HIT_BAR;
                                hit_bar_progress = 1.0;
                                hit_bar_verdict = "";
                            } 
                            else if (menu_context == "interact_pick_target") {
                                // Target chosen — now show THIS enemy's own interact_options list.
                                interact_target_index = targeted_enemy_index;
                                menu_stage = BATTLE_MENU.INTERACT;
                                menu_cursor = 0;
                            }
                            _key_conf = false;
                        }
                    }
                }
                break;
                
            case BATTLE_MENU.INTERACT:
                // Shows the SPECIFIC target enemy's own interact_options list
                // (set from global.enemy_database at spawn time), not a generic list —
                // a slime and a strong_slime have different options here.
                var _interact_target = global.active_battle_enemies[interact_target_index];
                var _options = (instance_exists(_interact_target) && variable_instance_exists(_interact_target, "interact_options"))
                    ? _interact_target.interact_options
                    : ["Check"];
                
                // IMPORTANT: keep the persistent 'interact_options' variable synced to this
                // frame's resolved list. The Draw GUI event almost certainly reads THIS
                // variable (not a local) to render the menu text — without this line it
                // will keep showing whatever list it always displayed, regardless of target.
                interact_options = _options;
                
                var _count = array_length(_options);
                
                if (_count > 0) {
                    if (_key_up || _key_left)   menu_cursor = (menu_cursor - 1 + _count) % _count;
                    if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _count;
                }
                if (_key_back) { 
                    // Go back to re-picking a target, not straight to MAIN
                    menu_stage = BATTLE_MENU.TARGET_SELECT;
                    menu_context = "interact_pick_target";
                    menu_cursor = interact_target_index;
                    _key_back = false; exit; 
                }
                
                if (_key_conf && _count > 0) {
                    var _current_actor = party_members[party_input_index];
                    _current_actor.chosen_action_type = "interact";
                    _current_actor.chosen_sub_action  = _options[menu_cursor];
                    _current_actor.chosen_target_index = interact_target_index;
                    
                    party_input_index++;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                    if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    _key_conf = false;
                }
                break;
                
            case BATTLE_MENU.TAKE_ACTION:
                var _count = array_length(take_action_options);
                if (_count > 0) {
                    if (_key_up || _key_left)   menu_cursor = (menu_cursor - 1 + _count) % _count;
                    if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _count;
                }
                if (_key_back) { 
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 2; _key_back = false; exit; 
                }
                
                if (_key_conf && _count > 0) {
                    var _chosen_action = take_action_options[menu_cursor];
                    var _current_actor = party_members[party_input_index];
                    
                    _current_actor.chosen_action_type = "take_action";
                    _current_actor.chosen_sub_action  = _chosen_action;
                    _current_actor.chosen_target_index = -1;
                    if (_chosen_action == "Defend") _current_actor.is_defending = true; 
                    
                    party_input_index++;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                    if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    _key_conf = false;
                }
                break;
                
           case BATTLE_MENU.ITEM_USE:
                var _inv = obj_item_manager.inv;
                var _item_count = array_length(_inv);

                if (_item_count == 0) {
                    if (_key_back || _key_conf) { 
                        menu_stage = BATTLE_MENU.MAIN;
                        menu_cursor = 3; 
                    }
                    break;
                }

                // --- SYNCHRONIZED PAGINATION NAVIGATION ENGINE ---
                var _cols = 2;
                var _max_visible = 4; // Matches your Draw GUI limits exactly
                var _current_page = floor(menu_cursor / _max_visible);
                var _total_pages = ceil(_item_count / _max_visible);
                var _page_start_idx = _current_page * _max_visible;

                if (_key_right) { 
                    // Move right if we are on the left column and the item exists
                    if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _item_count && (menu_cursor + 1) < (_page_start_idx + _max_visible)) {
                        menu_cursor += 1;
                    }
                }
                if (_key_left)  { 
                    // Move left if we are on the right column
                    if (menu_cursor % _cols > 0) {
                        menu_cursor -= 1;
                    }
                }
                if (_key_down)  { 
                    // Move down a row within the current page
                    if (menu_cursor + _cols < _item_count && (menu_cursor + _cols) < (_page_start_idx + _max_visible)) {
                        menu_cursor += _cols;
                    } else {
                        // Advance to the next page if available
                        var _next_page_idx = menu_cursor + _max_visible - (menu_cursor % _max_visible);
                        if (_next_page_idx < _item_count) {
                            menu_cursor = _next_page_idx;
                        } else {
                            menu_cursor = menu_cursor % _cols; // Wrap back to top row of page 1
                        }
                    }
                }
                if (_key_up)    { 
                    // Move up a row within the current page
                    if (menu_cursor - _cols >= _page_start_idx) {
                        menu_cursor -= _cols;
                    } else {
                        // Move back to previous page
                        if (_current_page > 0) {
                            menu_cursor = menu_cursor - _max_visible;
                        } else {
                            // Wrap to the very last item of the last page
                            menu_cursor = _item_count - 1;
                        }
                    }
                }

                if (_key_back) { 
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 3; 
                    exit;
                }

                if (_key_conf) {
                    var _current_actor = party_members[party_input_index];
                    var _chosen_item = _inv[menu_cursor];
                    
                    _current_actor.chosen_action_type = "item";
                    _current_actor.chosen_item_reference = _chosen_item;
                    // No dedicated recipient-select screen anymore: item is used on whoever picked it.
                    _current_actor.chosen_target_index = party_input_index;
                    
                    // FIX: remove the item from the shared inventory the instant it's chosen,
                    // so it physically can't be picked again by another party member this round.
                    array_delete(_inv, menu_cursor, 1);
                    
                    party_input_index++;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                    
                    if (party_input_index >= party_max_members) {
                        battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    }
					_key_conf = false;
                }
                break;
        }
    }
	// ------------------------------------------
    // SUB-STATE 2: TURN SORTING & QUEUE BUILDING
    // Priority order: Defend/Flee/Spare > Item > Interact > Attack.
    // Enemies always attack, so they land in the last tier.
    // Within each tier, order is randomized.
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.TURN_SORTING) {
        // Tier 0 = take_action (Defend/Flee/Spare), 1 = item, 2 = interact, 3 = attack
        var _tiers = array_create(4);
        for (var _t = 0; _t < 4; _t++) _tiers[_t] = [];
        
        var _party_count = array_length(party_members);
        for (var _i = 0; _i < _party_count; _i++) {
            var _member = party_members[_i];
            if (_member.hp <= 0) continue;
            
            var _act_type = variable_struct_exists(_member, "chosen_action_type") ? _member.chosen_action_type : "fight";
            var _targ_idx = variable_struct_exists(_member, "chosen_target_index") ? _member.chosen_target_index : 0;
            var _sub_act  = variable_struct_exists(_member, "chosen_sub_action")  ? _member.chosen_sub_action  : "";
            var _item_ref = variable_struct_exists(_member, "chosen_item_reference") ? _member.chosen_item_reference : undefined;
            
            var _entry = {
                actor_type: "party",
                actor_index: _i,
                chosen_action_type: _act_type,
                chosen_target_index: _targ_idx,
                chosen_sub_action: _sub_act,
                chosen_item_reference: _item_ref
            };
            
            var _tier = 3; // default: attack
            switch (_act_type) {
                case "take_action": _tier = 0; break;
                case "item":        _tier = 1; break;
                case "interact":    _tier = 2; break;
                case "fight":       _tier = 3; break;
            }
            array_push(_tiers[_tier], _entry);
        }
        
        var _enemy_count = array_length(global.active_battle_enemies);
        for (var _i = 0; _i < _enemy_count; _i++) {
            var _enemy = global.active_battle_enemies[_i];
            if (!instance_exists(_enemy) || _enemy.hp <= 0) continue;
            
            var _living_targets = [];
            for (var _p_check = 0; _p_check < _party_count; _p_check++) {
                if (party_members[_p_check].hp > 0) array_push(_living_targets, _p_check);
            }
            
            var _target_party_idx = 0;
            if (array_length(_living_targets) > 0) {
                _target_party_idx = _living_targets[irandom(array_length(_living_targets) - 1)];
            }
            
            array_push(_tiers[3], {
                actor_type: "enemy",
                actor_instance: _enemy,
                actor_index: _i,
                target_index: _target_party_idx
            });
        }
        
        // Shuffle each tier independently (Fisher-Yates), then concatenate in priority order
        turn_queue = [];
        for (var _t = 0; _t < 4; _t++) {
            var _bucket = _tiers[_t];
            var _n = array_length(_bucket);
            for (var _s = _n - 1; _s > 0; _s--) {
                var _j = irandom(_s);
                var _tmp = _bucket[_s];
                _bucket[_s] = _bucket[_j];
                _bucket[_j] = _tmp;
            }
            for (var _k = 0; _k < _n; _k++) {
                array_push(turn_queue, _bucket[_k]);
            }
        }
        
        battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
    }
    // ------------------------------------------
    // SUB-STATE 3: EXECUTING INDIVIDUAL QUEUE ENTRIES
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.TURN_PROCESSING) {
        if (array_length(turn_queue) == 0) {
            for (var _i = 0; _i < array_length(party_members); _i++) {
                party_members[_i].is_defending = false;
            }
            party_input_index = 0;
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            menu_stage = BATTLE_MENU.MAIN;
            menu_cursor = 0;
            battle_text = "";
            text_char_count = 0; 
            exit;
        }
        
        current_turn_act = array_shift(turn_queue);
        action_timer = 120; 
        text_char_count = 0;
        
        if (current_turn_act.actor_type == "party") {
            var _actor = party_members[current_turn_act.actor_index];
            if (_actor.hp <= 0) {
                battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
                exit;
            }
    
            switch (current_turn_act.chosen_action_type) {
                case "fight":
                    var _t_idx = current_turn_act.chosen_target_index;
                    var _target = global.active_battle_enemies[_t_idx];
                    
                    if (!instance_exists(_target) || _target.hp <= 0) {
                        var _enemy_count = array_length(global.active_battle_enemies);
                        for (var _e = 0; _e < _enemy_count; _e++) {
                            var _potential_foe = global.active_battle_enemies[_e];
                            if (instance_exists(_potential_foe) && _potential_foe.hp > 0) {
                                _t_idx = _e;
                                _target = _potential_foe;
                                current_turn_act.chosen_target_index = _e; 
                                break;
                            }
                        }
                    }
                    
                    if (instance_exists(_target) && _target.hp > 0) {
                        var _mult = variable_instance_exists(_actor, "chosen_hit_multiplier") ? _actor.chosen_hit_multiplier : 1.0;
                        var _verd = variable_instance_exists(_actor, "chosen_hit_verdict") ? _actor.chosen_hit_verdict : "HIT";
                        if (is_undefined(_mult) || !is_real(_mult)) _mult = 1.0;
                        var _damage = max(1, _actor.atk - _target.def);
                        _damage = ceil(_damage * _mult);
        
                        _target.hp = max(0, _target.hp - _damage);
                        var _spawn_x = _target.x - camera_get_view_x(view_camera[0]);
                        var _spawn_y = (_target.y - camera_get_view_y(view_camera[0])) - 15;
                        if (!variable_instance_exists(_target, "display_hp")) {
                            _target.display_hp = _target.hp + _damage;
                        }
        
                        array_push(popup_numbers, {
                            type: "jumping_number", 
                            x: _spawn_x,
                            y: _spawn_y,
                            hspeed: random_range(-1.5, 1.5),
                            vspeed: random_range(-4.0, -2.0),
                            gravity: 0.2,
                            text: string(_damage),
                            life: 45,
                            max_life: 45,
                            color: (_mult >= 1.5) ? c_yellow : c_white
                        });
                        battle_text = string(_actor.name) + " attacks " + string(_target.name) + "! " + string(_verd);
                        screenshake_amount = (_mult >= 1.5) ? 5 : 2;
                    } else {
                        battle_text = _actor.name + " swung, but no enemies were left!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
            
                case "interact":
                    var _t_idx = current_turn_act.chosen_target_index;
                    var _target = global.active_battle_enemies[_t_idx];
                    
                    // (Keep your dead target redirection code here)
                    
                    if (instance_exists(_target) && _target.hp > 0) {
                        var _e_name = variable_instance_exists(_target, "name") ? _target.name : "Enemy";
                        var _sub_action = current_turn_act.chosen_sub_action;
                        
                        if (_sub_action == "Check") {
                            // Check is purely informational: reveal stats, no mercy change.
                            battle_text = _actor.name + " checked " + string(_e_name) + "! ATK: " + string(_target.atk) + " DEF: " + string(_target.def);
                        }
                        else if (variable_global_exists("interact_effects") && struct_exists(global.interact_effects, _sub_action)) {
                            // Data-driven: mercy delta + flavor text come from scr_game_database,
                            // so new interact options only need a database entry, not new code here.
                            var _effect = global.interact_effects[$ _sub_action];
                            var _flavor = string_replace(_effect.flavor, "{name}", string(_e_name));
                            battle_text = _actor.name + " " + _flavor;
                            
                            if (variable_instance_exists(_target, "mercy")) {
                                _target.mercy = clamp(_target.mercy + _effect.mercy_delta, 0, _target.max_mercy);
                                if (_target.mercy >= _target.max_mercy) { _target.can_spare = true; }
                            }
                        }
                        else {
                            // Catch-all fallback in case an option was typed in the database but not coded here yet
                            battle_text = _actor.name + " tried to " + string(_sub_action) + " with " + string(_e_name) + ", but nothing happened.";
                        }
                        
                        // Extra check: Provide visual feedback if they hit the mercy threshold this turn
                        if (variable_instance_exists(_target, "can_spare") && _target.can_spare) {
                            battle_text += " [Can now be SPARED]";
                        }
                        
                    } else {
                        battle_text = _actor.name + " looked around, but everything was quiet!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
                case "take_action":
                    if (current_turn_act.chosen_sub_action == "Defend") { 
                        battle_text = _actor.name + " is guarding safely!";
                    } else if (current_turn_act.chosen_sub_action == "Flee") { 
                        battle_text = "Escaping from battle layout...";
                    } 
                    // --- NEW SPARE PROCESSING STATE ---
                    else if (current_turn_act.chosen_sub_action == "Spare") {
                        var _spared_any = false;
                        var _names_spared = "";
                        var _e_count = array_length(global.active_battle_enemies);
                        
                        for (var _e = 0; _e < _e_count; _e++) {
                            var _enemy = global.active_battle_enemies[_e];
                            
                            if (instance_exists(_enemy) && _enemy.hp > 0 && (!variable_instance_exists(_enemy, "is_spared") || !_enemy.is_spared)) {
                                // Fallback structures to ensure no object errors occur
                                var _can_spare = variable_instance_exists(_enemy, "can_spare") ? _enemy.can_spare : false;
                                
                                if (_can_spare) {
                                    _enemy.is_spared = true;
                                    _enemy.visible = false; // Make their sprite disappear from the arena floor
                                    
                                    if (_names_spared != "") _names_spared += ", ";
                                    _names_spared += _enemy.name;
                                    _spared_any = true;
                                    
                                    // Optional: Add to a global non-lethal gold counter here
                                    if (variable_instance_exists(_enemy, "gold_value")) {
                                        global.battle_gold_earned = (variable_global_exists("battle_gold_earned") ? global.battle_gold_earned : 0) + _enemy.gold_value;
                                    }
                                }
                            }
                        }
                        
                        if (_spared_any) {
                            battle_text = _actor.name + " spared " + _names_spared + "!";
                        } else {
                            battle_text = _actor.name + " offered mercy, but no one was willing to accept it yet.";
                        }
                    } else { 
                        battle_text = _actor.name + " focused power!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
				case "item":
                    // Item was already removed from inventory at selection time (see ITEM_USE),
                    // and the actual item struct was captured onto the actor then, so we just
                    // read it straight off the queued turn entry — no re-lookup, no crash risk.
                    var _target_idx = current_turn_act.chosen_target_index;
                    var _live_target = party_members[_target_idx];
                    var _item = current_turn_act.chosen_item_reference;
                    
                    // HEAL EFFECT CALCULATIONS
                    var _heal_amt = 25; // Constant reliable baseline
                    if (is_struct(_item)) {
                        if (_item.name == "Apple") _heal_amt = 10;
                        else if (_item.name == "Bread") _heal_amt = 5;
                        else if (_item.name == "Hamburger") _heal_amt = 25;
                    }
                    
                    // Determine maximum HP boundary parameters dynamically
                    var _max_limit = 100;
                    if (variable_struct_exists(_live_target, "max_hp")) _max_limit = _live_target.max_hp;
                    else if (variable_struct_exists(_live_target, "hp_max")) _max_limit = _live_target.hp_max;
                    else if (variable_struct_exists(_live_target, "player_hp_max")) _max_limit = _live_target.player_hp_max;
                    
                    // Update HP safely within maximum boundary limits
                    _live_target.hp = min(_live_target.hp + _heal_amt, _max_limit);
                    
                    // Mirror health state back onto overworld tracker variables if Player 1 is updated
                    if (_target_idx == 0) {
                        global.player_hp = _live_target.hp;
                    }
                    
                    var _item_name = is_struct(_item) ? string(_item.name) : "Item";
                    battle_text = _actor.name + " used " + _item_name + " on " + _live_target.name + "!";
                    
                    // Spawn popup green jumping indicator numbers
                    var _spawn_x = 100 + (_target_idx * 160);
                    var _spawn_y = display_get_gui_height() - 120;
                    
                    array_push(popup_numbers, {
                        type: "jumping_number",
                        x: _spawn_x,
                        y: _spawn_y,
                        hspeed: random_range(-0.6, 0.6),
                        vspeed: random_range(-3.5, -2.0),
                        gravity: 0.18,
                        text: "+" + string(_heal_amt),
                        life: 60,
                        max_life: 60,
                        color: c_lime
                    });
                    
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
            }
        }
        else if (current_turn_act.actor_type == "enemy") {
            var _actor = current_turn_act.actor_instance;
            if (!instance_exists(_actor) || _actor.hp <= 0) {
                battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
                exit;
            }
            
            var _t_idx = current_turn_act.target_index;
            var _target = party_members[_t_idx];
            
            if (_target.hp <= 0) {
                var _p_count = array_length(party_members);
                for (var _p = 0; _p < _p_count; _p++) {
                    if (party_members[_p].hp > 0) {
                        _t_idx = _p;
                        _target = party_members[_p];
                        current_turn_act.target_index = _p;
                        break;
                    }
                }
            }
            
            if (_target.hp > 0) {
                var _is_guarding = variable_instance_exists(_target, "is_defending") ? _target.is_defending : false;
                var _damage = max(1, _actor.atk - _target.def);
                if (_is_guarding) _damage = ceil(_damage * 0.5);
                
                _target.hp = max(0, _target.hp - _damage);
                var _e_name = variable_instance_exists(_actor, "name") ? _actor.name : "Enemy";
                battle_text = string(_e_name) + " lunges at " + string(_target.name) + " doing " + string(_damage) + " damage!";
                if (_is_guarding) battle_text += " (Guarded!)";
                
                screenshake_amount = 3;
            } else {
                var _e_name = variable_instance_exists(_actor, "name") ? _actor.name : "Enemy";
                battle_text = string(_e_name) + " lunges, but no active targets were left standing!";
            }
            
            battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
        }
    }
    // ------------------------------------------
    // SUB-STATE 4: ACTION RESOLUTION
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.ACTION_RESOLUTION) {
        if (action_timer > 0) {
            action_timer--;
            if (_key_conf) action_timer = 0;
        } else {
            battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
        }
    }
    // ------------------------------------------
    // SUB-STATE 5: VICTORY SCREEN HOLD WINDOW
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.VICTORY) {
        if (!variable_instance_exists(id, "victory_timer")) victory_timer = 0;
        victory_timer++;
        
        if (text_char_count >= string_length(battle_text) && _key_conf) {
            global.player_hp = party_members[0].hp;
            if (instance_exists(obj_player)) {
                if (ds_exists(obj_player.pos_history, ds_type_list)) {
                    ds_list_clear(obj_player.pos_history);
                }
                with (obj_follower) {
                    x = obj_player.x;
                    y = obj_player.y;
                }
            }
            
            victory_timer = 0;
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            menu_stage = BATTLE_MENU.MAIN;
            menu_cursor = 0;
            party_input_index = 0;
            battle_text = "";
            text_char_count = 0;
            global.state = GAME_STATE.PLAYING;
            
            var _e_count = array_length(global.active_battle_enemies);
            for (var _e = 0; _e < _e_count; _e++) {
                var _enemy = global.active_battle_enemies[_e];
                if (instance_exists(_enemy)) instance_destroy(_enemy);
            }
            
            if (variable_global_exists("overworld_room_fallback") && room_exists(global.overworld_room_fallback)) {
                room_goto(global.overworld_room_fallback);
            } else {
                room_goto_previous();
            }
            exit;
        }
    }
    // -------------------------------------------------------------------------
    // SUB-STATE 6: GAMEOVER STATE
    // -------------------------------------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.GAMEOVER) {
        if (_key_conf) {
            // Room configurations or retry layouts go here
        }
        exit;
    }
}
exit;
