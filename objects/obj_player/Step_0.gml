// --- 1. INPUT FETCHING ---
up_key        = InputCheck(INPUT_VERB.UP);
left_key      = InputCheck(INPUT_VERB.LEFT);
down_key      = InputCheck(INPUT_VERB.DOWN);
right_key     = InputCheck(INPUT_VERB.RIGHT);
run_key       = InputCheck(INPUT_VERB.CANCEL);
inventory_key = InputPressed(INPUT_VERB.INVENTORY);
menu_key      = InputPressed(INPUT_VERB.PAUSE);

// --- 2. STATE INTERACTION GATE ---
// Force freeze player if they are in standard menu states, but allow freedom if in gameover room
if (global.state != GAME_STATE.PLAYING && room != rm_gameOver) {
    image_speed = 0;
    exit;
}

// --- 3. EXPLICIT INTERFACE LOCKS ---
// Completely disable menu and inventory options if player has lost
if (room == rm_gameOver) {
    obj_player.can_open_menu = false;
    obj_player.can_open_inventory = false;
} else {
    // Restore capabilities during normal overworld exploration
    obj_player.can_open_menu = true;
    obj_player.can_open_inventory = true;
}

if obj_player.can_move == true
{
    if (run_key) {
        image_speed = 0.2;
        spd = run_spd;
    } else {
        spd = walk_spd;
        image_speed = 2;
    }
    
    if xspd == 0 && yspd == 0 || can_move == false {
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

if (menu_key == true && obj_player.can_open_menu == true) {
    // If the menu was just closed this frame, consume the cooldown and do nothing
    if (obj_player.menu_cooldown) {
        obj_player.menu_cooldown = false;
    } 
    // Otherwise, open the menu safely
    else if (global.state == GAME_STATE.PLAYING) {
        instance_create_layer(x, y, "Instances", obj_menu);
        show_debug_message("menu created-----");
        global.state = GAME_STATE.MENU;
    }
}

// Reset the cooldown if the button wasn't pressed, keeping it clean
if (menu_key == false) {
    obj_player.menu_cooldown = false;
}

if instance_exists(obj_textbox) {
    obj_player.can_move = false
}

if (instance_exists(obj_menu) == false)
{
	if (inventory_key == true) && (obj_item_manager.inv_open == false) && (obj_player.can_move == true) && (obj_player.can_open_inventory == true){
	    obj_item_manager.inv_open = true;
	    obj_player.can_move = false;
	} 
	else if (inventory_key == true) && (obj_item_manager.inv_open == true){
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



/// @description Bottom of obj_player Step Event

// Record history entry when moving
if (x != xprevious || y != yprevious) {
    var _pos = {
        x: x,
        y: y,
        sprite: sprite_index,
        img_idx: image_index
    };
    ds_list_insert(pos_history, 0, _pos);
}

// Keep the size capped safely to support both followers without truncation leaks
var _max_history_needed = (array_length(party_allies) + 2) * 25;
while (ds_list_size(pos_history) > _max_history_needed) {
    ds_list_delete(pos_history, ds_list_size(pos_history) - 1);
}

depth = -bbox_bottom;