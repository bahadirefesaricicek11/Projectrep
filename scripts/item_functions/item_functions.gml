/// @desc Safely clones an item struct from global.item_list into the inventory
function item_add(_item)
{
    if (_item == undefined) return;
    
    var _mgr = obj_item_manager;
    if (array_length(_mgr.inv) < _mgr.max_inv_length)
    {
        // Copy struct variables into a fresh instance to avoid mutating the global template
        var _instanced_item = {};
        var _keys = struct_get_names(_item);
        for (var i = 0; i < array_length(_keys); i++) {
            var _k = _keys[i];
            _instanced_item[$ _k] = _item[$ _k];
        }
        
        array_push(_mgr.inv, _instanced_item);
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

function item_use(_target = undefined)
{
    var _mgr = obj_item_manager;
    var _inv = _mgr.inv;
    var _sel = _mgr.selected_item;
    
    if (_sel < 0 || _sel >= array_length(_inv)) return;
    
    var _item = _inv[_sel];
    
    if (_target == undefined) {
        _target = (room == rm_battle) ? 0 : obj_player;
    }
    
    var _execution_success = false;
    
    if (variable_struct_exists(_item, "effect")) 
    {
        if (is_method(_item.effect) || script_exists(_item.effect)) 
        {
            var _bound_effect = method(_mgr, _item.effect);
            _execution_success = _bound_effect(_target, _item);
        }
    }
    
    if (_execution_success) 
    {
        if (variable_struct_exists(_item, "count")) {
            _item.count--;
            if (_item.count <= 0) {
                array_delete(_inv, _sel, 1);
            }
        } else {
            array_delete(_inv, _sel, 1);
        }
        
        var _item_display_name = variable_struct_exists(_item, "name_key") ? __(_item.name_key) : "item";
        show_debug_message("ITEM ENGINE: Successfully consumed: " + string(_item_display_name));
    }
    
    var _current_inv_size = array_length(_inv);
    if (_mgr.posx >= _current_inv_size)
    {
        _mgr.posx = max(0, _current_inv_size - 1);
    }
    
    _mgr.selected_item = (_current_inv_size > 0) ? _mgr.posx : -1;
}

function item_effect_heal(_target, _amount) {
    if (room == rm_battle) {
        if (!is_real(_target) || _target < 0 || !instance_exists(obj_battle_controller)
            || _target >= array_length(obj_battle_controller.party_members)) {
            return false;
        }
        
        var _actor = obj_battle_controller.party_members[_target];
        if (_actor.hp >= _actor.max_hp) return false;
        
        _actor.hp = min(_actor.hp + _amount, _actor.max_hp);
        if (_target == 0) global.player_hp = _actor.hp;
        return true;
    } else {
        if (global.player_hp >= global.player_hp_max) return false;
        global.player_hp = min(global.player_hp + _amount, global.player_hp_max);
        return true;
    }
}

function item_effect_equip(_slot, _item_key, _stat_name, _stat_bonus) {
    var _mgr = obj_item_manager;
    
    if (!variable_instance_exists(_mgr, "equipped") || !is_array(_mgr.equipped)) return false;
    if (_slot < 0 || _slot >= array_length(_mgr.equipped)) return false;
    
    var _previous = _mgr.equipped[_slot];
    if (!is_undefined(_previous) && is_struct(_previous)) {
        var _prev_stat  = variable_struct_exists(_previous, "stat_name")  ? _previous.stat_name  : undefined;
        var _prev_bonus = variable_struct_exists(_previous, "stat_bonus") ? _previous.stat_bonus : 0;
        if (!is_undefined(_prev_stat) && variable_global_exists(_prev_stat)) {
            variable_global_set(_prev_stat, variable_global_get(_prev_stat) - _prev_bonus);
        }
    }
    
    if (!variable_global_exists("item_list") || !variable_struct_exists(global.item_list, _item_key)) {
        show_debug_message("ITEM ENGINE ERROR: '" + string(_item_key) + "' not found in global.item_list.");
        return false;
    }
    
    var _new_item = global.item_list[$ _item_key];
    _new_item.stat_name = _stat_name;
    _new_item.stat_bonus = _stat_bonus;
    _mgr.equipped[_slot] = _new_item;
    
    if (variable_global_exists(_stat_name)) {
        variable_global_set(_stat_name, variable_global_get(_stat_name) + _stat_bonus);
    }
    
    return true;
}

function gold_add(_amount) 
{
    global.player_gold += _amount;
    if (global.player_gold < 0) global.player_gold = 0;
}