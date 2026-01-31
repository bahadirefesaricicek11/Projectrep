function item_add(_item)
{
	if array_length(obj_item_manager.inv) <	obj_item_manager.max_inv_length
	{
		array_push(obj_item_manager.inv, _item)	;
	}
}

function item_remove()
{
	if obj_item_manager.inv[obj_item_manager.selected_item].canDrop == true
	{
		array_delete(obj_item_manager.inv, obj_item_manager.selected_item, 1);
	}
}

function item_use()
{
	obj_item_manager.inv[obj_item_manager.selected_item].effect();
}