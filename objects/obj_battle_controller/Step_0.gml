/// @description Process Inputs & State Routines

// --- 1. SCREENSHAKE DECAY ---
if (screenshake_amount > 0) {
    screenshake_amount -= 0.5;
    if (screenshake_amount < 0) screenshake_amount = 0;
}

// --- 2. NATIVE INPUT ENGINE ---
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

    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT) {
        
        switch (menu_stage) {
            
            // --- MAIN BUTTON NAVIGATION ---
            case BATTLE_MENU.MAIN:
                var _max_actions = 4; 
                
                if (_key_left) {
                    menu_cursor = (menu_cursor - 1 + _max_actions) % _max_actions;
                }
                if (_key_right) {
                    menu_cursor = (menu_cursor + 1) % _max_actions;
                }
                
                if (_key_conf) {
                    switch (menu_cursor) {
                        case 0: menu_stage = BATTLE_MENU.TARGET_SELECT; break;
                        case 1: menu_stage = BATTLE_MENU.INTERACT;      break;
                        case 2: menu_stage = BATTLE_MENU.TAKE_ACTION;    break;
                        case 3: menu_stage = BATTLE_MENU.ITEM_USE;       break;
                    }
                    menu_cursor = 0; 
                }
                break;
                
            // --- ATTACK: TARGET SELECTOR ---
            case BATTLE_MENU.TARGET_SELECT:
                var _enemy_count = array_length(global.active_battle_enemies);
                if (_enemy_count > 0) {
                    if (_key_up || _key_left)   menu_cursor = (menu_cursor - 1 + _enemy_count) % _enemy_count;
                    if (_key_down || _key_right) menu_cursor = (menu_cursor + 1) % _enemy_count;
                    
                    if (_key_back) {
                        menu_stage = BATTLE_MENU.MAIN;
                        menu_cursor = 0; 
                    }
                    
                    if (_key_conf) {
                        var _target = global.active_battle_enemies[menu_cursor];
                        if (_target.hp > 0) {
                            var _damage = party_members[party_input_index].atk + global.battle_buff_atk; 
                            _target.hp -= _damage;
                            
                            battle_text = party_members[party_input_index].name + " attacked " + string(_target.name) + " for " + string(_damage) + " damage!";
                            text_char_count = 0;
                            
                            battle_sub_state = BATTLE_STATE.TURN_SORTING;
                            menu_stage = BATTLE_MENU.MAIN;
                            menu_cursor = 0;
                        }
                    }
                }
                break;
                
            // --- INTERACT SUB-MENU ---
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
                    var _chosen_act = interact_options[menu_cursor];
                    battle_text = party_members[party_input_index].name + " used " + _chosen_act + "!";
                    text_char_count = 0;
                    
                    battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                }
                break;
                
            // --- TAKE ACTION SUB-MENU ---
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
                    battle_text = party_members[party_input_index].name + " decided to " + _chosen_action + "!";
                    text_char_count = 0;
                    
                    battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                }
                break;
                
            // --- ITEM USE SUB-MENU ---
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
                var _max_visible = 4; // 2 rows x 2 columns max per view

                // Grid Navigation Controls
                if (_key_right) {
                    if (menu_cursor % _cols < _cols - 1 && menu_cursor + 1 < _item_count) {
                        menu_cursor += 1;
                    } else {
                        menu_cursor -= (menu_cursor % _cols); 
                    }
                }

                if (_key_left) {
                    if (menu_cursor % _cols > 0) {
                        menu_cursor -= 1;
                    } else {
                        var _target_right = menu_cursor + (_cols - 1);
                        menu_cursor = (_target_right < _item_count) ? _target_right : _item_count - 1;
                    }
                }

                if (_key_down) {
                    if (menu_cursor + _cols < _item_count) {
                        menu_cursor += _cols;
                    } else {
                        menu_cursor = menu_cursor % _cols; // Loop to top row
                    }
                }

                if (_key_up) {
                    if (menu_cursor - _cols >= 0) {
                        menu_cursor -= _cols;
                    } else {
                        var _last_row_index = menu_cursor;
                        while (_last_row_index + _cols < _item_count) {
                            _last_row_index += _cols;
                        }
                        menu_cursor = _last_row_index; // Loop to bottom row
                    }
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
			
            // --- ITEM TARGETING SYSTEM ---
            case BATTLE_MENU.ITEM_TARGET_SELECT:
                var _party_count = array_length(party_members);

                if (_key_up || _key_left)
                    menu_cursor = (menu_cursor - 1 + _party_count) mod _party_count;

                if (_key_down || _key_right)
                    menu_cursor = (menu_cursor + 1) mod _party_count;

                if (_key_back) {
                    menu_stage = BATTLE_MENU.ITEM_USE;
                    menu_cursor = obj_item_manager.selected_item; 
                }

                if (_key_conf) {
                    var _target = party_members[menu_cursor];

                    pending_item.effect(_target);

                    battle_text = party_members[party_input_index].name + " used " + pending_item.name + " on " + _target.name + "!";
                    text_char_count = 0;

                    pending_item = undefined;

                    battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    menu_stage = BATTLE_MENU.MAIN;
                    menu_cursor = 0;
                }
                break;
        }
    }
}