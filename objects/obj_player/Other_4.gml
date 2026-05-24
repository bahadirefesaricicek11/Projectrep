
if (room == rm_outside) {
    can_move = true;
}

if (room == rm_init or room == rm_splash or room == rm_menuRoom or room == rm_nameScreen or room == rm_introCutscene)
{
	x = -50;
	y = -50;
	can_move = false;
	can_open_menu = false;
}
else {
	can_open_menu = true;
}