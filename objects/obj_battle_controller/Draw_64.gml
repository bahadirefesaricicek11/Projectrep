/// @description Complete Battle Interface Render Engine

// --- 1. GLOBAL DRAW INITIALIZATION & VECTOR SETUP ---
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Reset text parameters to baseline before any rendering passes
draw_set_font(battle_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Apply screen shake vectors dynamically at the start so ALL layers can use them
var _sx = random_range(-screenshake_amount, screenshake_amount);
var _sy = random_range(-screenshake_amount, screenshake_amount);


// ========================================== 
// STATE: GAME OVER LAYOUT SCREEN
// ========================================== 
if (global.state == GAME_STATE.GAMEOVER) {
    if (sprite_exists(spr_box)) {
        draw_sprite_stretched(spr_box, 0, 0, 0, _gui_w, _gui_h);
    } else {
        draw_set_color(c_black);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    draw_text_transformed_color(_gui_w / 2 + _sx, _gui_h / 2 - 20 + _sy, "DEFEAT", 1.5, 1.5, 0, c_red, c_red, c_maroon, c_maroon, 1.0);
    draw_text_transformed_color(_gui_w / 2, _gui_h / 2 + 20, "PRESS CONFIRM KEY TO RETRY", 0.5, 0.5, 0, c_gray, c_gray, c_white, c_white, 1.0);
    draw_set_valign(fa_top);
    exit;
}

// ========================================== 
// STATE: CARD SELECTION LAYOUT SCREEN 
// ========================================== 
if (global.state == GAME_STATE.CARD_SELECTION) {
    if (sprite_exists(background)) {
        draw_sprite_stretched(background, 0, 0, 0, _gui_w, _gui_h);
    } else {
        draw_set_color(make_color_rgb(40, 30, 45)); 
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
    } 
     
    var _card_count = array_length(global.selected_cards);
    if (_card_count > 0) {
        var _card_w = 76;
        var _card_h = 120; 
        var _spacing = 12;
         
        var _total_w = (_card_count * _card_w) + ((_card_count - 1) * _spacing);
        var _start_x = (_gui_w - _total_w) / 2;
        
        var _bounce_t = card_intro_timer - 1;
        var _intro_ease = (_bounce_t * _bounce_t * ((2.70158 + 1) * _bounce_t + 2.70158) + 1);
        var _target_y = (_gui_h - _card_h) / 2;
        var _start_y = _gui_h + 40;
        var _current_y = lerp(_start_y, _target_y, _intro_ease);
        var _any_card_picked = (variable_instance_exists(id, "card_choice_locked") && card_choice_locked && variable_global_exists("chosen_battle_card") && global.chosen_battle_card != noone);
        var _t_raw = clamp(transition_timer / transition_duration, 0, 1);
        var _t_progress = (_t_raw < 0.5) ? 4 * _t_raw * _t_raw * _t_raw : 1 - power(-2 * _t_raw + 2, 3) / 2;
        
        for (var _i = 0; _i < _card_count; _i++) {
            var _card = global.selected_cards[_i];
            if (!is_struct(_card) && !instance_exists(_card)) continue;
            
            var _is_the_chosen_one = (_any_card_picked && global.chosen_battle_card == _card);
            var _draw_x = _start_x + (_i * (_card_w + _spacing));
            var _draw_y = _current_y;
            var _scale_multiplier = 1.0;
            var _layer_alpha = 1.0;
            var _rot_angle = 0;
            
            if (in_card_transition) {
                if (_is_the_chosen_one) {
                    _draw_x = lerp(chosen_card_start_x, 192 - (_card_w / 2), _t_progress);
                    _draw_y = lerp(chosen_card_start_y, 20 - (_card_h / 2), _t_progress);
                    _scale_multiplier = lerp(1.0, 0.0, power(_t_raw, 2));
                    _layer_alpha = lerp(1.0, 0.0, power(_t_raw, 4));
                    _rot_angle = chosen_card_angle;
                } else {
                    var _drop_ease = power(_t_raw, 3);
                    _draw_y = _current_y + (_drop_ease * (_gui_h - _current_y + 100));
                    _layer_alpha = lerp(1.0, 0.0, clamp(_t_raw * 2, 0, 1));
                }
            }

            var _is_cursor_highlight = (card_cursor == _i);
            var _box_color = c_white;
            if (_any_card_picked) {
                _box_color = _is_the_chosen_one ? c_white : c_dkgray;
            } else {
                _box_color = _is_cursor_highlight ? c_ltgray : c_white;
            }

            var _current_flip = _any_card_picked ? card_flip_angle : 180;
            var _x_scale = cos(degtorad(_current_flip)) * _scale_multiplier;
            
            var _center_x = _draw_x + (_card_w / 2);
            var _center_y = _draw_y + (_card_h / 2);
            var _is_showing_front = (variable_struct_exists(_card, "is_revealed") && _card.is_revealed && _current_flip < 90);
            var _base_sprite = _is_showing_front ? spr_card_front : spr_card_back;
            var _frame_index = 0;
            
            if (_any_card_picked) {
                _frame_index = _is_the_chosen_one ? 1 : 0;
            } else {
                _frame_index = (_is_cursor_highlight && !_is_showing_front) ? 1 : 0;
            }
            
            if (sprite_exists(_base_sprite)) {
                draw_sprite_ext(_base_sprite, _frame_index, _center_x, _center_y, _x_scale, _scale_multiplier, _rot_angle, _box_color, _layer_alpha);
            } else {
                if (sprite_exists(spr_box)) {
                    draw_sprite_ext(spr_box, _frame_index, _center_x, _center_y, _x_scale * (_card_w / sprite_get_width(spr_box)), _scale_multiplier * (_card_h / sprite_get_height(spr_box)), _rot_angle, _box_color, _layer_alpha);
                } else {
                    draw_set_color(_box_color);
                    draw_set_alpha(_layer_alpha);
                    draw_rectangle(_center_x - (_card_w / 2) * _x_scale, _draw_y, _center_x + (_card_w / 2) * _x_scale, _draw_y + (_card_h * _scale_multiplier), true);
                    draw_set_alpha(1.0);
                } 
            }
             
            if (_is_showing_front && variable_struct_exists(_card, "card_info")) {
                var _render_alpha = ((_any_card_picked && !_is_the_chosen_one) ? 0.45 : 1.0) * _layer_alpha;
                draw_set_alpha(_render_alpha);
                
                draw_set_color(_is_the_chosen_one ? c_black : (_is_cursor_highlight && !_any_card_picked ? c_yellow : c_white));
                draw_set_halign(fa_center);
                 
                var _title_string = variable_struct_exists(_card.card_info, "name") ? string(_card.card_info.name) : "";
                var _title_scale = 0.45 * _x_scale;   
                var _title_sep = 9;
                var _max_title_w = (_card_w - 10) / max(abs(_title_scale), 0.001);
                 
                draw_text_ext_transformed_color(_center_x, _center_y - (50 * _scale_multiplier), _title_string, _title_sep, _max_title_w, _title_scale, 0.45 * _scale_multiplier, _rot_angle, draw_get_color(), draw_get_color(), draw_get_color(), draw_get_color(), _render_alpha);
                var _icon_offset_y = -15 * _scale_multiplier;
                var _has_root_sprite = variable_struct_exists(_card, "icon_sprite");
                var _has_nest_sprite = variable_struct_exists(_card.card_info, "icon_sprite");
                if (_has_root_sprite || _has_nest_sprite) {
                    var _sprite = _has_root_sprite ? _card.icon_sprite : _card.card_info.icon_sprite;
                    var _frame  = variable_struct_exists(_card, "icon_frame") ? _card.icon_frame : (variable_struct_exists(_card.card_info, "icon_frame") ? _card.card_info.icon_frame : 0);
                    if (sprite_exists(_sprite)) {
                        draw_sprite_ext(_sprite, _frame, _center_x, _center_y + _icon_offset_y, _x_scale, 1.0 * _scale_multiplier, _rot_angle, c_white, _render_alpha);
                    } 
                } 
                 
                draw_set_color(_any_card_picked && !_is_the_chosen_one ? c_gray : c_black);
                draw_set_halign(fa_center);
                 
                var _desc_string = variable_struct_exists(_card.card_info, "desc") ? string(_card.card_info.desc) : "";
                var _desc_scale = 0.50 * _x_scale;    
                var _desc_sep = 20;
                var _max_desc_w = (_card_w - 12) / max(abs(_desc_scale), 0.001);
                 
                draw_text_ext_transformed_color(_center_x, _center_y + (10 * _scale_multiplier), _desc_string, _desc_sep, _max_desc_w, _desc_scale, 0.50 * _scale_multiplier, _rot_angle, draw_get_color(), draw_get_color(), draw_get_color(), draw_get_color(), _render_alpha);
                draw_set_alpha(1.0);
            } 
        } 
    } 
    exit;
}

// ========================================== 
// STATE: THE TACTICAL ARENA LAYOUT 
// ========================================== 
if (global.state == GAME_STATE.BATTLE) {
    if (sprite_exists(background)) {
        draw_sprite_stretched(background, 0, _sx, _sy, _gui_w, _gui_h);
    } else {
        draw_set_color(make_color_rgb(40, 30, 45)); 
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
    } 

    var _row_start_y = 52;
    var _row_vert_spacing = 50;
    
    // --- 2. HUD: VERTICAL HEALTH BOX SYSTEM (STACKED TO THE LEFT OF ALLIES) ---
    draw_set_font(Small_Font);
    var _native_w = 74;
    var _native_h = 84;
    var _scale = 0.75;
    
    var _box_w = _native_w * _scale;
    var _box_h = _native_h * _scale;

    for (var _i = 0; _i < party_max_members; _i++) {
        var _member = party_members[_i];
        if (!is_struct(_member) && !instance_exists(_member)) continue;
        
        var _current_box_x = 5 + _sx;
        var _current_box_y = (_i * _row_vert_spacing) + 30 + _sy;
        
        if (sprite_exists(spr_hp_box)) {
            draw_sprite_ext(spr_hp_box, 0, _current_box_x, _current_box_y, _scale, _scale, 0, c_white, 1.0);
        }
        
        draw_set_halign(fa_left);
        var _name_color = (_member.hp <= 0) ? c_red : c_white;
        var _text_local_x = _current_box_x + (8 * _scale) + 1;
        var _text_local_y = _current_box_y + (10 * _scale);
        
        draw_text_transformed_color(_text_local_x, _text_local_y, string_upper(_member.name), 0.5, 0.5, 0, _name_color, _name_color, _name_color, _name_color, 1);
        
        var _hp_val = max(0, _member.display_hp);
        var _whole_hp = floor(_hp_val);
        var _global_fraction = _hp_val - _whole_hp;
        if (_global_fraction < 0.05 || _global_fraction > 0.95) {
            _global_fraction = 0;
        }
        
        var _hund_digit = floor(_whole_hp / 100) % 10;
        var _tens_digit = floor(_whole_hp / 10) % 10;
        var _ones_digit = _whole_hp % 10;
        
        var _hund_frame = _hund_digit * 4;
        var _tens_frame = _tens_digit * 4;
        var _ones_frame = _ones_digit * 4;
        if (_global_fraction > 0) {
            var _sub_offset = floor(_global_fraction * 4);
            _ones_frame += _sub_offset;
            
            if (_ones_digit == 0) {
                _tens_frame += _sub_offset;
                if (_tens_digit == 0) {
                    _hund_frame += _sub_offset;
                }
            }
        }

        if (sprite_exists(spr_roller)) {
            var _native_local_x = 25;
            var _native_local_y = 25; 
            var _native_digit_w = 7; 
            var _pixel_margin   = 1;
            var _roller_start_x  = _current_box_x + (_native_local_x * _scale);
            var _roller_draw_y   = _current_box_y + (_native_local_y * _scale);
            var _digit_stride    = (_native_digit_w + _pixel_margin) * _scale;
            
            draw_sprite_ext(spr_roller, _hund_frame, _roller_start_x, _roller_draw_y, _scale, _scale, 0, c_white, 1.0);
            draw_sprite_ext(spr_roller, _tens_frame, _roller_start_x + _digit_stride, _roller_draw_y, _scale, _scale, 0, c_white, 1.0);
            draw_sprite_ext(spr_roller, _ones_frame, _roller_start_x + (_digit_stride * 2), _roller_draw_y, _scale, _scale, 0, c_white, 1.0);
        }
        
        if (_i < array_length(global.active_combat_buffs)) {
            var _card_data = global.active_combat_buffs[_i];
            if (_card_data != noone && variable_struct_exists(_card_data, "icon_sprite")) {
                if (sprite_exists(_card_data.icon_sprite)) {
                    var _icon_local_x = 36;
                    var _icon_local_y = 47; 
                    var _icon_draw_x = _current_box_x + (_icon_local_x * _scale);
                    var _icon_draw_y = _current_box_y + (_icon_local_y * _scale);
                    var _target_frame = variable_struct_exists(_card_data, "icon_frame") ? _card_data.icon_frame : 0;
                    
                    draw_sprite_ext(_card_data.icon_sprite, _target_frame, _icon_draw_x, _icon_draw_y, _scale, _scale, 0, c_white, 1.0);
                }
            }
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_font(battle_font);

    // --- 3. FIELD LAYER: PLAYER & ALLY SPRITES --- 
    var _p_count = array_length(party_members);

    for (var _p = 0; _p < _p_count; _p++) {
        var _m = party_members[_p];
        if (!is_struct(_m) && !instance_exists(_m)) continue;
        if (_m.hp > 0) {
            
            var _base_x = 82;
            var _base_y = _row_start_y + (_p * _row_vert_spacing) - 12;
            
            if (variable_instance_exists(id, "party_battle_positions") && _p < array_length(party_battle_positions)) {
                _base_x = party_battle_positions[_p].x;
                _base_y = party_battle_positions[_p].y;
            }
             
            var _is_active_input = (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && party_input_index == _p && menu_stage != BATTLE_MENU.HIT_BAR && battle_text == "");
            var _input_bounce_x = _is_active_input ? round(sin(current_time * 0.015) * 2) + 3 : 0;
            
            var _final_draw_x   = _base_x + _input_bounce_x + _sx;
            var _final_draw_y   = _base_y + _sy;

            if (sprite_exists(_m.sprite)) {
                var _blend_color = _is_active_input ? c_white : c_silver;
                draw_sprite_ext(_m.sprite, floor(_m.img_idx), _final_draw_x, _final_draw_y, 1.0, 1.0, 0, _blend_color, 1.0);
                
                if (_m.name == "Player" && variable_struct_exists(_m, "buffs") && is_array(_m.buffs)) {
                    for (var _b = 0; _b < array_length(_m.buffs); _b++) {
                        var _buff_item = _m.buffs[_b];
                        if (is_struct(_buff_item) && variable_struct_exists(_buff_item, "sprite") && sprite_exists(_buff_item.sprite)) {
                            draw_sprite(_buff_item.sprite, 0, _final_draw_x - 16 + (_b * 12), _final_draw_y - 12);
                        }
                    }
                }
            } 
        } 
    } 

    // ==========================================
    // HUD & SPRITE: ENEMY MASTER RENDER LAYOUT
    // ==========================================
    var _e_count = array_length(global.active_battle_enemies);
    for (var _j = 0; _j < _e_count; _j++) {
        var _enemy_inst = global.active_battle_enemies[_j];
        if (!instance_exists(_enemy_inst) || _enemy_inst.hp <= 0) continue;
    
        var _gui_x = _enemy_inst.x - camera_get_view_x(view_camera[0]);
        var _gui_y = _enemy_inst.y - camera_get_view_y(view_camera[0]);
    
        var _enemy_sprite = variable_instance_exists(_enemy_inst, "sprite_index") ? _enemy_inst.sprite_index : noone;
        var _enemy_frame  = variable_instance_exists(_enemy_inst, "image_index")  ? _enemy_inst.image_index  : 0;
        
        var _blend_color = c_white;
        if (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_cursor == _j) {
            _blend_color = (current_time % 200 < 100) ? c_yellow : c_white;
        }
        
        if (sprite_exists(_enemy_sprite)) {
            draw_sprite_ext(_enemy_sprite, _enemy_frame, _gui_x + _sx + 30, _gui_y + _sy, 1.0, 1.0, 0, _blend_color, 1.0);
        } else {
            draw_set_color(c_purple);
            draw_rectangle(_gui_x - 16 + _sx, _gui_y - 16 + _sy, _gui_x + 16 + _sx, _gui_y + 16 + _sy, false);
        }

        var _sprite_top_offset = 0;
        if (sprite_exists(_enemy_sprite)) {
            _sprite_top_offset = sprite_get_height(_enemy_sprite) - sprite_get_yoffset(_enemy_sprite);
        } else {
            _sprite_top_offset = 16;
        }

        var _box_x = _gui_x + _sx + 30;
        var _box_y = (_gui_y - _sprite_top_offset - 5) + _sy;
        var _bar_w = 40;
        var _bar_h = 4;
    
        draw_set_font(Small_Font);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text_transformed(_box_x, _box_y - 12, string_upper(_enemy_inst.name), 0.35, 0.35, 0);
    
        draw_set_color(c_dkgray);
        draw_rectangle(_box_x - (_bar_w / 2), _box_y, _box_x + (_bar_w / 2), _box_y + _bar_h, false);
        
        var _hp_percent = 0;
        if (_enemy_inst.max_hp > 0) {
            var _current_display_hp = variable_instance_exists(_enemy_inst, "display_hp") ? _enemy_inst.display_hp : _enemy_inst.hp;
            _hp_percent = clamp(_current_display_hp / _enemy_inst.max_hp, 0, 1);
        }
    
        if (_hp_percent > 0) {
            var _fill_end_x = (_box_x - (_bar_w / 2)) + (_bar_w * _hp_percent);
            var _bar_color = (_hp_percent <= 0.25) ? c_orange : c_red;
        
            draw_set_color(_bar_color);
            draw_rectangle(_box_x - (_bar_w / 2), _box_y, _fill_end_x, _box_y + _bar_h, false);
        }
    
        draw_set_color(c_black);
        draw_rectangle(_box_x - (_bar_w / 2) - 1, _box_y - 1, _box_x + (_bar_w / 2) + 1, _box_y + _bar_h + 1, true);
    }
	
    draw_set_font(battle_font);
	
    // --- 5. THE LOWER CHRONICLE (TEXT CONTROLLER) --- 
    var _dash_w = _gui_w - 160;
    var _dash_h = 64; 
    var _dash_x = 80 + _sx; 
    var _dash_y = _gui_h - 128 + _sy;
    
    if (battle_text != "") { 
        if (sprite_exists(spr_box)) {
            draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
        } else {
            draw_set_color(c_black);
            draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, false);
            draw_set_color(c_white);
            draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, true);
        }

        draw_set_color(c_white); 
        draw_set_halign(fa_left); 
        draw_set_valign(fa_top); 
         
        var _text_scale = 0.50;  
        var _line_sep = 14;
        var _max_text_w = (_dash_w - 20) / _text_scale; 
         
        draw_text_ext_transformed(_dash_x + 10, _dash_y + 8, string_copy(battle_text, 1, floor(text_char_count)), _line_sep, _max_text_w, _text_scale, _text_scale, 0);
    } 

    // --- 6. CAROUSEL MAIN BUTTON SYSTEMS --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && battle_text == "") { 
        var _btn_sprites = [spr_fight_btn, spr_int_btn, spr_action_btn, spr_use_btn];
        var _btn_count = array_length(_btn_sprites); 
         
        draw_set_halign(fa_center);  
        var _button_spacing = 53;  
        var _act_start_x = 112;  
        var _act_y = _gui_h - 32;
        
        for (var _i = 0; _i < _btn_count; _i++) { 
            var _ax = _act_start_x + (_i * _button_spacing);
            if (_i <= 1) {
                _ax -= 6;
            } else {
                _ax += 6;
            }
            
            _ax += _sx;
            var _ay = _act_y + _sy; 
             
            var _is_selected = (menu_stage == BATTLE_MENU.MAIN && menu_cursor == _i);
            if (menu_stage == BATTLE_MENU.TARGET_SELECT && _i == 0) _is_selected = true;
            if (menu_stage == BATTLE_MENU.INTERACT && _i == 1)      _is_selected = true;
            if (menu_stage == BATTLE_MENU.TAKE_ACTION && _i == 2)    _is_selected = true;
            if (menu_stage == BATTLE_MENU.ITEM_USE && _i == 3)       _is_selected = true;
            
            var _current_sprite = _btn_sprites[_i]; 
            if (sprite_exists(_current_sprite)) { 
                var _sub_image = _is_selected ? 1 : 0; 
                var _alpha = (menu_stage == BATTLE_MENU.MAIN) ? 1.0 : 0.40;
                if (_is_selected && menu_stage != BATTLE_MENU.MAIN) _alpha = 1.0; 
                 
                var _selected_y_offset = _is_selected ? -2 : 0;
                draw_sprite_ext(_current_sprite, _sub_image, _ax, _ay + _selected_y_offset, 1.2, 1.2, 0, c_white, _alpha);
            } 
        } 

        var _player_member = (array_length(party_members) > 0) ? party_members[0] : noone; 
        if (_player_member != noone && variable_struct_exists(_player_member, "clover_leaves") && sprite_exists(spr_clover)) { 
            var _btn1_x = (_act_start_x + (1 * _button_spacing)) - 6;
            var _btn2_x = (_act_start_x + (2 * _button_spacing)) + 6;
            var _clover_x = ((_btn1_x + _btn2_x) / 2) + _sx;
            var _clover_y = _act_y - 2 + _sy;   
            
            var _img_frame = clamp(_player_member.clover_leaves, 0, 4);
            draw_sprite_ext(spr_clover, _img_frame, _clover_x, _clover_y, 1.0, 1.0, 0, c_white, 1.0); 
        }

        draw_set_halign(fa_left);
    }

    // --- 7. CONTEXT SUB-MENU OVERLAY --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && menu_stage != BATTLE_MENU.MAIN && battle_text == "") { 
         
        if (menu_stage != BATTLE_MENU.HIT_BAR) {
            if (sprite_exists(spr_box)) {
                draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
            } else {
                draw_set_color(c_black);
                draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, false);
                draw_set_color(c_white);
                draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, true);
            }
        }

        var _options_array = [];
        var _is_inventory = false; 
         
        switch (menu_stage) { 
            case BATTLE_MENU.TARGET_SELECT:  
                var _raw_enemy_count = array_length(global.active_battle_enemies);
                _total_options = _raw_enemy_count; 
                
                if (_raw_enemy_count == 0) break;
                
                var _cols = 2;
                var _cell_w = (_dash_w - 32) / _cols;
                var _cell_h = 14;
                
                var _valid_enemy_index = 0;
                for (var _k = 0; _k < _raw_enemy_count; _k++) {
                    var _item = global.active_battle_enemies[_k];
                    if (!instance_exists(_item)) continue; 
        
                    var _col = _valid_enemy_index % _cols;
                    var _row = floor(_valid_enemy_index / _cols);
                    
                    var _item_x = _dash_x + 20 + (_col * _cell_w);
                    var _item_y = _dash_y + 16 + (_row * _cell_h);

                    if (menu_cursor == _k) {
                        draw_set_color(c_yellow);
                        draw_text_transformed(_item_x - 10, _item_y - 1, ">", 0.5, 0.5, 0);
                    } else {
                        draw_set_color(c_white);
                    }
        
                    var _enemy_name = variable_instance_exists(_item, "name") ? _item.name : "Enemy";
                    var _text_color = c_white;
                    
                    if (variable_instance_exists(_item, "hp") && _item.hp <= 0) {
                        _enemy_name = "[X] " + _enemy_name;
                        _text_color = c_gray;
                    }
                    
                    draw_set_color(_text_color);
                    draw_text_transformed(_item_x, _item_y, _enemy_name, 0.5, 0.5, 0);
        
                    var _bar_x = _item_x + 65;
                    var _bar_y = _item_y + 3;  
                    var _bar_w = 24;           
                    var _bar_h = 2;
                    if (variable_instance_exists(_item, "max_hp") && _item.max_hp > 0) {
                        var _hp_percent = clamp(_item.hp / _item.max_hp, 0, 1);
                        draw_set_color(c_dkgray);
                        draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
            
                        if (_hp_percent > 0) {
                            var _fill_color = (menu_cursor == _k) ? c_orange : c_lime;
                            draw_set_color(_fill_color);
                            draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _hp_percent), _bar_y + _bar_h, false);
                        }
                    }
                    _valid_enemy_index++;
                }
                draw_set_color(c_white);
                break;

            case BATTLE_MENU.INTERACT:      
                _options_array = interact_options;
                break; 
            case BATTLE_MENU.TAKE_ACTION:    
                _options_array = take_action_options;
                break; 
            case BATTLE_MENU.ITEM_USE:
                _is_inventory = true;
                if (instance_exists(obj_item_manager) && variable_instance_exists(obj_item_manager, "inv") && is_array(obj_item_manager.inv)) {
                    _options_array = obj_item_manager.inv;
                } else if (variable_global_exists("inventory") && is_array(global.inventory)) {
                    _options_array = global.inventory;
                }
                break;
            case BATTLE_MENU.ITEM_TARGET_SELECT:
                for(var _p=0; _p<array_length(party_members); _p++) {
                    var _member = party_members[_p];
                    if (is_struct(_member) || instance_exists(_member)) array_push(_options_array, _member);
                }
                break;

            case BATTLE_MENU.HIT_BAR:
    // 1. Draw the dashboard background
    if (sprite_exists(spr_box)) {
        draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
    }

    var _sword_sprite = spr_hit_bar_sword;
    
    if (sprite_exists(_sword_sprite)) {
        // 2. Dynamically calculate center positioning to make it fit
        var _sword_w = sprite_get_width(_sword_sprite);
        var _sword_h = sprite_get_height(_sword_sprite);
        
        // Centers the sprite perfectly inside the 374x61 box
        var _sword_x = _dash_x + ((_dash_w - _sword_w) / 2) + 50;
        var _sword_y = _dash_y + ((_dash_h - _sword_h) / 2) + 10;
        
        // 3. Draw the sword completely unstretched
        draw_sprite_ext(_sword_sprite, 0, _sword_x, _sword_y, 0.7, 0.7, 0, c_white, 1);
        
        // 4. Hit Bar Physics Configuration
        var _blade_start_local_x = 10;   // Pixels from the left edge of the image where the blade starts
        var _blade_end_local_x = 200;    // Pixels from the left edge where the crossguard starts
        
        var _track_start_x = _sword_x + _blade_start_local_x;
        var _total_blade_length = _blade_end_local_x - _blade_start_local_x;

		// 5. Calculate and Draw the Perfect Hit Zone (Syncing math with the striker line)
        var _target_pixel_x = _track_start_x + (_total_blade_length * hit_bar_target); // Removed the broken + 18 offset

        // Draw the inner aqua reference center
        draw_set_color(c_aqua);
        draw_set_alpha(0.25);
        draw_rectangle(_target_pixel_x - 3, _sword_y - 18, _target_pixel_x + 2, _sword_y + _sword_h - 3, false);
        draw_set_alpha(1); // Reset alpha channel immediately

        // 6. Draw the Moving Striker Line
        if (hit_bar_progress > 0) {
            // Your exact original calculation line untouched
            var _reticle_pixel_x = _track_start_x + (_total_blade_length * hit_bar_progress);
            
            draw_set_color(c_white);
            draw_set_alpha(1);
            draw_rectangle(_reticle_pixel_x - 1, _sword_y - 18, _reticle_pixel_x + 1, _sword_y + _sword_h - 3, false);
        }
        
        draw_set_alpha(1);
    }

    // 7. Text Verdict Overlay
    if (hit_bar_verdict != "") {
        draw_set_halign(fa_center);
        var _verdict_color = (hit_bar_verdict == "PERFECT!") ? c_yellow : ((hit_bar_verdict == "GOOD") ? c_lime : c_red);
        draw_text_transformed_color(_dash_x + (_dash_w / 2), _dash_y + 2, hit_bar_verdict, 0.5, 0.5, 0, _verdict_color, _verdict_color, _verdict_color, _verdict_color, 1.0);
    }
    break;
        } 

        if (menu_stage != BATTLE_MENU.HIT_BAR && menu_stage != BATTLE_MENU.TARGET_SELECT) {
            var _cols = 2;
            var _max_visible = 4; 
            
            var _total_options = array_length(_options_array);
            var _current_page = floor(menu_cursor / _max_visible);
            var _start_index = _current_page * _max_visible;
            var _end_index = min(_start_index + _max_visible, _total_options);
            
            var _cell_w = (_dash_w - 48) / _cols;
            var _cell_h = 24; 
            
            draw_set_halign(fa_left);
            draw_set_color(c_white);

            if (_total_options == 0) {
                var _empty_string = "NOTHING AVAILABLE";
                if (menu_stage == BATTLE_MENU.ITEM_USE)           _empty_string = "INVENTORY EMPTY";
                if (menu_stage == BATTLE_MENU.INTERACT)           _empty_string = "NO INTERACTIONS AVAILABLE";
                if (menu_stage == BATTLE_MENU.ITEM_TARGET_SELECT) _empty_string = "NO TARGETS AVAILABLE";
                
                draw_text_transformed(_dash_x + 20, _dash_y + 15, _empty_string, 0.6, 0.6, 0);
            } else {
                for (var _i = _start_index; _i < _end_index; _i++) {
                    var _element = _options_array[_i];
                    if (_element == undefined || _element == noone) continue;

                    var _relative_index = _i - _start_index;
                    var _col = _relative_index % _cols;
                    var _row = floor(_relative_index / _cols);
                    var _xx = _dash_x + 32 + (_col * (_cell_w + 16));
                    var _yy = _dash_y + 14 + (_row * _cell_h);
                    
                    if (menu_cursor == _i) {
                        draw_text_transformed(_xx - 12, _yy, ">", 0.6, 0.6, 0);
                    }
                    
                    var _display_text = "";
                    var _text_color = c_white;

                    if (_is_inventory) {
                        _display_text = (is_struct(_element) && variable_struct_exists(_element, "name")) ? string(_element.name) : "Unknown Item";
                        if (is_struct(_element) && variable_struct_exists(_element, "icon") && sprite_exists(_element.icon)) {
                            var _text_width = string_width(_display_text) * 0.6;
                            draw_sprite_ext(_element.icon, 0, _xx + _text_width + 6, _yy + 4, 0.5, 0.5, 0, c_white, 1);
                        }
                    } 
                    else if (menu_stage == BATTLE_MENU.ITEM_TARGET_SELECT) {
                        _display_text = (variable_struct_exists(_element, "name")) ? string(_element.name) : "Ally";
                        if (variable_struct_exists(_element, "hp") && variable_struct_exists(_element, "max_hp")) {
                            _display_text += " (" + string(_element.hp) + "/" + string(_element.max_hp) + " HP)";
                        }
                    }
                    else {
                        _display_text = string(_element);
                    }

                    draw_set_color(_text_color);
                    draw_text_transformed(_xx, _yy, _display_text, 0.6, 0.6, 0);
                }
                
                if (_total_options > _max_visible) {
                    var _total_pages = ceil(_total_options / _max_visible);
                    var _page_indicator = "PAGE " + string(_current_page + 1) + "/" + string(_total_pages);
                    draw_set_color(c_gray);
                    draw_text_transformed(_dash_x + _dash_w - 64, _dash_y + _dash_h - 12, _page_indicator, 0.4, 0.4, 0);
                }
            }
            draw_set_color(c_white);
        }
    } 

    // --- 8. TRANSIENT COMBAT TEXT OVERLAYS ---
    if (variable_instance_exists(id, "popup_numbers") && is_array(popup_numbers)) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var _pop_count = array_length(popup_numbers);
        for (var _i = 0; _i < _pop_count; _i++) {
            var _p = popup_numbers[_i];
            if (!is_struct(_p)) continue;
                
            if (variable_struct_exists(_p, "text")) {
                var _draw_x = variable_struct_exists(_p, "x") ? _p.x : (variable_struct_exists(_p, "xx") ? _p.xx : 0);
                var _draw_y = variable_struct_exists(_p, "y") ? _p.y : (variable_struct_exists(_p, "yy") ? _p.yy : 0);
            
                var _col  = variable_struct_exists(_p, "color") ? _p.color : c_white;
                var _life = variable_struct_exists(_p, "life") ? _p.life : 30;
            
                var _alpha = clamp(_life / 15, 0, 1);
                draw_set_halign(fa_center);
                draw_text_transformed_color(_draw_x, _draw_y, string(_p.text), 0.5, 0.5, 0, _col, _col, _col, _col, _alpha);
                draw_set_halign(fa_left);
            }
        }
        draw_set_valign(fa_top);
        draw_set_halign(fa_left);
    }
}