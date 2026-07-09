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
        show_debug_message("ITEM ENGINE: Successfully consumed asset instance reference: " + string(_item.name));
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
function gold_add(_amount) 
{
    global.player_gold += _amount;
    if (global.player_gold < 0) global.player_gold = 0;
}