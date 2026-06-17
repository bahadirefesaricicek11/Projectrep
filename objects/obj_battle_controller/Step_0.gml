// --- ABSOLUTE CRASH GUARD FOR BATTLE INITIALIZATION ---
// If players or enemies haven't finished spawning into the engine yet, 
// completely freeze the step processing until data initialization finishes.
if (array_length(party_members) <= 0 || array_length(global.active_battle_enemies) <= 0) {
    exit;
}
// ==========================================
// UPDATE UI EFFECTS & SPRITE ANIMATIONS EVERY FRAME
// ==========================================
anim_timer += 0.05;

for (var _p = 0; _p < array_length(party_members); _p++) {
    if (party_members[_p].hp > 0) {
        party_members[_p].img_idx += 0.15; 
    }
}

if (screenshake_amount > 0) {
    screenshake_amount -= 0.5; 
}

for (var _p = 0; _p < array_length(party_members); _p++) {
    var _m = party_members[_p];
    if (_m.display_hp > _m.hp) _m.display_hp -= 0.5;
    if (_m.display_hp < _m.hp) _m.display_hp += 0.5;
}

if (battle_text != "") {
    if (battle_text != last_battle_text) {
        text_char_count = 0; 
        last_battle_text = battle_text;
    }
    if (text_char_count < string_length(battle_text)) {
        text_char_count += 0.75; 
    }
}

// ==========================================
// STATE: CARD SELECTION (BEFORE COMBAT)
// ==========================================
if (global.state == GAME_STATE.CARD_SELECTION) {
    if (InputPressed(INPUT_VERB.LEFT))  card_cursor = max(0, card_cursor - 1);
    if (InputPressed(INPUT_VERB.RIGHT)) card_cursor = min(2, card_cursor + 1);
    
    if (InputPressed(INPUT_VERB.ACCEPT)) {
        var _selected_card = global.selected_cards[card_cursor];
        if (!_selected_card.is_revealed) {
            _selected_card.is_revealed = true;
        } else {
            battle_apply_card_buff(_selected_card.card_info);
        }
    }
    exit;
}

// ==========================================
// STATE: ACTIVE TURN COMBAT SYSTEM
// ==========================================
if (global.state == GAME_STATE.BATTLE) {
    
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT) {
        
        if (party_members[party_input_index].hp <= 0) {
            party_input_index++;
            if (party_input_index >= array_length(party_members)) {
                party_input_index = 0;
                battle_sub_state = BATTLE_STATE.TURN_SORTING;
            }
            exit;
        }
        
        if (menu_stage == 0) {
            if (InputPressed(INPUT_VERB.LEFT))  menu_cursor = max(0, menu_cursor - 1);
            if (InputPressed(INPUT_VERB.RIGHT)) menu_cursor = min(3, menu_cursor + 1);
            
            if (InputPressed(INPUT_VERB.ACCEPT)) {
                if (menu_cursor == 0) { 
                    menu_stage = 1; 
                    menu_cursor = 0; 
                }
                if (menu_cursor == 2) { 
                    var _defender = party_members[party_input_index];
                    var _def_action = {
                        owner: _defender,
                        is_player_side: true,
                        target: noone,
                        action_type: "DEFEND",
                        speed: _defender.spd * 2 
                    };
                    array_push(turn_queue, _def_action);
                    
                    menu_cursor = 0;
                    party_input_index++;
                    if (party_input_index >= array_length(party_members)) {
                        party_input_index = 0;
                        battle_sub_state = BATTLE_STATE.TURN_SORTING;
                    }
                }
            }
        }
        
        else if (menu_stage == 1) {
            var _max_enemy_index = array_length(global.active_battle_enemies) - 1;
            
            if (InputPressed(INPUT_VERB.UP))   menu_cursor = max(0, menu_cursor - 1);
            if (InputPressed(INPUT_VERB.DOWN)) menu_cursor = min(_max_enemy_index, menu_cursor + 1);
            
            if (InputPressed(INPUT_VERB.CANCEL)) {
                menu_stage = 0;
                menu_cursor = 0; 
            }
            
            if (InputPressed(INPUT_VERB.ACCEPT)) {
                var _attacker = party_members[party_input_index];
                
                var _player_action = {
                    owner: _attacker, 
                    is_player_side: true,
                    target: global.active_battle_enemies[menu_cursor],
                    action_type: "ATTACK",
                    speed: _attacker.spd + global.battle_buff_spd 
                };
                
                menu_stage = 0;
                menu_cursor = 0;
                array_push(turn_queue, _player_action);
                
                party_input_index++;
                if (party_input_index >= array_length(party_members)) {
                    party_input_index = 0;
                    battle_sub_state = BATTLE_STATE.TURN_SORTING;
                }
            }
        }
    }
    
    switch (battle_sub_state) {
        
        case BATTLE_STATE.TURN_SORTING:
            var _enemy_count = array_length(global.active_battle_enemies);
            for (var _i = 0; _i < _enemy_count; _i++) {
                var _enemy = global.active_battle_enemies[_i];
                if (_enemy.hp > 0) {
                    
                    var _valid_targets = [];
                    for (var _p = 0; _p < array_length(party_members); _p++) {
                        if (party_members[_p].hp > 0) array_push(_valid_targets, _p);
                    }
                    
                    var _target_idx = (array_length(_valid_targets) > 0) ? _valid_targets[irandom(array_length(_valid_targets) - 1)] : 0;
                    
                    var _enemy_action = {
                        owner: _enemy,
                        is_player_side: false,
                        target: _target_idx, 
                        action_type: "ATTACK",
                        speed: _enemy.spd
                    };
                    array_push(turn_queue, _enemy_action);
                }
            }
            
            var _size = array_length(turn_queue);
            for (var _i = 0; _i < _size; _i++) {
                for (var _j = 0; _j < _size - 1 - _i; _j++) {
                    if (turn_queue[_j].speed < turn_queue[_j + 1].speed) {
                        var _temp = turn_queue[_j];
                        turn_queue[_j] = turn_queue[_j + 1];
                        turn_queue[_j + 1] = _temp;
                    }
                }
            }
            
            battle_sub_state = BATTLE_STATE.ACTION_EXECUTE;
            action_timer = 0;
            current_turn_act = noone;
            break;
            
        case BATTLE_STATE.ACTION_EXECUTE:
            if (current_turn_act == noone) {
                if (array_length(turn_queue) > 0) {
                    current_turn_act = array_shift(turn_queue);
                    
                    var _owner_alive = current_turn_act.is_player_side ? (current_turn_act.owner.hp > 0) : (current_turn_act.owner.hp > 0);
                    if (!_owner_alive) {
                        current_turn_act = noone; 
                        exit;
                    }
                    
                    action_timer = 90; 
                    
                    if (current_turn_act.action_type == "DEFEND") {
                        battle_text = string(current_turn_act.owner.name) + " stands ready to defend!";
                    }
                    
                    else if (current_turn_act.action_type == "ATTACK") {
                        
                        if (!current_turn_act.is_player_side) {
                            var _target_member = party_members[current_turn_act.target];
                            
                            if (_target_member.hp > 0) {
                                var _damage = max(1, round(current_turn_act.owner.atk));
                                _target_member.hp = max(0, _target_member.hp - _damage);
                                screenshake_amount = 3;
                                
                                battle_text = string(current_turn_act.owner.name) + " slashes " + string(_target_member.name) + " for " + string(_damage) + " damage!";
                            } else {
                                current_turn_act = noone; 
                            }
                        } else {
                            var _target_enemy = current_turn_act.target;
                            var _actor = current_turn_act.owner;
                            
                            if (_target_enemy.hp > 0) {
                                var _is_crit = (_actor.clover_leaves >= 4);
                                var _crit_mult = _is_crit ? 2.0 : 1.0;
                                
                                var _buff_bonus = (_actor.name == "Player") ? global.battle_buff_atk : 0;
                                var _damage = max(1, round((_actor.atk + _buff_bonus) * _crit_mult));
                                _target_enemy.hp = max(0, _target_enemy.hp - _damage);
                                
                                screenshake_amount = _is_crit ? 8 : 3; 
                                
                                if (_is_crit) {
                                    battle_text = "SMASH HIT! ";
                                    _actor.clover_leaves = 0; 
                                } else {
                                    battle_text = "";
                                    _actor.clover_leaves += 1; 
                                }
                                
                                battle_text += string(_actor.name) + " strikes " + string(_target_enemy.name) + " for " + string(_damage) + " damage!";
                            } else {
                                current_turn_act = noone; 
                            }
                        }
                    }
                } else {
                    battle_sub_state = BATTLE_STATE.BATTLE_END;
                }
            } else {
                action_timer--;
                if (action_timer <= 0) {
                    current_turn_act = noone;
                }
            }
            break;
            
        case BATTLE_STATE.BATTLE_END:
            var _enemies_alive = false;
            for (var _e = 0; _e < array_length(global.active_battle_enemies); _e++) {
                if (global.active_battle_enemies[_e].hp > 0) _enemies_alive = true;
            }
            
            if (!_enemies_alive) {
                battle_cleanup_and_return();
                exit;
            }
            
            var _party_alive = false;
            for (var _p = 0; _p < array_length(party_members); _p++) {
                if (party_members[_p].hp > 0) _party_alive = true;
            }
            
            if (!_party_alive) {
                global.state = GAME_STATE.PLAYING; 
                room_goto(rm_gameover);           
                exit;
            }
            
            battle_sub_state = BATTLE_STATE.PLAYER_INPUT;
            party_input_index = 0;
            break;
    }
    exit;
}