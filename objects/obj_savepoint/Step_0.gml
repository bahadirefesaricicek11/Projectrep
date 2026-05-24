
alpha_counter = clamp(alpha_counter, 0,1);
dstnc = distance_to_object(obj_player)

var plr_face = 0;

if file_exists("save.ini")
{
	ini_open("save.ini");
	
	plyr_face = ini_read_real("SAVE", "player_face", 0);
	ini_close();
}

if plyr_face = 0{
	plr_face = 1;
} else if plyr_face = 1{
	plr_face = 2;
} else if plyr_face = 2{
	plr_face = 3;
} else if plyr_face = 3{
	plr_face = 4;
} else {
	plr_face = 0;
}

if dstnc < 15 
{
	alpha_counter -= 0.1;
	image_index = plr_face;
} else {
	alpha_counter = 1;
	image_index = 0;
}


if dstnc < 2 and obj_player.can_move && (InputPressed(INPUT_VERB.ACCEPT)) 
{
	startDialogue("Save 1");
	obj_player.image_speed = 0;
}
