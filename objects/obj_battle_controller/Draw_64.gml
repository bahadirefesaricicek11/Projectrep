var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

draw_set_font(battle_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);


if (room == rm_battle) 
{
    draw_clear(bg_color); 
    
    var _cell_w = 28; 
    var _cell_h = 36; 
    
    var _cam = view_camera[0];
    var _cam_x = camera_get_view_x(_cam);
    var _cam_y = camera_get_view_y(_cam);
    var _cam_w = camera_get_view_width(_cam);
    var _cam_h = camera_get_view_height(_cam);
    
    var _columns = (_cam_w div _cell_w) + 2; 
    var _rows    = (_cam_h div _cell_h) + 2;
    
    draw_set_alpha(1.0); 
    
    for (var _col = -1; _col < _columns; _col++) 
    {
        for (var _row = -1; _row < _rows; _row++) 
        {
            var _draw_x = floor(_cam_x + (_col * _cell_w) + bg_scroll_x + (_cell_w / 2));
            var _draw_y = floor(_cam_y + (_row * _cell_h) + bg_scroll_y + (_cell_h / 2));
            
            // --- LAGGING FIX: PIXEL-SPACE WAVELENGTH ---
            // Tying the wave phase directly to the visual X coordinate 
            // creates a smooth horizontal ripple that updates every frame without stuttering.
            var _angle = sin(bg_wiggle_timer + (_draw_x * 0.01)) * 20;
            
            draw_sprite_ext(
                bg_scroll_sprite, 0, 
                _draw_x, _draw_y, 
                1, 1, _angle, c_white, 0.20
            );
        }
    }
}

var _sx = random_range(-screenshake_amount, screenshake_amount);
var _sy = random_range(-screenshake_amount, screenshake_amount);

// ========================================== 
// STATE: CARD SELECTION LAYOUT SCREEN 
// ========================================== 
if (global.state == GAME_STATE.CARD_SELECTION) { 
     
    var _card_count = array_length(global.selected_cards);
    if (_card_count > 0) {
        var _card_w = 76, _card_h = 120, _spacing = 12;
        var _total_w = (_card_count * _card_w) + ((_card_count - 1) * _spacing);
        var _start_x = (_gui_w - _total_w) / 2;
        
        var _bounce_t = card_intro_timer - 1;
        var _intro_ease = (_bounce_t * _bounce_t * ((2.70158 + 1) * _bounce_t + 2.70158) + 1);
        var _target_y = (_gui_h - _card_h) / 2;
        var _current_y = lerp(_gui_h + 40, _target_y, _intro_ease);
        var _any_card_picked = (variable_instance_exists(id, "card_choice_locked") && card_choice_locked && variable_global_exists("chosen_battle_card") && global.chosen_battle_card != noone);
        var _t_raw = clamp(transition_timer / transition_duration, 0, 1);
        var _t_progress = (_t_raw < 0.5) ? 4 * _t_raw * _t_raw * _t_raw : 1 - power(-2 * _t_raw + 2, 3) / 2;
        
        for (var _i = 0; _i < _card_count; _i++) {
            var _card = global.selected_cards[_i];
            if (!is_struct(_card) && !instance_exists(_card)) continue;
            
            var _is_the_chosen_one = (_any_card_picked && global.chosen_battle_card == _card);
            var _draw_x = _start_x + (_i * (_card_w + _spacing));
            var _draw_y = _current_y;
            var _scale_multiplier = 1.0, _layer_alpha = 1.0, _rot_angle = 0;
            
            if (in_card_transition) {
                if (_is_the_chosen_one) {
                    _draw_x = lerp(chosen_card_start_x, 192 - (_card_w / 2), _t_progress);
                    _draw_y = lerp(chosen_card_start_y, 20 - (_card_h / 2), _t_progress);
                    _scale_multiplier = lerp(1.0, 0.0, _t_raw * _t_raw);
                    _layer_alpha = lerp(1.0, 0.0, power(_t_raw, 4));
                    _rot_angle = chosen_card_angle;
                } else {
                    _draw_y = _current_y + (power(_t_raw, 3) * (_gui_h - _current_y + 100));
                    _layer_alpha = lerp(1.0, 0.0, clamp(_t_raw * 2, 0, 1));
                }
            }

            var _is_cursor_highlight = (card_cursor == _i);
            var _box_color = _any_card_picked ? (_is_the_chosen_one ? c_white : c_dkgray) : (_is_cursor_highlight ? c_ltgray : c_white);
            var _x_scale = cos(degtorad(_any_card_picked ? card_flip_angle : 180)) * _scale_multiplier;
            
            var _center_x = _draw_x + (_card_w / 2);
            var _center_y = _draw_y + (_card_h / 2);
            var _is_showing_front = (variable_struct_exists(_card, "is_revealed") && _card.is_revealed && (_any_card_picked ? card_flip_angle : 180) < 90);
            var _base_sprite = _is_showing_front ? spr_card_front : spr_card_back;
            var _frame_index = _any_card_picked ? (_is_the_chosen_one ? 1 : 0) : (_is_cursor_highlight && !_is_showing_front ? 1 : 0);
            
            if (sprite_exists(_base_sprite)) {
                draw_sprite_ext(_base_sprite, _frame_index, _center_x, _center_y, _x_scale, _scale_multiplier, _rot_angle, _box_color, _layer_alpha);
            } else if (sprite_exists(spr_box)) {
                draw_sprite_ext(spr_box, _frame_index, _center_x, _center_y, _x_scale * (_card_w / sprite_get_width(spr_box)), _scale_multiplier * (_card_h / sprite_get_height(spr_box)), _rot_angle, _box_color, _layer_alpha);
            } else {
                draw_set_color(_box_color); draw_set_alpha(_layer_alpha);
                draw_rectangle(_center_x - (_card_w / 2) * _x_scale, _draw_y, _center_x + (_card_w / 2) * _x_scale, _draw_y + (_card_h * _scale_multiplier), true);
                draw_set_alpha(1.0);
            } 
             
            if (_is_showing_front && variable_struct_exists(_card, "card_info")) {
                var _render_alpha = ((_any_card_picked && !_is_the_chosen_one) ? 0.45 : 1.0) * _layer_alpha;
                draw_set_alpha(_render_alpha);
                draw_set_color(_is_the_chosen_one ? c_black : (_is_cursor_highlight && !_any_card_picked ? c_yellow : c_white));
                draw_set_halign(fa_center);
                 
                var _title_string = variable_struct_exists(_card.card_info, "name") ? string(_card.card_info.name) : "";
                var _title_scale = 0.45 * _x_scale;   
                draw_text_ext_transformed_color(_center_x, _center_y - (50 * _scale_multiplier), _title_string, 9, (_card_w - 10) / max(abs(_title_scale), 0.001), _title_scale, 0.45 * _scale_multiplier, _rot_angle, draw_get_color(), draw_get_color(), draw_get_color(), draw_get_color(), _render_alpha);
                
                var _has_root_sprite = variable_struct_exists(_card, "icon_sprite");
                var _has_nest_sprite = variable_struct_exists(_card.card_info, "icon_sprite");
                if (_has_root_sprite || _has_nest_sprite) {
                    var _sprite = _has_root_sprite ? _card.icon_sprite : _card.card_info.icon_sprite;
                    var _frame  = variable_struct_exists(_card, "icon_frame") ? _card.icon_frame : (variable_struct_exists(_card.card_info, "icon_frame") ? _card.card_info.icon_frame : 0);
                    if (sprite_exists(_sprite)) {
                        draw_sprite_ext(_sprite, _frame, _center_x, _center_y - 15 * _scale_multiplier, _x_scale, _scale_multiplier, _rot_angle, c_white, _render_alpha);
                    } 
                } 
                 
                draw_set_color(_any_card_picked && !_is_the_chosen_one ? c_gray : c_black);
                var _desc_string = variable_struct_exists(_card.card_info, "desc") ? string(_card.card_info.desc) : "";
                var _desc_scale = 0.50 * _x_scale;    
                draw_text_ext_transformed_color(_center_x, _center_y + (10 * _scale_multiplier), _desc_string, 20, (_card_w - 12) / max(abs(_desc_scale), 0.001), _desc_scale, 0.50 * _scale_multiplier, _rot_angle, draw_get_color(), draw_get_color(), draw_get_color(), draw_get_color(), _render_alpha);
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

    var _column_top_y = 0; // boxes now start flush at the top
    var _box_h = 80; // real height of spr_hp_box
    var _available_height = 216; // swap for _gui_h if this should track view/room size dynamically
    var _fits_at_full_size = (_box_h * party_max_members) <= _available_height;
    var _scale = _fits_at_full_size ? 1 : (_available_height / (_box_h * party_max_members));
    var _row_vert_spacing = _box_h * _scale;

    for (var _i = 0; _i < party_max_members; _i++) {
        var _member = party_members[_i];
        if (!is_struct(_member) && !instance_exists(_member)) continue;

        var _current_box_x = 5 + _sx;
        var _current_box_y = _column_top_y + (_i * _row_vert_spacing) + _sy;

        // Box background now scales too (Option C) — previously this stayed full-size
        // regardless of _scale, so it would've drifted out of sync with the HUD elements
        // drawn inside it once scaling kicked in.
        draw_sprite_ext(spr_hp_box, 0, _current_box_x, _current_box_y, _scale, _scale, 0, c_white, 1.0);

        draw_set_halign(fa_left);
        var _name_color = (_member.hp <= 0) ? c_red : c_white;
        draw_text_transformed_color(
            _current_box_x + HPBOX_NAME_X * _scale + 1,
            _current_box_y + HPBOX_NAME_Y * _scale,
            string_upper(_member.name), 0.75, 0.75, 0,
            _name_color, _name_color, _name_color, _name_color, 1
        );

        // --- Portrait (uses a dedicated portrait_sprite if the member has one, else falls back to the field sprite) ---
        var _portrait_sprite = _member.sprite;
        // Ported from the old FIELD LAYER's _is_active_input check: highlights whichever
        // party member is currently the one choosing an action, grays out everyone else.
        var _is_active_input = (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && party_input_index == _i && menu_stage != BATTLE_MENU.HIT_BAR && battle_text == "");
        var _portrait_color = (_member.hp <= 0) ? c_gray : (_is_active_input ? c_white : c_gray);
        scr_draw_sprite_fit(
            _portrait_sprite, 0,
            _current_box_x + HPBOX_PORTRAIT_X * 1,
            _current_box_y + HPBOX_PORTRAIT_Y * 1,
            HPBOX_PORTRAIT_MAX_W * 1, HPBOX_PORTRAIT_MAX_H * 1,
            _portrait_color, 1.0
        );
        
        // NEW: hit flash — same additive-blend trick as enemies (see the enemy render
        // loop for the full explanation). Calling scr_draw_sprite_fit a second time
        // with the same params is cheap and keeps the exact same fit/position math.
        var _member_flash = variable_struct_exists(_member, "hit_flash_timer") ? _member.hit_flash_timer : 0;
        if (_member_flash > 0) {
            gpu_set_blendmode(bm_add);
            scr_draw_sprite_fit(
                _portrait_sprite, 0,
                _current_box_x + HPBOX_PORTRAIT_X * 1,
                _current_box_y + HPBOX_PORTRAIT_Y * 1,
                HPBOX_PORTRAIT_MAX_W * 1, HPBOX_PORTRAIT_MAX_H * 1,
                c_white, _member_flash / HIT_FLASH_DURATION
            );
            gpu_set_blendmode(bm_normal);
        }

        var _hp_val = max(0, _member.display_hp);
        var _whole_hp = floor(_hp_val);
        var _global_fraction = _hp_val - _whole_hp;
        if (_global_fraction < 0.05 || _global_fraction > 0.95) _global_fraction = 0;

        var _hund_digit = floor(_whole_hp / 100) % 10;
        var _tens_digit = floor(_whole_hp / 10) % 10;
        var _ones_digit = _whole_hp % 10;

        var _hund_frame = _hund_digit * 4, _tens_frame = _tens_digit * 4, _ones_frame = _ones_digit * 4;
        if (_global_fraction > 0) {
            var _sub_offset = floor(_global_fraction * 4);
            _ones_frame += _sub_offset;
            if (_ones_digit == 0) {
                _tens_frame += _sub_offset;
                if (_tens_digit == 0) _hund_frame += _sub_offset;
            }
        }

        var _roller_draw_y = _current_box_y + HPBOX_ROLLER_Y * _scale;
        if (sprite_exists(spr_roller)) {
            var _roller_start_x = _current_box_x + HPBOX_ROLLER_X * _scale;
            var _digit_stride   = _fits_at_full_size ? HPBOX_ROLLER_STRIDE : 9.9;

            draw_sprite_ext(spr_roller, _hund_frame, _roller_start_x, _roller_draw_y, _scale, _scale, 0, c_white, 1);
            draw_sprite_ext(spr_roller, _tens_frame, _roller_start_x + _digit_stride, _roller_draw_y, _scale, _scale, 0, c_white, 1);
            draw_sprite_ext(spr_roller, _ones_frame, _roller_start_x + (_digit_stride * 2), _roller_draw_y, _scale, _scale, 0, c_white, 1);
        }

        if (_i < array_length(global.active_combat_buffs)) {
            var _card_data = global.active_combat_buffs[_i];
            if (_card_data != noone && variable_struct_exists(_card_data, "icon_sprite") && sprite_exists(_card_data.icon_sprite)) {
                var _buff_frame = variable_struct_exists(_card_data, "icon_frame") ? _card_data.icon_frame : 0;
                scr_draw_sprite_fit(
                    _card_data.icon_sprite, _buff_frame,
                    _current_box_x + HPBOX_BUFF_X * _scale,
                    _current_box_y + HPBOX_BUFF_Y * _scale,
                    HPBOX_BUFF_W * _scale, HPBOX_BUFF_H * _scale,
                    c_white, 1.0
                );
            }
        }

    }

	draw_set_halign(fa_left);
    // ==========================================
    // HUD & SPRITE: ENEMY MASTER RENDER LAYOUT
    // ==========================================
    var _e_count = array_length(global.active_battle_enemies);
    for (var _j = 0; _j < _e_count; _j++) {
        var _enemy_inst = global.active_battle_enemies[_j];
        if (!instance_exists(_enemy_inst) || _enemy_inst.hp <= 0) continue;
        
        // Spared enemies fade down to a permanent half-transparent state instead of
        // hiding entirely — they stay visible on the field, just clearly "out of it."
        var _is_spared_now = variable_instance_exists(_enemy_inst, "is_spared") && _enemy_inst.is_spared;
        var _spare_alpha = 1.0;
        if (_is_spared_now) {
            if (!variable_instance_exists(_enemy_inst, "spare_fade_alpha")) _enemy_inst.spare_fade_alpha = 1.0;
            // Eases down to 0.5 and stops — never fully disappears.
            _enemy_inst.spare_fade_alpha = max(0.5, _enemy_inst.spare_fade_alpha - 0.03);
            _spare_alpha = _enemy_inst.spare_fade_alpha;
        }
    
        var _gui_x = _enemy_inst.x - camera_get_view_x(view_camera[0]);
        var _gui_y = _enemy_inst.y - camera_get_view_y(view_camera[0]);
        var _enemy_sprite = variable_instance_exists(_enemy_inst, "sprite_index") ? _enemy_inst.sprite_index : noone;
        
        var _blend_color = (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_cursor == _j && current_time % 200 < 100) ? c_yellow : c_white;
        var _enemy_image_index = variable_instance_exists(_enemy_inst, "image_index") ? _enemy_inst.image_index : 0;
        
        if (sprite_exists(_enemy_sprite)) {
            draw_sprite_ext(_enemy_sprite, _enemy_image_index, _gui_x + _sx + 30, _gui_y + _sy, 1.0, 1.0, 0, _blend_color, _spare_alpha);
            
            // NEW: hit flash — additive-blended copy of the same sprite drawn on top,
            // fading out over HIT_FLASH_DURATION frames. Additive blending BRIGHTENS
            // toward white rather than tinting/darkening (which is what a normal
            // multiply-blend color would do), so this reads as a real "flash" without
            // needing a shader.
            var _enemy_flash = variable_instance_exists(_enemy_inst, "hit_flash_timer") ? _enemy_inst.hit_flash_timer : 0;
            if (_enemy_flash > 0) {
                gpu_set_blendmode(bm_add);
                draw_sprite_ext(_enemy_sprite, _enemy_image_index, _gui_x + _sx + 30, _gui_y + _sy, 1.0, 1.0, 0, c_white, (_enemy_flash / HIT_FLASH_DURATION) * _spare_alpha);
                gpu_set_blendmode(bm_normal);
            }
        } else {
            draw_set_color(c_purple); draw_set_alpha(_spare_alpha);
            draw_rectangle(_gui_x - 16 + _sx, _gui_y - 16 + _sy, _gui_x + 16 + _sx, _gui_y + 16 + _sy, false);
            draw_set_alpha(1.0);
        }
        
        // Spared enemies skip the name/HP/mercy HUD entirely — those numbers no
        // longer mean anything once they're out of the fight.
        if (_is_spared_now) continue;

        var _sprite_top_offset = sprite_exists(_enemy_sprite) ? sprite_get_height(_enemy_sprite) - sprite_get_yoffset(_enemy_sprite) : 16;
        var _box_x = _gui_x + _sx + 30, _box_y = (_gui_y - _sprite_top_offset - 5) + _sy;
        var _bar_w = 40, _bar_h = 4;
    
        draw_set_halign(fa_center); draw_set_color(c_white);
        draw_text_transformed(_box_x, _box_y - 12, string_upper(_enemy_inst.name), 0.35, 0.35, 0);
    
        draw_set_color(c_dkgray); draw_rectangle(_box_x - (_bar_w / 2), _box_y, _box_x + (_bar_w / 2), _box_y + _bar_h, false);
        
        if (_enemy_inst.max_hp > 0) {
            var _current_display_hp = variable_instance_exists(_enemy_inst, "display_hp") ? _enemy_inst.display_hp : _enemy_inst.hp;
            var _hp_percent = clamp(_current_display_hp / _enemy_inst.max_hp, 0, 1);
            if (_hp_percent > 0) {
                draw_set_color((_hp_percent <= 0.25) ? c_orange : c_red);
                draw_rectangle(_box_x - (_bar_w / 2), _box_y, (_box_x - (_bar_w / 2)) + (_bar_w * _hp_percent), _box_y + _bar_h, false);
            }
        }
        draw_set_color(c_black); draw_rectangle(_box_x - (_bar_w / 2) - 1, _box_y - 1, _box_x + (_bar_w / 2) + 1, _box_y + _bar_h + 1, true);
        
        // --- MERCY / SPARE METER (mirrors the HP bar, drawn just below it) ---
        if (variable_instance_exists(_enemy_inst, "mercy") && variable_instance_exists(_enemy_inst, "max_mercy") && _enemy_inst.max_mercy > 0) {
            var _mercy_bar_y = _box_y + _bar_h + 3;
            var _mercy_percent = clamp(_enemy_inst.mercy / _enemy_inst.max_mercy, 0, 1);
            
            draw_set_color(c_dkgray);
            draw_rectangle(_box_x - (_bar_w / 2), _mercy_bar_y, _box_x + (_bar_w / 2), _mercy_bar_y + _bar_h, false);
            
            if (_mercy_percent > 0) {
                // Turns green once the enemy is actually spareable, otherwise gold while filling up
                var _can_spare_now = variable_instance_exists(_enemy_inst, "can_spare") && _enemy_inst.can_spare;
                draw_set_color(_can_spare_now ? c_lime : c_yellow);
                draw_rectangle(_box_x - (_bar_w / 2), _mercy_bar_y, (_box_x - (_bar_w / 2)) + (_bar_w * _mercy_percent), _mercy_bar_y + _bar_h, false);
            }
            
            draw_set_color(c_black);
            draw_rectangle(_box_x - (_bar_w / 2) - 1, _mercy_bar_y - 1, _box_x + (_bar_w / 2) + 1, _mercy_bar_y + _bar_h + 1, true);
        }
    }
	
	
    // --- 5. THE LOWER CHRONICLE (TEXT CONTROLLER) --- 
    var _dash_w = _gui_w - 160, _dash_h = 64, _dash_x = 80 + _sx, _dash_y = _gui_h - 128 + _sy;
    
    if (battle_text != "") { 
        if (sprite_exists(spr_box)) draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
        else {
            draw_set_color(c_black); draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, false);
            draw_set_color(c_white); draw_rectangle(_dash_x, _dash_y, _dash_x + _dash_w, _dash_y + _dash_h, true);
        }
        draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top); 
        draw_text_ext_transformed(_dash_x + 10, _dash_y + 8, string_copy(battle_text, 1, floor(text_char_count)), 14, (_dash_w - 20) / 0.50, 0.50, 0.50, 0);
    } 

    // --- 6. CAROUSEL MAIN BUTTON SYSTEMS --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && battle_text == "") { 
        var _btn_sprites = [spr_fight_btn, spr_int_btn, spr_action_btn, spr_use_btn];
        draw_set_halign(fa_center);  
        
        // Persistent per-button lift value, eased toward its target each frame
        // instead of snapping instantly — was reported as part of navigation
        // feeling "clanky."
        if (!variable_instance_exists(id, "carousel_lift") || !is_array(carousel_lift) || array_length(carousel_lift) != 4) {
            carousel_lift = [0, 0, 0, 0];
        }
        
        for (var _i = 0; _i < 4; _i++) { 
            var _ax = 112 + (_i * 53) + (_i <= 1 ? -6 : 6) + _sx;
            var _ay = (_gui_h - 32) + _sy; 
             
            // FIX: TARGET_SELECT is now the entry point for THREE different flows
            // (Fight, Interact's target-pick, Spare's target-pick), not just Fight —
            // checking only menu_stage always highlighted "Fight" regardless of which
            // one actually put you there, which is exactly why Interact's button
            // looked like it was showing Fight instead. menu_context disambiguates.
            var _is_selected = (menu_stage == BATTLE_MENU.MAIN && menu_cursor == _i) ||
                               (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_context == "fight" && _i == 0) ||
                               (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_context == "interact_pick_target" && _i == 1) ||
                               (menu_stage == BATTLE_MENU.TARGET_SELECT && menu_context == "spare_pick_target" && _i == 2) ||
                               (menu_stage == BATTLE_MENU.INTERACT && _i == 1) ||
                               (menu_stage == BATTLE_MENU.TAKE_ACTION && _i == 2) ||
                               (menu_stage == BATTLE_MENU.ITEM_USE && _i == 3);
            
            carousel_lift[_i] = lerp(carousel_lift[_i], _is_selected ? -4 : 0, 0.35);
            
            var _current_sprite = _btn_sprites[_i]; 
            if (sprite_exists(_current_sprite)) { 
                var _alpha = (menu_stage == BATTLE_MENU.MAIN || _is_selected) ? 1.0 : 0.40;
                draw_sprite_ext(_current_sprite, _is_selected ? 1 : 0, _ax, _ay + carousel_lift[_i], 1.2, 1.2, 0, c_white, _alpha);
            } 
        } 

        var _player_member = (array_length(party_members) > 0) ? party_members[0] : noone; 
        if (_player_member != noone && variable_struct_exists(_player_member, "clover_leaves") && sprite_exists(spr_clover)) { 
            var _clover_cx = (((112 + 53) - 6) + ((112 + 106) + 6)) / 2 + _sx;
            var _clover_cy = 25 + _sy;
            var _clover_count = clamp(_player_member.clover_leaves, 0, 4);
            var _clover_is_max = (_clover_count >= 4);
            
            // Solid glow bloom when fully charged — a few opaque layered circles
            // rather than a wash of transparent bands, so it reads as a genuine glow
            // and not a "cheap" transparency effect.
            if (_clover_is_max) {
                var _glow_pulse = 1 + (sin(current_time * 0.008) * 0.15);
                draw_set_alpha(0.30);
                draw_set_color(make_colour_rgb(255, 230, 120));
                draw_circle(_clover_cx, _clover_cy, 20 * _glow_pulse, false);
                draw_set_alpha(0.5);
                draw_circle(_clover_cx, _clover_cy, 13 * _glow_pulse, false);
                draw_set_alpha(1.0);
            }
            
            var _clover_scale = _clover_is_max ? (1.2 + sin(current_time * 0.01) * 0.06) : 1.0;
            draw_sprite_ext(spr_clover, _clover_count, _clover_cx, _clover_cy, _clover_scale, _clover_scale, 0, c_white, 1.0); 
            
            if (_clover_is_max) {
                draw_set_halign(fa_center);
                draw_set_color(make_colour_rgb(255, 215, 0));
                draw_text_transformed(_clover_cx, _clover_cy + 17, "READY!", 0.4, 0.4, 0);
                draw_set_halign(fa_left);
                draw_set_color(c_white);
            }
        }
        draw_set_halign(fa_left);
    }

    // --- 6b. DODGE WINDOW (Block-Tales-style QTE before an enemy attack lands) ---
    // Every ring here uses draw_ring_solid (scr_battle_functions) — real filled
    // triangle-strip geometry between an inner and outer radius. This replaces BOTH
    // earlier attempts: stacked draw_circle outlines (gaps at these sizes) and
    // fill-then-punch layering (which, with 3+ overlapping rings, was actually
    // erasing part of the Good zone whenever the Perfect zone punched through it).
    // Each ring here is self-contained and can't bleed into or erase any other.
    if (battle_sub_state == BATTLE_STATE.DODGE_WINDOW) {
        var _dq_center_x = _gui_w / 2 + _sx;
        var _dq_center_y = (_gui_h / 2) - 10 + _sy;
        var _dq_base_radius = 70;
        
        var _dq_perfect = variable_instance_exists(id, "dodge_perfect_threshold") ? dodge_perfect_threshold : 0.12;
        var _dq_good    = variable_instance_exists(id, "dodge_good_threshold")    ? dodge_good_threshold    : 0.30;
        
        var _dq_target_radius  = _dq_base_radius * dodge_target;
        var _dq_good_px        = _dq_good * _dq_base_radius;
        var _dq_perfect_px     = _dq_perfect * _dq_base_radius;
        
        // Solid dark backdrop disc — grounds the whole meter as a contained HUD
        // element instead of shapes floating directly over the arena background.
        draw_set_color(c_black);
        draw_circle(_dq_center_x, _dq_center_y, _dq_base_radius + 14, false);
        
        // Gentle pulse on the target zone only — draws the eye without making the
        // panel itself feel unstable.
        var _dq_pulse = 1 + (sin(current_time * 0.006) * 0.06);
        
        // Track ring: solid gray outline of the whole play area
        draw_ring_solid(_dq_center_x, _dq_center_y, _dq_base_radius - 2, _dq_base_radius + 2, c_ltgray);
        
        // Good zone: solid opaque orange ring
        var _dq_good_min = max(0, _dq_target_radius - (_dq_good_px * _dq_pulse));
        var _dq_good_max = _dq_target_radius + (_dq_good_px * _dq_pulse);
        draw_ring_solid(_dq_center_x, _dq_center_y, _dq_good_min, _dq_good_max, c_orange);
        
        // Perfect zone: solid opaque lime ring, nested inside the Good zone — since
        // this is its OWN ring geometry (not a punch into the Good zone's fill), the
        // Good zone's outer and inner portions on either side of it stay fully intact.
        var _dq_perfect_min = max(0, _dq_target_radius - (_dq_perfect_px * _dq_pulse));
        var _dq_perfect_max = _dq_target_radius + (_dq_perfect_px * _dq_pulse);
        draw_ring_solid(_dq_center_x, _dq_center_y, _dq_perfect_min, _dq_perfect_max, c_lime);
        
        // The moving ring: shrinks from the full radius down to 0 as dodge_progress
        // counts down from 1 to 0. A black drop-shadow ring drawn first gives it
        // contrast against the zones/backdrop. Color shifts white -> lime as it nears
        // the target.
        var _dq_current_radius = _dq_base_radius * clamp(dodge_progress, 0, 1);
        var _dq_distance_norm = clamp(abs(dodge_progress - dodge_target) / _dq_good, 0, 1);
        var _dq_ring_color = merge_color(c_lime, c_white, _dq_distance_norm);
        
        draw_ring_solid(_dq_center_x, _dq_center_y, _dq_current_radius - 4, _dq_current_radius + 4, c_black);
        draw_ring_solid(_dq_center_x, _dq_center_y, _dq_current_radius - 2, _dq_current_radius + 2, _dq_ring_color);
        
        // "NOW!" callout: fires whenever the moving ring is actually inside the Good
        // zone, so success is communicated by more than just color (helps colorblind
        // players too, and just reads clearer at a glance during a fast QTE).
        var _dq_in_good_zone = (abs(dodge_progress - dodge_target) <= _dq_good);
        if (_dq_in_good_zone) {
            var _dq_now_pulse = 1 + (sin(current_time * 0.03) * 0.15);
            draw_set_halign(fa_center);
            draw_set_color(c_yellow);
            draw_text_transformed(_dq_center_x, _dq_center_y - 6, "NOW!", 0.7 * _dq_now_pulse, 0.7 * _dq_now_pulse, 0);
            draw_set_halign(fa_left);
        }
        
        // Subtle pulsing scale on the prompt text so the screen doesn't feel static
        var _dq_prompt_scale = 0.6 + (sin(current_time * 0.01) * 0.04);
        draw_set_halign(fa_center);
        draw_set_color(c_yellow);
        draw_text_transformed(_dq_center_x, _dq_center_y - _dq_base_radius - 26, "PRESS ACCEPT!", _dq_prompt_scale, _dq_prompt_scale, 0);
        draw_set_color(c_white);
        draw_text_transformed(_dq_center_x, _dq_center_y + _dq_base_radius + 14, "Tap when the ring closes on the band!", 0.4, 0.4, 0);
        draw_set_halign(fa_left);
        draw_set_color(c_white);
    }

    // --- 7. CONTEXT SUB-MENU OVERLAY --- 
    if (battle_sub_state == BATTLE_STATE.PLAYER_INPUT && menu_stage != BATTLE_MENU.MAIN && battle_text == "") { 
         
        if (menu_stage != BATTLE_MENU.HIT_BAR && sprite_exists(spr_box)) {
            draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
        }

        var _options_array = [];
        var _is_inventory = false; 
         
        switch (menu_stage) { 
            case BATTLE_MENU.TARGET_SELECT:  
                var _raw_enemy_count = array_length(global.active_battle_enemies);
                if (_raw_enemy_count == 0) break;
                
                var _cols = 2, _cell_w = (_dash_w - 32) / _cols, _cell_h = 14;
                var _valid_enemy_index = 0;
                
                for (var _k = 0; _k < _raw_enemy_count; _k++) {
                    var _item = global.active_battle_enemies[_k];
                    if (!instance_exists(_item)) continue; 
                    
                    var _item_is_spared = variable_instance_exists(_item, "is_spared") && _item.is_spared;
                    
                    // Spare's target select only ever shows enemies actually ready to be spared.
                    if (menu_context == "spare_pick_target") {
                        var _item_spareable = !_item_is_spared && variable_instance_exists(_item, "hp") && _item.hp > 0
                            && variable_instance_exists(_item, "can_spare") && _item.can_spare;
                        if (!_item_spareable) continue;
                    }
        
                    var _item_x = _dash_x + 20 + ((_valid_enemy_index % _cols) * _cell_w);
                    var _item_y = _dash_y + 16 + (floor(_valid_enemy_index / _cols) * _cell_h);
                    var _ts_is_selected = (menu_cursor == _k);
        
                    var _enemy_name = variable_instance_exists(_item, "name") ? _item.name : "Enemy";
                    var _text_color = _ts_is_selected ? c_yellow : c_white;
                    if (variable_instance_exists(_item, "hp") && _item.hp <= 0) {
                        _enemy_name = "[X] " + _enemy_name; _text_color = c_gray;
                    } else if (_item_is_spared) {
                        // Fight/Interact contexts still list every enemy, so mark spared ones
                        // clearly (they're excluded from being targetable, per the step script).
                        _enemy_name = "[SPARED] " + _enemy_name; _text_color = c_gray;
                    }
                    
                    draw_set_color(_text_color); draw_text_transformed(_item_x, _item_y, _enemy_name, 0.5, 0.5, 0);
        
                    if (variable_instance_exists(_item, "max_hp") && _item.max_hp > 0) {
                        var _hp_percent = clamp(_item.hp / _item.max_hp, 0, 1);
                        // FIX: outline + empty track now always draw at FULL width. Previously
                        // these scaled by _hp_percent too, so a low HP value collapsed the
                        // whole box down to a sliver instead of showing a mostly-empty bar.
						draw_set_color((menu_cursor == _k) ? c_ltgray : c_white);
						draw_rectangle(_item_x + 29, _item_y + 3, _item_x + 31 + 24, _item_y + 11, false);
                        draw_set_color(c_dkgray); 
						draw_rectangle(_item_x + 30, _item_y + 4, _item_x + 30 + 24, _item_y + 10, false);
                        if (_hp_percent > 0) {
                            // HP box is now always red (was orange/lime depending on cursor)
                            draw_set_color((menu_cursor == _k) ? c_red : make_colour_rgb(170, 0, 0));
                            draw_rectangle(_item_x + 30, _item_y + 4, (_item_x + 30) + (24 * _hp_percent), _item_y + 10, false);
                        }
						draw_set_colour(c_white);
						draw_text_transformed(_item_x + 35, _item_y+1, string(round(_hp_percent * 100)) + "%", 0.5,0.5, 0);
                    }
                    
                    // --- SPARE/MERCY PERCENTAGE BOX, drawn just to the right of the HP box ---
                    if (variable_instance_exists(_item, "max_mercy") && _item.max_mercy > 0) {
                        var _mercy_percent = clamp(_item.mercy / _item.max_mercy, 0, 1);
                        var _mercy_x = _item_x + 70; // sits just right of the HP box + its % text
                        var _mercy_w = 20;
                        
                        // FIX: same bug as the HP box above — outline + empty track now always
                        // draw at full fixed width, regardless of the current mercy percent.
                        draw_set_color((menu_cursor == _k) ? c_ltgray : c_white);
                        draw_rectangle(_mercy_x - 1, _item_y + 3, _mercy_x + 1 + _mercy_w, _item_y + 11, false);
                        draw_set_color((menu_cursor == _k) ? c_gray : c_dkgray);
                        draw_rectangle(_mercy_x, _item_y + 4, _mercy_x + _mercy_w, _item_y + 10, false);
                        
                        if (_mercy_percent > 0) {
                            draw_set_color(c_yellow);
                            draw_rectangle(_mercy_x, _item_y + 4, _mercy_x + (_mercy_w * _mercy_percent), _item_y + 10, false);
                        }
                        
                        // FIX: now uses the exact same Y and scale as the HP% text (was
                        // _item_y + 1 already, but a different font scale — 0.45 vs 0.5 —
                        // shifted its visual baseline enough to look misaligned) and is
                        // now white instead of black, matching the HP% text's color.
                        draw_set_color(c_white);
                        draw_text_transformed(_mercy_x + 4, _item_y + 1, string(round(_mercy_percent * 100)) + "%", 0.5, 0.5, 0);
                    }
                    
                    _valid_enemy_index++;
                }
                draw_set_color(c_white);
                break;

            case BATTLE_MENU.INTERACT:       _options_array = interact_options; break; 
            case BATTLE_MENU.TAKE_ACTION:     _options_array = take_action_options; break; 
            case BATTLE_MENU.ITEM_USE:
                _is_inventory = true;
                if (instance_exists(obj_item_manager) && variable_instance_exists(obj_item_manager, "inv") && is_array(obj_item_manager.inv)) _options_array = obj_item_manager.inv;
                else if (variable_global_exists("inventory") && is_array(global.inventory)) _options_array = global.inventory;
                break;
            case BATTLE_MENU.ITEM_TARGET_SELECT:
                for(var _p=0; _p<array_length(party_members); _p++) {
                    var _member = party_members[_p];
                    if (is_struct(_member) || instance_exists(_member)) array_push(_options_array, _member);
                }
                break;

            case BATTLE_MENU.HIT_BAR:
                if (sprite_exists(spr_box)) draw_sprite_stretched(spr_box, 0, _dash_x, _dash_y, _dash_w, _dash_h);
                var _sword_sprite = spr_hit_bar_sword;
                
                if (sprite_exists(_sword_sprite)) {
                    var _sword_w = sprite_get_width(_sword_sprite), _sword_h = sprite_get_height(_sword_sprite);
                    var _sword_x = _dash_x + ((_dash_w - _sword_w) / 2) + 50, _sword_y = _dash_y + ((_dash_h - _sword_h) / 2) + 10;
                    
                    draw_sprite_ext(_sword_sprite, 0, _sword_x, _sword_y, 0.7, 0.7, 0, c_white, 1);
                    
                    var _track_start_x = _sword_x + 10;
                    var _total_blade_length = 190;
                    var _target_pixel_x = _track_start_x + (_total_blade_length * hit_bar_target);

                    draw_set_color(c_aqua); draw_set_alpha(0.25);
                    draw_rectangle(_target_pixel_x - 3, _sword_y - 18, _target_pixel_x + 2, _sword_y + _sword_h - 3, false);
                    draw_set_alpha(1.0);

                    if (hit_bar_progress > 0) {
                        var _reticle_pixel_x = _track_start_x + (_total_blade_length * hit_bar_progress);
                        draw_set_color(c_white);
                        draw_rectangle(_reticle_pixel_x - 1, _sword_y - 18, _reticle_pixel_x + 1, _sword_y + _sword_h - 3, false);
                    }
                }

                if (hit_bar_verdict != "") {
                    draw_set_halign(fa_center);
                    var _verdict_color = (hit_bar_verdict == "PERFECT!") ? c_yellow : ((hit_bar_verdict == "GOOD") ? c_lime : c_red);
                    draw_text_transformed_color(_dash_x + (_dash_w / 2), _dash_y + 2, hit_bar_verdict, 0.5, 0.5, 0, _verdict_color, _verdict_color, _verdict_color, _verdict_color, 1.0);
                }
                break;
        } 

        // --- Generic option-list renderer for Interact / Take Action / Item Use / Item Target Select ---
        // Restyled to match TARGET_SELECT: same spacing (cell_w/cell_h/offsets), same cursor arrow
        // style, and the selected line is drawn in yellow (not just marked by the arrow), with
        // unavailable entries grayed out the same way dead enemies are in Target Select.
        if (menu_stage != BATTLE_MENU.HIT_BAR && menu_stage != BATTLE_MENU.TARGET_SELECT) {
            var _cols = 2, _max_visible = 4; 
            var _total_options = array_length(_options_array);
            var _current_page = floor(menu_cursor / _max_visible);
            var _start_index = _current_page * _max_visible;
            var _end_index = min(_start_index + _max_visible, _total_options);
            var _cell_w = (_dash_w - 32) / _cols, _cell_h = 14; 
            
            draw_set_halign(fa_left); draw_set_color(c_white);

            if (_total_options == 0) {
                var _empty_string = "NOTHING AVAILABLE";
                if (menu_stage == BATTLE_MENU.ITEM_USE)           _empty_string = "INVENTORY EMPTY";
                if (menu_stage == BATTLE_MENU.INTERACT)           _empty_string = "NO INTERACTIONS AVAILABLE";
                if (menu_stage == BATTLE_MENU.ITEM_TARGET_SELECT) _empty_string = "NO TARGETS AVAILABLE";
                draw_set_color(c_white);
                draw_text_transformed(_dash_x + 20, _dash_y + 15, _empty_string, 0.5, 0.5, 0);
            } else {
                for (var _i = _start_index; _i < _end_index; _i++) {
                    var _element = _options_array[_i];
                    if (_element == undefined || _element == noone) continue;

                    var _relative_index = _i - _start_index;
                    var _xx = _dash_x + 20 + ((_relative_index % _cols) * _cell_w);
                    var _yy = _dash_y + 16 + (floor(_relative_index / _cols) * _cell_h);
                    
                    var _is_selected = (menu_cursor == _i);
                    var _text_color = _is_selected ? c_yellow : c_white;
                    
                    var _display_text = "";
                    if (_is_inventory) {
                        // FIX: items store a localization key (name_key), not a plain
                        // .name field — the hover-inspection code below already knows
                        // this (__(_inspect_item.name_key)), but this list was checking
                        // .name instead, which items don't have, so it always fell
                        // through to "Unknown Item" even though the icon rendered fine.
                        if (is_struct(_element) && variable_struct_exists(_element, "name_key")) {
                            _display_text = __(_element.name_key);
                        } else if (is_struct(_element) && variable_struct_exists(_element, "name")) {
                            _display_text = string(_element.name);
                        } else {
                            _display_text = "Unknown Item";
                        }
                        draw_set_color(_text_color);
                        draw_text_transformed(_xx, _yy, _display_text, 0.5, 0.5, 0);
                        if (is_struct(_element) && variable_struct_exists(_element, "icon") && sprite_exists(_element.icon)) {
                            draw_sprite_ext(_element.icon, 0, _xx + (string_width(_display_text) * 0.5) + 6, _yy + 4, 0.5, 0.5, 0, c_white, 1);
                        }
                    } 
                    else if (menu_stage == BATTLE_MENU.ITEM_TARGET_SELECT) {
                        _display_text = (variable_struct_exists(_element, "name")) ? string(_element.name) : "Ally";
                        var _is_downed = (variable_struct_exists(_element, "hp") && _element.hp <= 0);
                        if (_is_downed) { _display_text = "[X] " + _display_text; _text_color = c_gray; }
                        if (variable_struct_exists(_element, "hp") && variable_struct_exists(_element, "max_hp")) {
                            _display_text += " (" + string(_element.hp) + "/" + string(_element.max_hp) + " HP)";
                        }
                        draw_set_color(_text_color);
                        draw_text_transformed(_xx, _yy, _display_text, 0.5, 0.5, 0);
                    } else {
                        _display_text = string(_element);
                        draw_set_color(_text_color);
                        draw_text_transformed(_xx, _yy, _display_text, 0.5, 0.5, 0);
                    }
                }
                
                if (_total_options > _max_visible) {
                    draw_set_color(c_gray);
                    draw_text_transformed(_dash_x + _dash_w - 64, _dash_y + _dash_h - 12, "PAGE " + string(_current_page + 1) + "/" + string(ceil(_total_options / _max_visible)), 0.4, 0.4, 0);
                }
            }
            draw_set_color(c_white);
        }
    } 

    // --- 8. TRANSIENT COMBAT TEXT OVERLAYS ---
    if (variable_instance_exists(id, "popup_numbers") && is_array(popup_numbers)) {
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_set_font(Bitmap_Font); // dedicated font for damage numbers/SPARED!/DODGED!/etc.
        var _pop_count = array_length(popup_numbers);
        
        for (var _i = 0; _i < _pop_count; _i++) {
            var _p = popup_numbers[_i];
            if (is_struct(_p) && variable_struct_exists(_p, "text")) {
                var _draw_x = variable_struct_exists(_p, "x") ? _p.x : (variable_struct_exists(_p, "xx") ? _p.xx : 0);
                var _draw_y = variable_struct_exists(_p, "y") ? _p.y : (variable_struct_exists(_p, "yy") ? _p.yy : 0);
                var _col  = variable_struct_exists(_p, "color") ? _p.color : c_white;
                // NEW: optional second color for a top-to-bottom gradient (e.g. gold-to-
                // orange for mercy gains, orange-to-red for crits) instead of a flat single
                // color. Falls back to _col on both ends if color2 isn't set, so every
                // existing flat-color popup (plain damage numbers, DODGED!, etc.) still
                // renders exactly as before.
                var _col2 = variable_struct_exists(_p, "color2") ? _p.color2 : _col;
                var _life = variable_struct_exists(_p, "life") ? _p.life : 30;
                var _scale = variable_struct_exists(_p, "scale") ? _p.scale : 0.5;
            
                draw_text_transformed_color(_draw_x, _draw_y, string(_p.text), _scale, _scale, 0, _col, _col, _col2, _col2, clamp(_life / 15, 0, 1));
            }
            // NEW: renders battle_spawn_hit_particles' output — these were being created
            // and given physics (see the Step event) but nothing was ever drawing them,
            // since this loop only handled text-bearing popups before.
            else if (is_struct(_p) && variable_struct_exists(_p, "type") && _p.type == "particle") {
                var _p_col = variable_struct_exists(_p, "color") ? _p.color : c_white;
                var _p_life = variable_struct_exists(_p, "life") ? _p.life : 20;
                var _p_max_life = variable_struct_exists(_p, "max_life") ? _p.max_life : 35;
                var _p_size = variable_struct_exists(_p, "size") ? _p.size : 2;
                
                draw_set_color(_p_col);
                draw_set_alpha(clamp(_p_life / _p_max_life, 0, 1));
                draw_circle(_p.x, _p.y, _p_size, false);
                draw_set_alpha(1.0);
            }
            // NEW: weapon-specific hit effects (e.g. sword slash) — plays through the
            // sprite's own frames at the target's position via the Step event's frame
            // advancement above. Full opacity throughout (a slash shouldn't fade out
            // mid-swing); it simply expires once the animation finishes.
            else if (is_struct(_p) && variable_struct_exists(_p, "type") && _p.type == "sprite_effect") {
                if (variable_struct_exists(_p, "sprite") && sprite_exists(_p.sprite)) {
                    var _fx_frame = variable_struct_exists(_p, "frame") ? _p.frame : 0;
                    var _fx_scale = variable_struct_exists(_p, "fx_scale") ? _p.fx_scale : 1.0;
                    draw_sprite_ext(_p.sprite, floor(_fx_frame), _p.x, _p.y, _fx_scale, _fx_scale, 0, c_white, 1.0);
                }
            }
        }
        draw_set_valign(fa_top); draw_set_halign(fa_left);
        draw_set_font(battle_font);
        draw_set_color(c_white);
    }
}
