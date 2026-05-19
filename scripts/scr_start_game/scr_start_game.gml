function scr_send_nameScreen(){
    room_goto(rm_nameScreen);
}

function scr_start_game(){
    global.ingame = true;
    room_goto(rm_outside); // Güvenli oda geçişi
}