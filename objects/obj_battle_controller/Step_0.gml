/// @description Process Inputs, States & Turn Loop Lifecycles

// --- 1. SCREENSHAKE DECAY ---
if (screenshake_amount > 0) {
    screenshake_amount -= 0.5;
    if (screenshake_amount < 0) screenshake_amount = 0;
}

// --- 2. HP ODOMETER ROLLING ENGINE ---
var _party_count = array_length(party_members);
var _base_roll_speed = 0.15;

for (var _i = 0; _i < _party_count; _i++) {
    var _member = party_members[_i];
    if (_member.display_hp != _member.hp) {
        var _diff = _member.hp - _member.display_hp;
        var _dir = sign(_diff);
        var _step = _dir * _base_roll_speed;
        
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
            var _e_dir = sign(_e_diff);
            var _e_step = _e_dir * _enemy_roll_speed;
            
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
var _key_left  = false;
var _key_right = false;
var _key_up    = false;
var _key_down  = false;
var _key_conf  = false;
var _key_back  = false;

// Only poll active physical buttons if we aren't displaying the victory message
if (variable_instance_exists(id, "battle_sub_state") && battle_sub_state == BATTLE_STATE.VICTORY) {
    // Check if our 1-second unskippable delay has cleared
    if (variable_instance_exists(id, "victory_timer") && victory_timer >= 60) {
        // Only accept a clean, fresh press to dismiss the screen
        _key_conf = InputPressed(INPUT_VERB.ACCEPT);
    }
} else {
    // Normal combat loop input reading
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
        if (card_intro_timer < 1.0) {
            card_intro_timer += 0.03;
        }
        
        if (!variable_instance_exists(id, "card_choice_locked") || !card_choice_locked) {
            if (_key_left) {
                card_cursor--;
                if (card_cursor < 0) card_cursor = _card_count - 1; 
            }
            
            if (_key_right) {
                card_cursor++;
                if (card_cursor >= _card_count) card_cursor = 0;
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
            if (_chosen_card_struct.buff_type == "spd")    _leader.spd += _chosen_card_struct.value;
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
                        if (_ally_card_data.buff_type == "spd")    _ally.spd += _ally_card_data.value;
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
        if (is_struct(_member) || instance_exists(_member)) {
            if (_member.hp > 0) {
                _all_dead = false;
                break;
            }
        }
    }
    
    if (_all_dead) {
        global.state = GAME_STATE.GAMEOVER;
        room_goto(rm_gameOver);
        exit;
    }

    // --- CRITERIA B: CHECK FOR VICTORY ---
    var _enemies_alive = false;
    var _e_count = array_length(global.active_battle_enemies);
    
    for (var _e = 0; _e < _e_count; _e++) {
        var _enemy = global.active_battle_enemies[_e];
        if (instance_exists(_enemy) && _enemy.hp > 0) {
            _enemies_alive = true;
            break;
        }
    }
    
    if (!_enemies_alive && battle_sub_state != BATTLE_STATE.VICTORY) {
        battle_sub_state = BATTLE_STATE.VICTORY;
        text_char_count = 0; 
        battle_text = "Victory! You won the battle!"; 
        
        // FORCE INPUT CLEAR ON THE INITIAL MATRIX FRAMESHIFT
        _key_conf = false; 
        
        // Flag them as dead so they stop acting
        for (var _e = 0; _e < _e_count; _e++) {
            var _enemy = global.active_battle_enemies[_e];
            if (instance_exists(_enemy)) {
                _enemy.is_dead = true; 
            }
        }
    }
    
    // --- TEXT PACING ACCELERATOR ---
    if (battle_text != "") {
        if (text_char_count < string_length(battle_text)) {
            text_char_count += 0.5;
        }
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
        
        // Handle the real-time Hit Bar calculation sequence
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
                        case 0: // FIGHT
                            menu_stage = BATTLE_MENU.TARGET_SELECT;
                            menu_context = "fight";
                            _current_actor.chosen_action_type = "fight";
                            _current_actor.chosen_sub_action  = "";
                            break;
                        case 1: // INTERACT
                            menu_stage = BATTLE_MENU.INTERACT;
                            break;
                        case 2: // TAKE ACTION
                            menu_stage = BATTLE_MENU.TAKE_ACTION;
                            break;
                        case 3: // ITEM
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
                    var _cols = 2; // Matches your Draw GUI column layout grid
                    
                    // --- GRID-BASED MENU NAVIGATION ---
                    if (_key_right) {
                        // Move right only if we aren't on the right edge and the target slot exists
                        if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _enemy_count) {
                            var _next = menu_cursor + 1;
                            if (global.active_battle_enemies[_next].hp > 0) menu_cursor = _next;
                        }
                        _key_right = false;
                    }
                    if (_key_left) {
                        // Move left only if we aren't on the left boundary column
                        if (menu_cursor % _cols > 0) {
                            var _prev = menu_cursor - 1;
                            if (global.active_battle_enemies[_prev].hp > 0) menu_cursor = _prev;
                        }
                        _key_left = false;
                    }
                    if (_key_down) {
                        // Jump down a full row block (+2 slots)
                        if (menu_cursor + _cols < _enemy_count) {
                            var _down = menu_cursor + _cols;
                            if (global.active_battle_enemies[_down].hp > 0) menu_cursor = _down;
                        }
                        _key_down = false;
                    }
                    if (_key_up) {
                        // Jump up a full row block (-2 slots)
                        if (menu_cursor - _cols >= 0) {
                            var _up = menu_cursor - _cols;
                            if (global.active_battle_enemies[_up].hp > 0) menu_cursor = _up;
                        }
                        _key_up = false;
                    }

                    // Emergency safety sweep: If cursor lands on a dead target, find first living
                    if (global.active_battle_enemies[menu_cursor].hp <= 0) {
                        for (var _i = 0; _i < _enemy_count; _i++) {
                            if (global.active_battle_enemies[_i].hp > 0) {
                                menu_cursor = _i;
                                break;
                            }
                        }
                    }

                    if (_key_back) {
                        menu_stage = (menu_context == "interact") ? BATTLE_MENU.INTERACT : BATTLE_MENU.MAIN;
                        menu_cursor = 0; 
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
                            else if (menu_context == "interact") {
                                _current_actor.chosen_action_type = "interact";
                                _current_actor.chosen_sub_action  = selected_sub_action;
                                _current_actor.chosen_target_index = targeted_enemy_index;
                                
                                party_input_index++;
                                menu_stage = BATTLE_MENU.MAIN;
                                menu_cursor = 0;
                                if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
                            }
                            _key_conf = false;
                        }
                    }
                }
                break;
                
            case BATTLE_MENU.INTERACT:
                var _count = array_length(interact_options);
                if (_count > 0) {
                    if (_key_up || _key_left)   menu_cursor = (menu_cursor - 1 + _count) % _count;
                    if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _count;
                }
                if (_key_back) { 
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 1; _key_back = false; exit; 
                }
                
                if (_key_conf && _count > 0) {
                    selected_sub_action = interact_options[menu_cursor];
                    menu_stage = BATTLE_MENU.TARGET_SELECT;
                    menu_context = "interact";
                    menu_cursor = 0;
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

                var _cols = 2;
                if (_key_right) { 
                    if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _item_count) menu_cursor += 1;
                    else menu_cursor -= (menu_cursor % _cols); 
                }
                if (_key_left)  { 
                    if (menu_cursor % _cols > 0) menu_cursor -= 1;
                    else { var _tr = menu_cursor + (_cols - 1); menu_cursor = (_tr < _item_count) ? _tr : _item_count - 1; } 
                }
                if (_key_down)  { 
                    if (menu_cursor + _cols < _item_count) menu_cursor += _cols;
                    else menu_cursor = menu_cursor % _cols; 
                }
                if (_key_up)    { 
                    if (menu_cursor - _cols >= 0) menu_cursor -= _cols;
                    else { var _lr = menu_cursor; while (_lr + _cols < _item_count) { _lr += _cols; } menu_cursor = _lr; } 
                }

                if (_key_back) { 
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 3; 
                }

                if (_key_conf) {
                    pending_item = _inv[menu_cursor];
                    obj_item_manager.selected_item = menu_cursor;
                    menu_stage = BATTLE_MENU.ITEM_TARGET_SELECT;
                    menu_cursor = 0; 
                }
                break;
                
            case BATTLE_MENU.ITEM_TARGET_SELECT:
                var _party_count = array_length(party_members);
                if (_key_up || _key_left)    menu_cursor = (menu_cursor - 1 + _party_count) % _party_count;
                if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _party_count;
                if (_key_back) {
                    menu_stage = BATTLE_MENU.ITEM_USE;
                    menu_cursor = obj_item_manager.selected_item; 
                }

                if (_key_conf) {
                    var _current_actor = party_members[party_input_index];
                    _current_actor.chosen_action_type = "item";
                    _current_actor.chosen_item_reference = pending_item;
                    _current_actor.chosen_item_inventory_idx = obj_item_manager.selected_item;
                    _current_actor.chosen_target_index = menu_cursor;
                    
                    pending_item = undefined;
                    party_input_index++;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                    if (party_input_index >= party_max_members) battle_sub_state = BATTLE_STATE.TURN_SORTING;
                }
                break;
        }
    }
    // ------------------------------------------
    // SUB-STATE 2: TURN SORTING & QUEUE BUILDING
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.TURN_SORTING) {
        turn_queue = [];
        var _living_party_count = 0;
        
        for (var _i = 0; _i < array_length(party_members); _i++) {
            var _member = party_members[_i];
            if (_member.hp > 0) {
                _living_party_count++;
                
                // Pack active choices directly from menu caching layer into action queue
                array_push(turn_queue, {
                    actor_type: "party",
                    actor_index: _i,
                    spd: _member.spd,
                    chosen_action_type: variable_instance_exists(_member, "chosen_action_type") ? _member.chosen_action_type : "fight",
                    chosen_target_index: variable_instance_exists(_member, "chosen_target_index") ? _member.chosen_target_index : 0,
                    chosen_sub_action: variable_instance_exists(_member, "chosen_sub_action") ? _member.chosen_sub_action : "",
                    chosen_item_reference: variable_instance_exists(_member, "chosen_item_reference") ? _member.chosen_item_reference : undefined,
                    chosen_item_inventory_idx: variable_instance_exists(_member, "chosen_item_inventory_idx") ? _member.chosen_item_inventory_idx : -1
                });
            }
        }
        
        if (_living_party_count == 0) {
            global.state = GAME_STATE.GAMEOVER;
            exit;
        }
        
        var _enemy_count = array_length(global.active_battle_enemies);
        for (var _i = 0; _i < _enemy_count; _i++) {
            var _enemy = global.active_battle_enemies[_i];
            if (instance_exists(_enemy) && _enemy.hp > 0) {
                
                var _target_party_idx = irandom(array_length(party_members) - 1);
                while (party_members[_target_party_idx].hp <= 0) {
                    _target_party_idx = irandom(array_length(party_members) - 1);
                }
                
                array_push(turn_queue, {
                    actor_type: "enemy",
                    actor_instance: _enemy,
                    actor_index: _i,
                    spd: _enemy.spd,
                    target_index: _target_party_idx
                });
            }
        }
        
        array_sort(turn_queue, function(_element1, _element2) {
            return _element2.spd - _element1.spd;
        });
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
        
        // --- PROCESS PARTY MEMBER TURN ---
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
                    
                    // --- ATTACK REDIRECTION ENGINE ---
                    // If the selected enemy died earlier this turn, look for a new living threat
                    if (!instance_exists(_target) || _target.hp <= 0) {
                        var _enemy_count = array_length(global.active_battle_enemies);
                        for (var _e = 0; _e < _enemy_count; _e++) {
                            var _potential_foe = global.active_battle_enemies[_e];
                            if (instance_exists(_potential_foe) && _potential_foe.hp > 0) {
                                _t_idx = _e;
                                _target = _potential_foe;
                                current_turn_act.chosen_target_index = _e; // Redirect the action
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
                    
                    // --- INTERACT REDIRECTION ENGINE ---
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
                        var _e_name = variable_instance_exists(_target, "name") ? _target.name : "Enemy";
                        battle_text = _actor.name + " used " + current_turn_act.chosen_sub_action + " on " + string(_e_name) + "!";
                        if (current_turn_act.chosen_sub_action == "Check") {
                            battle_text += " ATK: " + string(_target.atk) + " DEF: " + string(_target.def);
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
                    } else { 
                        battle_text = _actor.name + " focused power!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
                case "item":
                    var _target = party_members[current_turn_act.chosen_target_index];
                    var _item = current_turn_act.chosen_item_reference;
                    if (is_struct(_item)) {
                        if (_target.hp > 0 || _item.name == "Revive") { 
                            _item.effect(_target);
                            battle_text = _actor.name + " used " + _item.name + " on " + _target.name + "!";
                            if (instance_exists(obj_item_manager)) {
                                array_delete(obj_item_manager.inv, current_turn_act.chosen_item_inventory_idx, 1);
                            }
                        } else {
                            battle_text = _actor.name + " tried to use an item, but the target was down!";
                        }
                    } else {
                        battle_text = _actor.name + " fumbled with their inventory!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
            }
        }
	}
    // ------------------------------------------
    // SUB-STATE 4: ACTION RESOLUTION TIMING WINDOWS
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.ACTION_RESOLUTION) {
        if (action_timer > 0) {
            action_timer--;
            if (_key_conf && text_char_count >= string_length(battle_text)) {
                action_timer = 0;
            }
        } else {
            battle_text = "";
            current_turn_act = noone;
            battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
        }
    }
	// ------------------------------------------
    // SUB-STATE 5: VICTORY SCREEN HOLD WINDOW
    // ------------------------------------------
    else if (battle_sub_state == BATTLE_STATE.VICTORY) {
        
        if (!variable_instance_exists(id, "victory_timer")) {
            victory_timer = 0;
        }
        
        victory_timer++;
        
        var _text_is_finished = (text_char_count >= string_length(battle_text));
        
        if (_text_is_finished && _key_conf) {
            
            // --- GLOBAL PERSISTENCE WRITEBACK ---
            global.player_hp = party_members[0].hp;
            
            // ... (keep your ally stats synchronization loop here) ...

            // --- RE-ALIGN OVERWORLD FOLLOWERS BEFORE CHANGING ROOMS ---
            if (instance_exists(obj_player)) {
                // Clear the historical path buffer so they don't snap back in time
                if (ds_exists(obj_player.pos_history, ds_type_list)) {
                    ds_list_clear(obj_player.pos_history);
                }
                
                // Force any active followers to immediately snap onto the player's tile
                with (obj_follower) {
                    x = obj_player.x;
                    y = obj_player.y;
                }
            }
            
            // --- CARD CLEARING & ENGINE RESET ---
            victory_timer = 0; 
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            menu_stage = BATTLE_MENU.MAIN;
            menu_cursor = 0;
            party_input_index = 0;
            battle_text = "";
            text_char_count = 0;
            
            global.state = GAME_STATE.PLAYING;
            
            // Destructive scene management
            var _e_count = array_length(global.active_battle_enemies);
            for (var _e = 0; _e < _e_count; _e++) {
                var _enemy = global.active_battle_enemies[_e];
                if (instance_exists(_enemy)) {
                    instance_destroy(_enemy);
                }
            }
            
            // --- 2. RESTORE OVERWORLD GUI RATIO RIGHT BEFORE EXIT ---
            // If your overworld uses a different interface resolution (e.g., standard 1920x1080 or native window size)
            // Restore it here before changing rooms so the overworld HUD doesn't stay tiny.
            display_set_gui_size(499, 280); 
            
            if (variable_global_exists("overworld_room_fallback") && room_exists(global.overworld_room_fallback)) {
                room_goto(global.overworld_room_fallback);
            } else {
                room_goto_previous();
            }
            exit;
        }
    }
}
exit;