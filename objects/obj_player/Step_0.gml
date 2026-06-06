up_key = InputCheck(INPUT_VERB.UP);
left_key = InputCheck(INPUT_VERB.LEFT);
down_key = InputCheck(INPUT_VERB.DOWN);
right_key = InputCheck(INPUT_VERB.RIGHT);
run_key = InputCheck(INPUT_VERB.CANCEL);
inventory_key = InputPressed(INPUT_VERB.INVENTORY);
menu_key = InputPressed(INPUT_VERB.PAUSE);

if obj_player.can_move == true
{
    if (run_key) {
        image_speed = 0.2;
        spd = run_spd;
    } else {
        spd = walk_spd;
        image_speed = 2;
    }
    
    if xspd == 0 and yspd == 0 or can_move == false {
        image_speed = 0;
        image_index = 0;
    } else {
        image_speed = 2;
    }
    
    xspd = (right_key - left_key) * spd;
    yspd = (down_key -  up_key) * spd;

    if (xspd != 0) 
    {
        if (place_meeting(x + xspd, y, obj_solid)) 
        {
            var climbed = false;
            var slope_height = spd + 2; 
            
            for (var i = 1; i <= slope_height; i++) 
            {
                if (!place_meeting(x + xspd, y - i, obj_solid)) 
                {
                    y -= i;
                    climbed = true;
                    break;
                }
                if (!place_meeting(x + xspd, y + i, obj_solid)) 
                {
                    y += i;
                    climbed = true;
                    break;
                }
            }
            
            if (!climbed) 
            {
                while (!place_meeting(x + sign(xspd), y, obj_solid)) {
                    x += sign(xspd);
                }
                xspd = 0;
            }
        }
    }

    if (yspd != 0)
    {
        if (place_meeting(x, y + yspd, obj_solid))
        {
            var descended = false;
            var slope_width = spd + 2;

            for (var i = 1; i <= slope_width; i++)
            {
                if (!place_meeting(x - i, y + yspd, obj_solid))
                {
                    x -= i;
                    descended = true;
                    break;
                }
                if (!place_meeting(x + i, y + yspd, obj_solid))
                {
                    x += i;
                    descended = true;
                    break;
                }
            }
			
            if (!descended)
            {
                while (!place_meeting(x, y + sign(yspd), obj_solid))
                {
                    y += sign(yspd);
                }
                yspd = 0;
            }
        }
    }

    mask_index = sprite[FACE_DOWN];
    if yspd == 0 {
        if xspd > 0 {face = FACE_RIGHT};
        if xspd < 0 {face = FACE_LEFT};
    }
    if xspd == 0 {
        if yspd > 0 {face = FACE_DOWN};
        if yspd < 0 {face = FACE_UP};
    }

    sprite_index = sprite[face];

    x += xspd;
    y += yspd;
} else {
    image_speed = 0;
    image_index = 0;
}

if (menu_key) {
    if (global.state == GAME_STATE.PLAYING) {
        instance_create_layer(x, y, "Instances", obj_menu);
        global.state = GAME_STATE.MENU;
    }
    else if (global.state == GAME_STATE.MENU) {
        if (instance_exists(obj_menu) && obj_menu.is_ingame) {
            instance_destroy(obj_menu);
        }
    }
}

if instance_exists(obj_textbox) {
    obj_player.can_move = false
}

if (instance_exists(obj_menu) == false)
{
	if (inventory_key == true) and (obj_item_manager.inv_open == false) and obj_player.can_move == true{
	    obj_item_manager.inv_open = true;
	    obj_player.can_move = false;
	} 
	else if (inventory_key == true) and (obj_item_manager.inv_open == true){
	    obj_item_manager.inv_open = false;
	    obj_player.can_move = true;
	}
}

if (global.player_hp > 100)
{
    global.player_hp = 100;
}
if (global.player_gold > 99999)
{
    global.player_gold = 99999;
}




depth = -bbox_bottom;