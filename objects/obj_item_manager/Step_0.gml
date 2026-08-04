/// @description obj_item_manager -> Step Event

up_key = InputPressed(INPUT_VERB.UP);
down_key = InputPressed(INPUT_VERB.DOWN);
left_key = InputPressed(INPUT_VERB.LEFT);
right_key = InputPressed(INPUT_VERB.RIGHT);
select_key = InputPressed(INPUT_VERB.ACCEPT);
drop_key = InputPressed(INPUT_VERB.CANCEL);

if (inv_open == true)
{
    var lr = right_key - left_key; // Standard direction logic (1 for Right, -1 for Left)
    var ud = down_key - up_key;    // Standard direction logic (1 for Down, -1 for Up)
        
    posx += lr;
    if (ud > 0) posx += rowLength; // Move down 1 row (4 slots)
    if (ud < 0) posx -= rowLength; // Move up 1 row (4 slots)

    // Robust wrapping calculation
    posx = ((posx mod max_inv_length) + max_inv_length) mod max_inv_length;
    
    if (posx < array_length(inv) && posx >= 0)
    {
        selected_item = posx;
        if (select_key)
        {
            startDialogue("Item");
        }
    }
}

inv_full = (array_length(inv) >= max_inv_length);

if (instance_exists(obj_textbox) || instance_exists(obj_menu))
{
    inv_open = false;
}