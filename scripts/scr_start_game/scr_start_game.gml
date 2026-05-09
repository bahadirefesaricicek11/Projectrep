function scr_send_nameScreen(){
	room_goto(rm_nameScreen);
}

function scr_start_game(){
	room_goto(rm_house)
	obj_player.x = 210;
	obj_player.y = 130;
	obj_player.can_move = true;
	global.ingame = true;
	scr_text();
}