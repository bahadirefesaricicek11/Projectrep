if (obj_item_manager.inv_open == true)
{
    draw_set_font(textfont);
    draw_set_valign(fa_top);
    
    common_color = make_color_rgb(51, 204, 255);
    rare_color = make_color_rgb(255, 204, 0);
    epic_color = make_color_rgb(153, 0, 153);

    var _xx = _x;
    var _yy = _y;
    var _sep = sep;
    var _sepx = sepx;
    
    // 1. Fetch the localized sprite name string ("spr_inventory_eng" or "spr_inventory_tr")
    var _localized_sprite_string = __("inventory.background");

    // 2. Convert that string value directly into a real asset integer pointer index
    var background_sprite = asset_get_index(_localized_sprite_string);

    // 3. Safety validation check layer
    if (background_sprite == -1 || !sprite_exists(background_sprite)) {
        background_sprite = spr_inventory_eng; 
    } 

    // 4. Clean render execution step centered perfectly at 384x216 bounds layout
    draw_sprite(background_sprite, 0, 192, 108);
    
    draw_set_halign(fa_center);

    var player_name = string(global.player_name);
    var max_width = 38; 
    var max_scale = 0.19; 

    var full_width = string_width(player_name); 
    var target_scale = max_width / full_width;
    var final_scale = min(max_scale, target_scale);

    // Scaled text coordinates
    draw_text_ext_transformed(123, 31, player_name, 0, 38, final_scale, final_scale, 0);

    draw_set_halign(fa_left);
    draw_text_transformed(103, 42, __("inventory.strength_info") + string(global.player_attack), 0.15, 0.15, 0);
    draw_text_transformed(103, 50, __("inventory.defense_info") + string(global.player_defense), 0.15, 0.15, 0);
    
    // --- PARTY MEMBERS BELOW STATS ---
    // Reads from obj_player.party_allies (the actual shared party-tracking array —
    // the same one Room Start rebuilds followers from and the battle setup builds the
    // fighting party from), resolved through ally_database_lookup() so it matches
    // regardless of how each ally's name was capitalized ("Bob"/"bob"/"BOB" all work).
    // Replaces the old global.encounter_allies / global.ally_db pair, which were a
    // separate, disconnected system from the one everything else now uses.
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "party_allies") && is_array(obj_player.party_allies))
    {
        var _party_draw_y = 148; // Starts 12 pixels below Defense stat
        var _line_height = 8;   // Matches the vertical spacing of your stats
        var _ally_display_count = 0;
        
        var _ally_count = array_length(obj_player.party_allies);
        for (var p = 0; p < _ally_count; p++)
        {
            var _ally_entry = obj_player.party_allies[p];
            
            // party_allies normally holds plain name strings, but tolerate a raw
            // struct too (same leniency the battle setup already has)
            var _lookup_name = is_string(_ally_entry) ? _ally_entry
                : (is_struct(_ally_entry) && variable_struct_exists(_ally_entry, "name") ? _ally_entry.name : undefined);
            
            var _db_data = ally_database_lookup(_lookup_name);
            var _ally_name = !is_undefined(_db_data) ? _db_data.name : (is_undefined(_lookup_name) ? "Ally" : string(_lookup_name));
            
            // Draw companion text matching your stat layout font-scale
            draw_text_transformed(103, _party_draw_y + (_ally_display_count * _line_height), "- " + string(_ally_name), 0.15, 0.15, 0);
            _ally_display_count++;
        }
    }
    // -------------------------------------------
    
    var statscale = 0.19; 
    
    var health_x = 10;
    var _htxt = (string(global.player_hp));
    var _hw = (string_width(_htxt) + 130) * statscale;
    
    draw_sprite_stretched(spr_stats, 0, health_x - 2, 6, _hw, 22);
    draw_sprite(spr_health, 0, health_x+1, 9);
    draw_text_transformed(health_x + 18, 12, _htxt, statscale, statscale, 0);
    
    var gold_x = 48;
    var _gtxt = (string(global.player_gold));
    var _gw = (string_width(_gtxt) + 130) * statscale;
    
    draw_sprite_stretched(spr_stats, 0, gold_x - 2, 6, _gw, 22);
    draw_sprite(spr_gold_stack, 0, gold_x+1, 9);
    draw_text_transformed(gold_x + 18, 12, _gtxt, statscale, statscale, 0);

    // Inventory Grid loop coordinates updated to scale
    for (var i = 0; i < max_inv_length; i++)
    {
        var xx = 13 + (_xx * 0.78) + (i mod rowLength) * 20;
        var yy = -1 + (_yy * 0.56) + (i div rowLength) * 20;
        draw_sprite(spr_inventory_slot, 0, xx, yy);
    }
    
    var _current_inv_qty = array_length(inv);
    for (var i = 0; i < _current_inv_qty; i++)
    {
        var xx = 14 + (_xx * 0.78) + (i mod rowLength) * 20;
        var yy = (_yy * 0.56) + (i div rowLength) * 20;
        draw_sprite(inv[i].icon, 0, xx, yy);
    }

    // Equipment Slots natively mapped to 384x216 screen space
    draw_sprite(spr_helmet_slot, 0, 268, 32);
    draw_sprite(spr_chestplate_slot, 0, 268, 51);
    draw_sprite(spr_bottom_slot, 0, 268, 70);
    
    draw_sprite(spr_shield_slot, 0, 268, 152);
    draw_sprite(spr_weapon_slot, 0, 268, 171);
    
    if (equipped[0] != undefined) draw_sprite(equipped[0].icon, 0, 268, 32);
    if (equipped[1] != undefined) draw_sprite(equipped[1].icon, 0, 268, 51);
    if (equipped[2] != undefined) draw_sprite(equipped[2].icon, 0, 268, 70);
    if (equipped[3] != undefined) draw_sprite(equipped[3].icon, 0, 268, 152);
    if (equipped[4] != undefined) draw_sprite(equipped[4].icon, 0, 268, 171);
    
    // --- FIXED HOVER INSPECTION RENDERING LAYER ---
    for (var i = 0; i < max_inv_length; i++)
    {
        if (posx == i)
        {
            var xx = 13 + (_xx * 0.78) + (i mod rowLength) * 20;
            var yy = -1 + (_yy * 0.56) + (i div rowLength) * 20;
            draw_sprite(spr_inventory_hover, 0, xx + 1, yy + 1);
            
            // Only process drawing text data if the cursor is actually hovering over a populated item slot!
            if (posx < _current_inv_qty)
            {
                var _inspect_item = inv[posx];
                var _c = c_white;
                
                // CRITICAL FIX: Safe index reference checks
                if (_inspect_item.rarity == "common")       { _c = common_color; }
                else if (_inspect_item.rarity == "rare")    { _c = rare_color; }
                else if (_inspect_item.rarity == "epic")    { _c = epic_color; }
                
                font_enable_effects(textfont, true, {
                    outlineEnable: true,
                    outlineColour: c_black,
                    // Thickness profile compatibility check
                    outlineThickness: 1 
                });
                
                // CRITICAL FIX: Dynamic on-the-fly translation lookups via localized structural keys
                var _localized_name = __(_inspect_item.name_key);
                var _localized_desc = __(_inspect_item.description_key);
                
                draw_text_transformed_colour((name_x + 3) * 0.7695, name_y * 0.7714, _localized_name, 0.38, 0.38, 0, _c, _c, _c, _c, 1);
                draw_text_transformed(info_x * 0.7695, info_y * 0.7714, _localized_desc, 0.19, 0.19, 0);
                font_enable_effects(textfont, false);
            }
            break; // Break loop early since we found the single active cursor index position
        }
    }
}
