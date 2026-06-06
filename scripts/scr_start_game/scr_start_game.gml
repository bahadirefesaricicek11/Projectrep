function scr_send_nameScreen(){
    room_goto(rm_nameScreen);
}

function scr_start_game(){
    global.state = GAME_STATE.PLAYING;
    room_goto(rm_outside);
	obj_player.x = 100;
	obj_player.y = 175;
}