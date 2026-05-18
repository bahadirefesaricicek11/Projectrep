function scr_send_nameScreen(){
	room_goto(rm_nameScreen);
}

function scr_start_game(){
	room_goto(rm_outside)
	obj_player.x = 90;
	obj_player.y = 150;
	obj_player.can_move = true;
	global.ingame = true;
	scr_text();
}