up_key = InputPressed(INPUT_VERB.UP);
down_key = InputPressed(INPUT_VERB.DOWN);
left_key = InputPressed(INPUT_VERB.RIGHT);
right_key = InputPressed(INPUT_VERB.LEFT);
select_key = InputPressed(INPUT_VERB.ACCEPT);
drop_key = InputPressed(INPUT_VERB.CANCEL);


if obj_item_manager.inv_open == true
{
	var lr = left_key-right_key;
	var ud = up_key-down_key;
		
	posx += lr;
	if posx >= inv_length {posx = 0};
	if posx < 0 {posx = inv_length-1};
	if ud > 0 {posx -= 4};
	if ud < 0 {posx += 4};
	
	if (posx < array_length(inv) and posx >= 0)
	{
	    selected_item = posx;
    
	    if select_key
	    {
			startDialogue("Item");
	    }
	}
}

if instance_exists(obj_textbox)
{
	inv_open = false;
}

