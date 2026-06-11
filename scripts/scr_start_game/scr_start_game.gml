function scr_send_nameScreen(){
    room_goto(rm_nameScreen);
}

function scr_start_game(){
    global.state = GAME_STATE.PLAYING;
    room_goto(rm_forest_1);
	obj_player.x = 255;
	obj_player.y = 180;
}