/// @description Render Encounter Cards UI

var _target_w = 384;
var _target_h = 216;
var _queue_size = array_length(encounter_composition);

for (var _i = 0; _i < card_count; _i++) {
    var _x1 = _i * card_width;
    var _y1 = card_y[_i]; // Vertical position handled by Step Event calculations
    
    // --- 1. DRAW CARD BACKING ---
    if (sprite_exists(card_back_sprite)) {
        draw_sprite(card_back_sprite, 0, _x1, _y1);
    } else {
        // Fallback vector container box if asset tree index is corrupted
        draw_set_color(c_black);
        draw_rectangle(_x1, _y1, _x1 + card_width, _y1 + _target_h, false);
        draw_set_color(c_white);
        draw_rectangle(_x1 + 4, _y1 + 4, _x1 + card_width - 4, _y1 + _target_h - 4, true);
    }
    
    // --- 2. DYNAMIC ENEMY SLOT MAPPING ---
    var _enemy_key = noone;
    switch (_queue_size) {
        case 1:
            if (_i == 1) _enemy_key = encounter_composition[0]; // Center slot
            break;
        case 2:
            if (_i == 0) _enemy_key = encounter_composition[0]; // Left slot
            if (_i == 1) _enemy_key = encounter_composition[1]; // Center slot
            break;
        case 3:
            _enemy_key = encounter_composition[_i]; // Full row allocation
            break;
    }
    
    // Define the exact visual midpoint anchors for this card column segment
    var _center_x = _x1 + (card_width / 2);
    var _frame_center_y = _y1 + 92; // Pushes down past the "ENEMY" text straight into the box center
    
    // --- 3. DRAW THE PORTRAIT IF THE SLOT IS OCCUPIED ---
    if (_enemy_key != noone) {
        if (variable_global_exists("enemy_database") && variable_struct_exists(global.enemy_database, _enemy_key)) {
            var _blueprint = global.enemy_database[$ _enemy_key];
            var _enemy_sprite = variable_struct_exists(_blueprint, "sprite") ? _blueprint.sprite : noone;
            
            if (sprite_exists(_enemy_sprite)) {
                // The square frame looks to be roughly 56x56 pixels wide on your 128px canvas
                var _max_allowed_w = 54; 
                var _max_allowed_h = 54; 
                
                // Fetch asset dimensions
                var _sprite_w = sprite_get_width(_enemy_sprite);
                var _sprite_h = sprite_get_height(_enemy_sprite);
                
                // Calculate scale constraints
                var _scale_x = _max_allowed_w / _sprite_w;
                var _scale_y = _max_allowed_h / _sprite_h;
                
                // Maintain aspect ratio
                var _final_scale = min(_scale_x, _scale_y);
                
                // Scale bounds clamping for tiny pixel art icons
                if (_final_scale > 2.0) _final_scale = 2.0;
                
                // --- ORIGIN RE-ALIGNMENT FOR PERFECT CENTERING ---
                var _x_offset = sprite_get_xoffset(_enemy_sprite);
                var _y_offset = sprite_get_yoffset(_enemy_sprite);
                
                var _draw_x = _center_x;
                var _draw_y = _frame_center_y;
                
                // If sprite origins are left at Top-Left (0,0), calculate manual centering offsets
                if (_x_offset == 0 && _y_offset == 0) {
                    _draw_x = _center_x - ((_sprite_w * _final_scale) / 2);
                    _draw_y = _frame_center_y - ((_sprite_h * _final_scale) / 2);
                } 
                // Adjust for custom middle or bottom-centered origins safely
                else {
                    _draw_x = _center_x - (_sprite_w / 2 - _x_offset) * _final_scale;
                    _draw_y = _frame_center_y - (_sprite_h / 2 - _y_offset) * _final_scale;
                }
                
                // Render the database sprite locked inside visual frame bounds
                draw_sprite_ext(_enemy_sprite, 0, _draw_x, _draw_y, _final_scale, _final_scale, 0, c_white, 1.0);
            }
        }
    } 
    // --- 4. DRAW EXCLAMATION MARK IF THE SLOT IS EMPTY ---
    else {
        if (sprite_exists(spr_exclamation_mark)) {
            var _x_offset = sprite_get_xoffset(spr_exclamation_mark);
            var _y_offset = sprite_get_yoffset(spr_exclamation_mark);
            
            var _draw_x = _center_x;
            var _draw_y = _frame_center_y;
            
            if (_x_offset == 0 && _y_offset == 0) {
                _draw_x = _center_x - ((sprite_get_width(spr_exclamation_mark) * 2) / 2);
                _draw_y = _frame_center_y - ((sprite_get_height(spr_exclamation_mark) * 2) / 2);
            } else {
                _draw_x = _center_x - (sprite_get_width(spr_exclamation_mark) / 2 - _x_offset) * 2.0;
                _draw_y = _frame_center_y - (sprite_get_height(spr_exclamation_mark) / 2 - _y_offset) * 2.0;
            }
            
            draw_sprite_ext(spr_exclamation_mark, 0, _draw_x, _draw_y, 2.0, 2.0, 0, c_white, 1.0);
        }
    }
}