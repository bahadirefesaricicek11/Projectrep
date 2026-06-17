// --- NATIVE RETRO CANVAS DETECTOR ---
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Screenshake offset calculations
var _sx = random_range(-screenshake_amount, screenshake_amount);
var _sy = random_range(-screenshake_amount, screenshake_amount);

draw_set_font(battle_font);
draw_set_valign(fa_top);

// ==========================================
// STATE: CARD SELECTION LAYOUT SCREEN
// ==========================================
if (global.state == GAME_STATE.CARD_SELECTION) {
    if (sprite_exists(background)) {
        draw_sprite_stretched(background, 0, 0, 0, _gui_w, _gui_h);
    }
    
    var _card_count = array_length(global.selected_cards);
    if (_card_count > 0) {
        var _card_w = 60; var _card_h = 80; var _spacing = 10;
        var _total_w = (_card_count * _card_w) + ((_card_count - 1) * _spacing);
        var _start_x = (_gui_w - _total_w) / 2;
        var _start_y = (_gui_h - _card_h) / 2;

        for (var _i = 0; _i < _card_count; _i++) {
            var _card = global.selected_cards[_i];
            _card.x = _start_x + (_i * (_card_w + _spacing));
            _card.y = _start_y;
            
            var _is_hl = (card_cursor == _i);
            if (sprite_exists(box_sprite)) {
                draw_sprite_stretched_ext(box_sprite, 0, _card.x, _card.y, _card_w, _card_h, _is_hl ? c_yellow : c_white, 1.0);
            }
            
            draw_set_color(c_white);
            if (_card.is_revealed) {
                draw_text(_card.x + 4, _card.y + 6, _card.card_info.name);
                draw_text_ext(_card.x + 4, _card.y + 24, _card.card_info.desc, 9, _card_w - 8);
            } else {
                draw_set_halign(fa_center);
                draw_text(_card.x + (_card_w / 2), _card.y + (_card_h / 2) - 4, "REVEAL");
                draw_set_halign(fa_left);
            }
        }
    }
    exit;
}

// ==========================================
// STATE: THE TACTICAL ARENA LAYOUT (384x216 Grid)
// ==========================================
if (global.state == GAME_STATE.BATTLE) {
    
    // --- INSTANT VISUAL FAIL-SAFE ---
    // If the background asset isn't ready or hasn't loaded yet, this draws 
    // a dark purple background instantly so the screen never looks pitch black.
    if (sprite_exists(background)) {
        draw_sprite_stretched(background, 0, _sx, _sy, _gui_w, _gui_h);
    } else {
        draw_set_color(make_color_rgb(40, 30, 45)); 
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
    }

    // --- 1. HUD: TOP-CENTER CLOVER METER ---
    var _active_member = party_members[party_input_index];
    if (sprite_exists(spr_clover)) {
        draw_set_halign(fa_center); // Perfectly centers your Middle-Center sprite origin
        
        var _clover_x = 192 + _sx; // Exact midpoint of 384 width boundary
        var _clover_y = 35 + _sy;  
        var _img_frame = clamp(_active_member.clover_leaves, 0, 4);
        
        draw_sprite_ext(spr_clover, _img_frame, _clover_x, _clover_y, 1.0, 1.0, 0, c_white, 1.0);
    }

    var _row_start_y = 52;
    var _row_vert_spacing = 42;

    // --- 2. FIELD LAYER: PLAYER SPRITES + OVERHEAD HP BARS ---
    draw_set_halign(fa_left); 
    var _p_count = array_length(party_members);
    var _player_field_x = 42 + _sx; 

    for (var _p = 0; _p < _p_count; _p++) {
        var _m = party_members[_p];
        if (_m.hp > 0 && sprite_exists(_m.sprite)) {
            var _py = _row_start_y + (_p * _row_vert_spacing) + sin(anim_timer + _p + 2) * 1.5 + _sy;
            var _is_current_turn = (_p == party_input_index && battle_sub_state == BATTLE_STATE.PLAYER_INPUT);
            var _p_blend = _is_current_turn ? c_yellow : c_white;
            
            draw_sprite_ext(_m.sprite, floor(_m.img_idx), _player_field_x, _py, 1.0, 1.0, 0, _p_blend, 1.0);
            
            // Overhead HP Bar setup
            var _bar_w = 22;
            var _bar_h = 3;
            var _bar_x = _player_field_x - (_bar_w / 2);
            var _bar_y = _py - sprite_get_yoffset(_m.sprite) - 4; 
            
            draw_set_color(c_red);
            draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
            
            if (_m.max_hp > 0) {
                var _hp_percent = clamp(_m.display_hp / _m.max_hp, 0, 1);
                var _fill_w = _bar_w * _hp_percent;
                if (_fill_w > 0) {
                    draw_set_color(c_lime);
                    draw_rectangle(_bar_x, _bar_y, _bar_x + _fill_w, _bar_y + _bar_h, false);
                }
            }
        }
    }

    // --- 3. FIELD LAYER: ADJUSTED ENEMY FIELD POSITION ---
    var _enemy_count = array_length(global.active_battle_enemies);
    if (_enemy_count > 0) {
        var _enemy_field_x = _gui_w - 65 + _sx; 
        
        for (var _e = 0; _e < _enemy_count; _e++) {
            var _enemy_inst = global.active_battle_enemies[_e];
            if (instance_exists(_enemy_inst) && _enemy_inst.hp > 0) {
                var _ey = _row_start_y + (_e * _row_vert_spacing) + sin(anim_timer + _e) * 2 + _sy; 
                
                if (sprite_exists(_enemy_inst.sprite_index)) {
                    var _is_targeted = (menu_stage == 1 && menu_cursor == _e && battle_sub_state == BATTLE_STATE.PLAYER_INPUT);
                    var _blend = _is_targeted ? c_red : c_white;
                    
                    draw_sprite_ext(_enemy_inst.sprite_index, _enemy_inst.image_index, _enemy_field_x, _ey, 1.0, 1.0, 0, _blend, 1.0);
                }
            }
        }
    }

    // --- 4. DYNAMIC COMBAT CHRONICLE LOG WINDOW ---
    if (battle_text != "") {
        var _msg_w = _gui_w - 24;
        var _msg_h = 34;
        var _msg_x = 12 + _sx;
        var _msg_y = _gui_h - 96 + _sy; 
        
        if (sprite_exists(box_sprite)) {
            draw_sprite_stretched(box_sprite, 0, _msg_x, _msg_y, _msg_w, _msg_h);
        }
        
        var _visible_string = string_copy(battle_text, 1, floor(text_char_count));
        draw_set_color(c_white);
        draw_text_ext(_msg_x + 8, _msg_y + 6, _visible_string, 11, _msg_w - 16);
    }

    // --- 5. TARGET SELECTOR MENU OVERLAY ---
    if (menu_stage == 1 && battle_sub_state == BATTLE_STATE.PLAYER_INPUT) {
        var _box_w = 110;
        var _box_h = 52;
        var _box_x = (_gui_w - _box_w) / 2 + _sx;
        var _box_y = _gui_h - _box_h - 56 + _sy; 
        
        if (sprite_exists(box_sprite)) {
            draw_sprite_stretched(box_sprite, 0, _box_x, _box_y, _box_w, _box_h);
        }
        
        draw_set_color(c_aqua);
        draw_text(_box_x + 8, _box_y + 5, "TARGET:");
        
        var _enemy_count = array_length(global.active_battle_enemies);
        for (var _e = 0; _e < _enemy_count; _e++) {
            var _enemy_data = global.active_battle_enemies[_e];
            var _text_y = _box_y + 18 + (_e * 11);
            
            if (_enemy_data.hp <= 0) {
                draw_set_color(c_dkgray);
                draw_text(_box_x + 16, _text_y, "x " + string(_enemy_data.name));
            } else if (menu_cursor == _e) {
                draw_set_color(c_yellow);
                draw_text(_box_x + 8, _text_y, "> " + string(_enemy_data.name));
            } else {
                draw_set_color(c_white);
                draw_text(_box_x + 16, _text_y, "• " + string(_enemy_data.name));
            }
        }
    }

    // --- 6. ACTION SELECTION ENGINE (PERFECTLY ALIGNED TO ART SQUARES) ---
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && menu_stage == 0) {
        
        var _btn_sprites = [spr_fight_btn, spr_int_btn, spr_action_btn, spr_use_btn];
        var _btn_count = array_length(_btn_sprites);
        
        draw_set_halign(fa_center); // Links directly with the Middle-Center asset origins
        
        var _card_spacing = 53; 
        var _act_start_x = 112; 
        var _act_y = _gui_h - 24; 

        for (var _i = 0; _i < _btn_count; _i++) {
            var _ax = _act_start_x + (_i * _card_spacing) + _sx;
            var _ay = _act_y + _sy;
            var _is_selected = (menu_cursor == _i);
            
            var _current_sprite = _btn_sprites[_i];
            if (sprite_exists(_current_sprite)) {
                var _sub_image = _is_selected ? 1 : 0;
                var _blend_color = _is_selected ? c_yellow : c_white;
                
                draw_sprite_ext(_current_sprite, _sub_image, _ax, _ay, 1.0, 1.0, 0, _blend_color, 1.0);
            }
        }
        draw_set_halign(fa_left); // Safety clean reset
    }
}