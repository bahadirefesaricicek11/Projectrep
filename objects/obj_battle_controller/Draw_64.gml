/// @description Render UI & Tactical Layouts 

var _gui_w = display_get_gui_width(); 
var _gui_h = display_get_gui_height(); 

// Screenshake variables 
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
        
        // ENTRANCE ANIMATION: Back-out easing curve for a snappy bounce entry
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

            _card.x = _draw_x; 
            _card.y = _draw_y; 
             
            var _is_cursor_highlight = (card_cursor == _i); 
            var _box_color = c_white;
            if (_any_card_picked) {
                _box_color = _is_the_chosen_one ? c_white : c_dkgray;
            } else {
                _box_color = _is_cursor_highlight ? c_yellow : c_white;
            }

            var _current_flip = _any_card_picked ? card_flip_angle : 180;
            var _x_scale = cos(degtorad(_current_flip)) * _scale_multiplier; 
            
            var _center_x = _card.x + (_card_w / 2);
            var _center_y = _card.y + (_card_h / 2);
            var _is_showing_front = (_card.is_revealed && _current_flip < 90);

            var _base_sprite = _is_showing_front ? spr_card_front : spr_card_back;
            
            if (sprite_exists(_base_sprite)) {
                draw_sprite_ext(_base_sprite, 0, _center_x, _center_y, _x_scale, _scale_multiplier, _rot_angle, _box_color, _layer_alpha);
            } else {
                if (sprite_exists(box_sprite)) { 
                    draw_sprite_ext(box_sprite, 0, _center_x, _center_y, _x_scale * (_card_w / sprite_get_width(box_sprite)), _scale_multiplier * (_card_h / sprite_get_height(box_sprite)), _rot_angle, _box_color, _layer_alpha); 
                } else { 
                    draw_set_color(_box_color); 
                    draw_set_alpha(_layer_alpha);
                    draw_rectangle(_center_x - (_card_w / 2) * _x_scale, _card.y, _center_x + (_card_w / 2) * _x_scale, _card.y + (_card_h * _scale_multiplier), true); 
                    draw_set_alpha(1.0);
                } 
            }
             
            if (_is_showing_front) { 
                var _render_alpha = ((_any_card_picked && !_is_the_chosen_one) ? 0.45 : 1.0) * _layer_alpha;
                draw_set_alpha(_render_alpha);
                
                draw_set_color(_is_the_chosen_one ? c_black : (_is_cursor_highlight && !_any_card_picked ? c_yellow : c_white)); 
                draw_set_halign(fa_center); 
                 
                var _title_string = string(_card.card_info.name); 
                var _title_scale = 0.45 * _x_scale;   
                var _title_sep = 9;        
                var _max_title_w = (_card_w - 10) / abs(_title_scale + 0.001); 
                 
                draw_text_ext_transformed_color(_center_x, _center_y - (50 * _scale_multiplier), _title_string, _title_sep, _max_title_w, _title_scale, 0.45 * _scale_multiplier, _rot_angle, draw_get_color(), draw_get_color(), draw_get_color(), draw_get_color(), _render_alpha); 
                 
                var _icon_offset_y = -15 * _scale_multiplier;
                var _has_root_sprite = variable_struct_exists(_card, "icon_sprite"); 
                var _has_nest_sprite = variable_struct_exists(_card, "card_info") && variable_struct_exists(_card.card_info, "icon_sprite"); 

                if (_has_root_sprite || _has_nest_sprite) { 
                    var _sprite = _has_root_sprite ? _card.icon_sprite : _card.card_info.icon_sprite; 
                    var _frame  = variable_struct_exists(_card, "icon_frame") ? _card.icon_frame : _card.card_info.icon_frame; 
     
                    if (sprite_exists(_sprite)) { 
                        draw_sprite_ext(_sprite, _frame, _center_x, _center_y + _icon_offset_y, _x_scale, 1.0 * _scale_multiplier, _rot_angle, c_white, _render_alpha); 
                    } 
                } 
                 
                draw_set_color(_any_card_picked && !_is_the_chosen_one ? c_gray : c_black); 
                draw_set_halign(fa_center); 
                 
                var _desc_string = string(_card.card_info.desc); 
                var _desc_scale = 0.50 * _x_scale;    
                var _desc_sep = 20;  
                var _max_desc_w = (_card_w - 12) / abs(_desc_scale + 0.001); 
                 
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

    // --- 1. HUD: CLOVER METER --- 
    var _player_member = (array_length(party_members) > 0) ? party_members[0] : noone; 

    if (_player_member != noone && variable_struct_exists(_player_member, "clover_leaves") && sprite_exists(spr_clover)) { 
        draw_set_halign(fa_center); 
        var _clover_x = 192 + _sx;  
        var _clover_y = 20 + _sy;   
        var _img_frame = clamp(_player_member.clover_leaves, 0, 4); 
        draw_sprite_ext(spr_clover, _img_frame, _clover_x, _clover_y, 1.0, 1.0, 0, c_white, 1.0); 
    } 

    var _row_start_y = 52; 
    var _row_vert_spacing = 42; 

    // --- 2. FIELD LAYER: PLAYER SPRITES --- 
    draw_set_halign(fa_left);  
    var _p_count = array_length(party_members); 
    var _player_field_x = 42 + _sx;  

    for (var _p = 0; _p < _p_count; _p++) { 
        var _m = party_members[_p]; 
        if (_m.hp > 0) { 
            var _py = _row_start_y + (_p * _row_vert_spacing) + _sy; 
             
            if (sprite_exists(_m.sprite)) { 
                draw_sprite_ext(_m.sprite, floor(_m.img_idx), _player_field_x, _py, 1.0, 1.0, 0, c_white, 1.0); 
            } 
             
            var _bar_w = 22; 
            var _bar_h = 3; 
            var _bar_x = _player_field_x - (_bar_w / 2); 
            var _offset_y = sprite_exists(_m.sprite) ? sprite_get_yoffset(_m.sprite) + 4 : 4; 
            var _bar_y = _py - _offset_y;  
             
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

    // --- 3. FIELD LAYER: ENEMY SPRITES --- 
    var _enemy_count = array_length(global.active_battle_enemies); 
    if (_enemy_count > 0) { 
        var _enemy_field_x = _gui_w - 45 + _sx;  
     
        for (var _e = 0; _e < _enemy_count; _e++) { 
            var _enemy_inst = global.active_battle_enemies[_e]; 
         
            if (instance_exists(_enemy_inst) && _enemy_inst.hp > 0) { 
                var _ey = _row_start_y + (_e * _row_vert_spacing) + _sy;  

                var _is_targeted = (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_cursor == _e && battle_sub_state == BATTLE_STATE.PLAYER_INPUT); 
                var _blend = _is_targeted ? c_red : c_white; 
             
                var _enemy_sprite = noone; 
                if (variable_instance_exists(_enemy_inst, "sprite") && sprite_exists(_enemy_inst.sprite)) { 
                    _enemy_sprite = _enemy_inst.sprite; 
                } else if (sprite_exists(_enemy_inst.sprite_index)) { 
                    _enemy_sprite = _enemy_inst.sprite_index; 
                } 

                if (sprite_exists(_enemy_sprite)) { 
                    var _img_idx = variable_instance_exists(_enemy_inst, "image_index") ? _enemy_inst.image_index : 0; 
                    draw_sprite_ext(_enemy_sprite, floor(_img_idx), _enemy_field_x, _ey, 1.0, 1.0, 0, _blend, 1.0); 
                } 
            } 
        } 
    } 

    // --- 4. THE LOWER CHRONICLE --- 
    var _dash_w = _gui_w - 160; 
    var _dash_h = 64; 
    var _dash_x = 80 + _sx; 
    var _dash_y = _gui_h - 128 + _sy; 
     
    if (menu_stage == BATTLE_MENU.MAIN) { 
        if (battle_text != "") { 
            draw_set_color(c_white); 
            draw_set_halign(fa_left); 
            draw_set_valign(fa_top); 
             
            var _text_scale = 0.50;  
            var _line_sep = 14;      
            var _max_text_w = (_dash_w - 20) / _text_scale; 
             
            draw_text_ext_transformed(_dash_x + 10, _dash_y + 8, string_copy(battle_text, 1, floor(text_char_count)), _line_sep, _max_text_w, _text_scale, _text_scale, 0); 
        } 
    } 

    // --- 5. CAROUSEL MAIN BUTTON SYSTEMS --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT) { 
        var _btn_sprites = [spr_fight_btn, spr_int_btn, spr_action_btn, spr_use_btn]; 
        var _btn_count = array_length(_btn_sprites); 
         
        draw_set_halign(fa_center);  
        var _card_spacing = 53;  
        var _act_start_x = 112;  
        var _act_y = _gui_h - 28;  

        for (var _i = 0; _i < _btn_count; _i++) { 
            var _ax = _act_start_x + (_i * _card_spacing) + _sx; 
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
                 
                draw_sprite_ext(_current_sprite, _sub_image, _ax, _ay, 1.0, 1.0, 0, c_white, _alpha); 
            } 
        } 
        draw_set_halign(fa_left);  
    } 

    // --- 6. UNDERTALE STYLE CONTEXT SUB-MENU OVERLAY --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && menu_stage != BATTLE_MENU.MAIN) { 
         
        if (sprite_exists(box_sprite)) {
            draw_sprite_stretched(box_sprite, 0, _dash_x, _dash_y, _dash_w, _dash_h);
        } else {
            draw_set_color(c_black);
            draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, false);
            draw_set_color(c_white);
            draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, true);
        }

        var _options_array = []; 
        var _is_inventory = false; 
         
        switch (menu_stage) { 
            case BATTLE_MENU.TARGET_SELECT:  
                for(var _k=0; _k<array_length(global.active_battle_enemies); _k++) {
                    array_push(_options_array, global.active_battle_enemies[_k]);  
                }
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
                    array_push(_options_array, party_members[_p]);
                }
                break;
        } 

        // --- FIXED PAGINATION GRID RENDERING ENGINE ---
        var _cols = 2;
        var _max_visible = 4; // Display a maximum of 4 options on screen at once
        
        // Calculate current page based on cursor location
        var _current_page = floor(menu_cursor / _max_visible);
        var _start_index = _current_page * _max_visible;
        var _total_options = array_length(_options_array);
        var _end_index = min(_start_index + _max_visible, _total_options);
        
        // Standardized spacing limits designed for 4 visible items
        var _cell_w = (_dash_w - 48) / _cols;
        var _cell_h = 24; 
        
        draw_set_halign(fa_left);
        draw_set_color(c_white);

        if (_total_options == 0) {
            draw_text_transformed(_dash_x + 20, _dash_y + 15, "NOTHING AVAILABLE", 0.6, 0.6, 0);
        } else {
            // Only loop through items belonging to the active viewport slice
            for (var _i = _start_index; _i < _end_index; _i++) {
                var _element = _options_array[_i];
                if (_element == undefined) continue;

                // Relative position inside the 4-item visual window
                var _relative_index = _i - _start_index;
                var _col = _relative_index % _cols;
                var _row = floor(_relative_index / _cols);
                
                // Generous margins: +32 on X guarantees left and right columns remain separated
                var _xx = _dash_x + 32 + (_col * (_cell_w + 16));
                var _yy = _dash_y + 14 + (_row * _cell_h);
                
                // Draw selection asterisk
                if (menu_cursor == _i) {
                    draw_text_transformed(_xx - 12, _yy, "*", 0.6, 0.6, 0);
                }
                
                var _display_text = "";
                var _text_color = c_white;

                if (_is_inventory) {
                    _display_text = variable_struct_exists(_element, "name") ? string(_element.name) : "Unknown Item";
                    
                    if (variable_struct_exists(_element, "icon") && sprite_exists(_element.icon)) {
                        var _text_width = string_width(_display_text) * 0.6;
                        var _icon_x = _xx + _text_width + 6; 
                        var _icon_y = _yy + 4; 
                        
                        draw_sprite_ext(_element.icon, 0, _icon_x, _icon_y, 0.5, 0.5, 0, c_white, 1);
                    }
                } 
                else if (menu_stage == BATTLE_MENU.TARGET_SELECT) {
                    _display_text = string(_element.name);
                    if (variable_instance_exists(_element, "hp") && _element.hp <= 0) {
                        _display_text = "[X] " + _display_text;
                        _text_color = c_gray;
                    }
                } 
                else if (menu_stage == BATTLE_MENU.ITEM_TARGET_SELECT) {
                    _display_text = string(_element.name);
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
            
            // Visual indicator if extra pages exist
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