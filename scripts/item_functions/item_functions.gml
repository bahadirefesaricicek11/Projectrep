function item_add(_item)
{
	
    if (_item == undefined) return;
    
    if (array_length(obj_item_manager.inv) < obj_item_manager.max_inv_length)
    {
        array_push(obj_item_manager.inv, _item);
    }
}
function item_remove()
{
    var _inv = obj_item_manager.inv;
    var _sel = obj_item_manager.selected_item;
    
    if (_sel >= 0 && _sel < array_length(_inv))
    {
        if (_inv[_sel].canDrop == true)
        {
            array_delete(_inv, _sel, 1);
            
            if (obj_item_manager.posx >= array_length(_inv))
            {
                obj_item_manager.posx = max(0, array_length(_inv) - 1);
                obj_item_manager.selected_item = obj_item_manager.posx;
            }
        }
    }
}
/// @desc Completely Modularized Item Consumable Core Engine
function item_use(_target = undefined)
{
    var _mgr = obj_item_manager;
    var _inv = _mgr.inv;
    var _sel = _mgr.selected_item;
    
    // Bounds check protection pipeline
    if (_sel < 0 || _sel >= array_length(_inv)) return;
    
    var _item = _inv[_sel];
    
    // --- 1. DYNAMIC CONTEXT EVALUATION ---
    // If no target was explicitly provided, default context straight to the main player profile
    if (_target == undefined) {
        _target = (room == rm_battle) ? 0 : obj_player; // Index 0 in combat, player instance in overworld
    }
    
    // --- 2. EXECUTE DATA-BOUND STRUCT SCRIPT METRIC ---
    var _execution_success = false;
    
    if (variable_struct_exists(_item, "effect")) 
    {
        if (is_method(_item.effect) || script_exists(_item.effect)) 
        {
            // Bind the method context wrapper to the item manager execution scope
            var _bound_effect = method(_mgr, _item.effect);
            
            // The item script must return 'true' if the item was successfully used, or 'false' if invalid (e.g. healing a full HP target)
            _execution_success = _bound_effect(_target, _item);
        }
    }
    
    // --- 3. PERSISTENT INVENTORY DEPLETION CLEANUP ---
    if (_execution_success) 
    {
        if (variable_struct_exists(_item, "count")) {
            _item.count--;
            if (_item.count <= 0) {
                array_delete(_inv, _sel, 1);
            }
        } else {
            // Fallback tracking if inventory layout handles duplication stacks as individual unique array entries
            array_delete(_inv, _sel, 1);
        }
        // FIX: items don't have a .name field, only .name_key (a localization key) —
        // same root cause as the earlier "Unknown Item" bug in the battle inventory
        // list. __() resolves it to the actual display string.
        var _item_display_name = variable_struct_exists(_item, "name_key") ? __(_item.name_key) : "item";
        show_debug_message("ITEM ENGINE: Successfully consumed asset instance reference: " + string(_item_display_name));
    }
    
    // --- 4. CURSOR REPOSITION SAFETY BOUNDS ---
    var _current_inv_size = array_length(_inv);
    if (_mgr.posx >= _current_inv_size)
    {
        _mgr.posx = max(0, _current_inv_size - 1);
    }
    
    // Lock updated structural handles down safely
    _mgr.selected_item = (_current_inv_size > 0) ? _mgr.posx : -1;
}

/// @desc Heals _target by _amount. Returns true if it actually healed anything (so
/// item_use knows to consume the item), false if the target was already at full HP
/// (so the item stays in the inventory unused). This was missing entirely — every
/// call to it from scr_item_database was throwing "not set before reading it" since
/// GameMaker didn't recognize it as a function at all.
/// @param {Real|Id.Instance} _target  Battle: party_members index (0 = player). Overworld: obj_player instance (unused directly, healing applies to global.player_hp).
/// @param {Real} _amount
function item_effect_heal(_target, _amount) {
    if (room == rm_battle) {
        // _target is a party_members index (0 = player, 1+ = allies)
        if (!is_real(_target) || _target < 0 || !instance_exists(obj_battle_controller)
            || _target >= array_length(obj_battle_controller.party_members)) {
            return false;
        }
        
        var _actor = obj_battle_controller.party_members[_target];
        if (_actor.hp >= _actor.max_hp) return false; // already full — item not consumed
        
        _actor.hp = min(_actor.hp + _amount, _actor.max_hp);
        if (_target == 0) global.player_hp = _actor.hp; // keep the overworld tracker in sync for the player
        return true;
    } else {
        // Overworld: heals straight against the global player HP trackers
        if (global.player_hp >= global.player_hp_max) return false;
        global.player_hp = min(global.player_hp + _amount, global.player_hp_max);
        return true;
    }
}

/// @desc Equips an item into the given equipment slot and applies its stat bonus,
/// removing whatever was previously equipped there first (and ITS bonus) so
/// re-equipping repeatedly can't stack the same bonus over and over. This was
/// missing entirely, same as item_effect_heal above. Always returns true —
/// equipping doesn't have a "fail" case the way healing does.
/// @param {Real} _slot        Index into obj_item_manager.equipped
/// @param {String} _item_key  Key into global.item_list for the item being equipped
/// @param {String} _stat_name Name of the global stat variable to modify (e.g. "player_defense")
/// @param {Real} _stat_bonus  Amount to add to that stat
function item_effect_equip(_slot, _item_key, _stat_name, _stat_bonus) {
    var _mgr = obj_item_manager;
    
    if (!variable_instance_exists(_mgr, "equipped") || !is_array(_mgr.equipped)) return false;
    if (_slot < 0 || _slot >= array_length(_mgr.equipped)) return false;
    
    // Remove the previous item's bonus in this slot first, if there was one
    var _previous = _mgr.equipped[_slot];
    if (!is_undefined(_previous) && is_struct(_previous)) {
        var _prev_stat  = variable_struct_exists(_previous, "stat_name")  ? _previous.stat_name  : undefined;
        var _prev_bonus = variable_struct_exists(_previous, "stat_bonus") ? _previous.stat_bonus : 0;
        if (!is_undefined(_prev_stat) && variable_global_exists(_prev_stat)) {
            variable_global_set(_prev_stat, variable_global_get(_prev_stat) - _prev_bonus);
        }
    }
    
    // Equip the new item and apply its bonus
    if (!variable_global_exists("item_list") || !variable_struct_exists(global.item_list, _item_key)) {
        show_debug_message("ITEM ENGINE ERROR: '" + string(_item_key) + "' not found in global.item_list.");
        return false;
    }
    
    var _new_item = global.item_list[$ _item_key];
    // Stashed on the item itself so item_effect_equip can find and reverse it later
    // when something else gets equipped into this same slot.
    _new_item.stat_name = _stat_name;
    _new_item.stat_bonus = _stat_bonus;
    _mgr.equipped[_slot] = _new_item;
    
    if (variable_global_exists(_stat_name)) {
        variable_global_set(_stat_name, variable_global_get(_stat_name) + _stat_bonus);
    } else {
        show_debug_message("ITEM ENGINE WARNING: global." + string(_stat_name) + " doesn't exist — equip bonus not applied.");
    }
    
    return true;
}

function gold_add(_amount) 
{
    global.player_gold += _amount;
    if (global.player_gold < 0) global.player_gold = 0;
}
