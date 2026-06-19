/// @description Process Inputs, States & Popup Lifecycles

// --- 1. SCREENSHAKE DECAY ---
if (screenshake_amount > 0) {
    screenshake_amount -= 0.5;
    if (screenshake_amount < 0) screenshake_amount = 0;
}

// --- 2. TRANSIENT POPUP LIFECYCLE MANAGEMENT ---
// Reverse-looping prevents array indexing skips during real-time structural deletion
var _p_count = array_length(popup_numbers);
for (var _i = _p_count - 1; _i >= 0; _i--) {
    var _p = popup_numbers[_i];
    
    _p.life--;
    _p.yy -= 0.5; // Upward float velocity vector
    
    if (_p.life <= 0) {
        array_delete(popup_numbers, _i, 1);
    }
}

// --- 3. NATIVE INPUT ENGINE ---
var _key_left  = InputPressed(INPUT_VERB.LEFT);
var _key_right = InputPressed(INPUT_VERB.RIGHT);
var _key_up    = InputPressed(INPUT_VERB.UP);
var _key_down  = InputPressed(INPUT_VERB.DOWN);
var _key_conf  = InputPressed(INPUT_VERB.ACCEPT); 
var _key_back  = InputPressed(INPUT_VERB.CANCEL);

// ==========================================
// STATE LOGIC: CARD SELECTION
// ==========================================
if (global.state == GAME_STATE.CARD_SELECTION) {
    var _card_count = array_length(global.selected_cards);
    
    if (_card_count > 0) {
        // Animate the cards sliding up into view from the bottom when the screen opens
        if (card_intro_timer < 1.0) {
            card_intro_timer += 0.03; 
        }
        
        // PHASE 1: CHOOSE A BLIND CARD
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
                    
                    // Capture layout origins exactly as they sit onscreen right now
                    var _card_w = 76; 
                    var _spacing = 12;
                    var _total_w = (_card_count * _card_w) + ((_card_count - 1) * _spacing);
                    var _start_x = (display_get_gui_width() - _total_w) / 2;
                    
                    chosen_card_start_x = _start_x + (card_cursor * (_card_w + _spacing));
                    chosen_card_start_y = (display_get_gui_height() - 120) / 2;
                    
                    // Force reveal ALL underlying structural data instantly
                    for (var _i = 0; _i < _card_count; _i++) {
                        global.selected_cards[_i].is_revealed = true;
                    }
                    
                    // Start the auto-dismissal timer (60 frames = 1 second preview)
                    card_reveal_timer = 60;
                    exit;
                }
            }
        }
        // PHASE 2: AUTOMATIC REVEAL ANIMATION LOOP (No inputs accepted)
        else if (!in_card_transition) {
            // Smoothly animate the card flip angle down to 0 degrees
            card_flip_angle = lerp(card_flip_angle, 0, 0.15);
            
            // Countdown the display timer
            if (card_reveal_timer > 0) {
                card_reveal_timer--;
            } else {
                // Hand off to the flight path interpolation system
                in_card_transition = true;
                transition_timer = 0;
            }
        }
    }
    
    // --- TRANSITION FLIGHT PATH MATH ---
    if (in_card_transition) {
        if (transition_timer < transition_duration) {
            transition_timer++;
        } else {
            // Hand off sequence over! Clean up and drop safely into combat state
            in_card_transition = false;
            card_choice_locked = false;
            card_intro_timer = 0;
            card_flip_angle = 180;
            card_reveal_timer = -1;
            
            battle_apply_card_buff(global.chosen_battle_card.card_info);
            
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
    
    if (battle_text != "") {
        if (text_char_count < string_length(battle_text)) {
            text_char_count += 0.5;
        }
    }

    // ------------------------------------------
    // SUB-STATE: PLAYER INPUT LATCHING
    // ------------------------------------------
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT) {
        
        // --- CRITICAL BOUNDARY PROTECTION: CHIEF ENGINE SHIELD ---
        if (party_input_index >= party_max_members) {
            battle_sub_state = BATTLE_STATE.TURN_SORTING;
            exit;
        }
        
        // Safety lock: if current character is dead, instantly skip ahead
        if (party_members[party_input_index].hp <= 0) {
            party_input_index++;
            if (party_input_index >= party_max_members) {
                battle_sub_state = BATTLE_STATE.TURN_SORTING;
            }
            exit;
        }
        
        // Handle the real-time Hit Bar sequence if engaged
        if (menu_stage == BATTLE_MENU.HIT_BAR) {
            hit_bar_progress -= hit_bar_speed;
            
            if (hit_bar_progress <= 0) {
                hit_bar_multiplier = 0;
                hit_bar_verdict = "MISS";
                event_user(0); // Trigger Damage Resolution Script
            }
            
            if (_key_conf) {
                var _distance = abs(hit_bar_progress - hit_bar_target);
                
                if (_distance <= 0.04) {
                    hit_bar_multiplier = 2.0;
                    hit_bar_verdict = "PERFECT!";
                } else if (_distance <= 0.12) {
                    hit_bar_multiplier = 1.2;
                    hit_bar_verdict = "GOOD";
                } else {
                    hit_bar_multiplier = 0.6;
                    hit_bar_verdict = "WEAK";
                }
                event_user(0); // Trigger Damage Resolution Script
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
                            
                            // Initialize action types safely right on selection declaration
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
                }
                break;
                
            case BATTLE_MENU.TARGET_SELECT:
                var _enemy_count = array_length(global.active_battle_enemies);
                if (_enemy_count > 0) {
                    if (_key_up || _key_left)   menu_cursor = (menu_cursor - 1 + _enemy_count) % _enemy_count;
                    if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _enemy_count;
                    
                    if (_key_back) {
                        menu_stage = (menu_context == "interact") ? BATTLE_MENU.INTERACT : BATTLE_MENU.MAIN;
                        menu_cursor = 0; 
                    }
                    
                    if (_key_conf) {
                        targeted_enemy_index = menu_cursor;
                        var _target = global.active_battle_enemies[targeted_enemy_index];
                        
                        if (instance_exists(_target) && _target.hp > 0) {
                            var _current_actor = party_members[party_input_index];
                            
                            if (menu_context == "fight") {
                                // Lock structural intent targets down onto character
                                _current_actor.chosen_target_index = targeted_enemy_index;
                                
                                // Advance our character turn select array counter
                                party_input_index++;
                                
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
                                
                                if (party_input_index >= party_max_members) {
                                    battle_sub_state = BATTLE_STATE.TURN_SORTING;
                                }
                            }
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
                    menu_cursor = 1; 
                }
                
                if (_key_conf && _count > 0) {
                    selected_sub_action = interact_options[menu_cursor];
                    menu_stage = BATTLE_MENU.TARGET_SELECT;
                    menu_context = "interact";
                    menu_cursor = 0;
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
                    menu_cursor = 2; 
                }
                
                if (_key_conf && _count > 0) {
                    var _chosen_action = take_action_options[menu_cursor];
                    var _current_actor = party_members[party_input_index];
                    
                    _current_actor.chosen_action_type = "take_action";
                    _current_actor.chosen_sub_action  = _chosen_action;
                    _current_actor.chosen_target_index = -1;
                    
                    if (_chosen_action == "Defend") {
                        _current_actor.is_defending = true; 
                    }
                    
                    party_input_index++;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                    
                    if (party_input_index >= party_max_members) {
                        battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    }
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
                if (_key_right) { if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _item_count) menu_cursor += 1; else menu_cursor -= (menu_cursor % _cols); }
                if (_key_left)  { if (menu_cursor % _cols > 0) menu_cursor -= 1; else { var _tr = menu_cursor + (_cols - 1); menu_cursor = (_tr < _item_count) ? _tr : _item_count - 1; } }
                if (_key_down)  { if (menu_cursor + _cols < _item_count) menu_cursor += _cols; else menu_cursor = menu_cursor % _cols; }
                if (_key_up)    { if (menu_cursor - _cols >= 0) menu_cursor -= _cols; else { var _lr = menu_cursor; while (_lr + _cols < _item_count) { _lr += _cols; } menu_cursor = _lr; } }

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
                    
                    if (party_input_index >= party_max_members) {
                        battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    }
                }
                break;
        }
    }

    // ------------------------------------------
    // SUB-STATE: TURN SORTING & QUEUE BUILDING
    // ------------------------------------------
    if (battle_sub_state == BATTLE_STATE.TURN_SORTING) {
        turn_queue = [];
        
        // 1. Gather all living party actions
        var _party_count = array_length(party_members);
        for (var _i = 0; _i < _party_count; _i++) {
            var _member = party_members[_i];
            if (_member.hp > 0) {
                array_push(turn_queue, {
                    actor_type: "party",
                    actor_index: _i,
                    spd: _member.spd
                });
            }
        }
        
        // 2. Gather all living enemy actions & build automatic target sets
        var _enemy_count = array_length(global.active_battle_enemies);
        for (var _i = 0; _i < _enemy_count; _i++) {
            var _enemy = global.active_battle_enemies[_i];
            if (instance_exists(_enemy) && _enemy.hp > 0) {
                
                var _target_party_idx = irandom(array_length(party_members) - 1);
                while (party_members[_target_party_idx].hp <= 0) {
                    _target_party_idx = irandom(array_length(party_members) - 1);
                    if (party_members[0].hp <= 0 && party_members[1].hp <= 0 && party_members[2].hp <= 0) break;
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
        
        // 3. Dynamic speed-sorting algorithm
        array_sort(turn_queue, function(_element1, _element2) {
            return _element2.spd - _element1.spd;
        });
        
        battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
        exit;
    }

    // ------------------------------------------
    // SUB-STATE: EXECUTING INDIVIDUAL QUEUE ENTRIES
    // ------------------------------------------
    if (battle_sub_state == BATTLE_STATE.TURN_PROCESSING) {
        if (array_length(turn_queue) == 0) {
            // Round finished! Strip defense shields across the team
            for (var _i = 0; _i < array_length(party_members); _i++) {
                party_members[_i].is_defending = false;
            }
            
            party_input_index = 0;
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            menu_stage = BATTLE_MENU.MAIN;
            menu_cursor = 0;
            exit;
        }
        
        current_turn_act = array_shift(turn_queue);
        action_timer = 90; 
        text_char_count = 0;
        
        // --- PROCESS PARTY MEMBER TURN ---
        if (current_turn_act.actor_type == "party") {
            var _actor = party_members[current_turn_act.actor_index];
            
            // Mid-turn safety: check if player died before getting to act this round
            if (_actor.hp <= 0) {
                battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
                exit;
            }
            
            switch (_actor.chosen_action_type) {
                case "fight":
                    // Text details generated directly via event_user 0 inside hit_bar resolve hooks
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
                case "interact":
                    var _target = global.active_battle_enemies[_actor.chosen_target_index];
                    if (instance_exists(_target) && _target.hp > 0) {
                        battle_text = _actor.name + " used " + _actor.chosen_sub_action + " on " + string(_target.name) + "!";
                        if (_actor.chosen_sub_action == "Check") {
                            battle_text += " ATK: " + string(_target.atk) + " DEF: " + string(_target.def);
                        }
                    } else {
                        battle_text = _actor.name + " tried to look for an enemy, but it was already gone!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
                case "take_action":
                    if (_actor.chosen_sub_action == "Defend") {
                        battle_text = _actor.name + " is guarding safely!";
                    } else if (_actor.chosen_sub_action == "Flee") {
                        battle_text = "Escaping from battle layout...";
                    } else {
                        battle_text = _actor.name + " focused power!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
                    
                case "item":
                    var _target = party_members[_actor.chosen_target_index];
                    var _item = _actor.chosen_item_reference;
                    
                    if (_target.hp > 0 || _item.name == "Revive") { 
                        _item.effect(_target);
                        battle_text = _actor.name + " used " + _item.name + " on " + _target.name + "!";
                    } else {
                        battle_text = _actor.name + " tried to use an item, but the target was down!";
                    }
                    battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
                    break;
            }
        } 
        // --- PROCESS ENEMY AUTOMATIC TURN ---
        else if (current_turn_act.actor_type == "enemy") {
            var _enemy = current_turn_act.actor_instance;
            
            // Mid-turn safety: check if enemy died before getting to act this round
            if (!instance_exists(_enemy) || _enemy.hp <= 0) {
                battle_sub_state = BATTLE_STATE.TURN_PROCESSING;
                exit;
            }
            
            var _target = party_members[current_turn_act.target_index];
            battle_text = string(_enemy.name) + " strikes " + string(_target.name) + "!";
            
            var _damage = max(1, _enemy.atk - _target.def);
            if (_target.is_defending) _damage = ceil(_damage * 0.5);
            
            _target.hp = max(0, _target.hp - _damage);
            
          
            // Push damage tracking parameters out, assigning max_life and color safely
            array_push(popup_numbers, {
                xx: 100, // Replace with your target drawing positions later
                yy: 150, 
                text: string(_damage),
                life: 45,
                max_life: 45,
                color: c_red // Added to resolve Draw GUI coloration crash
            });
            
            screenshake_amount = 3; 
            battle_sub_state = BATTLE_STATE.ACTION_RESOLUTION;
        }
        exit;
    }

    // ------------------------------------------
    // SUB-STATE: ACTION RESOLUTION TIMING WINDOWS
    // ------------------------------------------
    if (battle_sub_state == BATTLE_STATE.ACTION_RESOLUTION) {
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
        exit;
    }
}