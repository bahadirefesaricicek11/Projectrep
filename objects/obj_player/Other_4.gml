if (room == rm_outside || room == rm_forest_1 || room == rm_outside_3) {
    can_move = true;
}
if (room == rm_shop)
{
	can_open_menu = false;
}


if (room == rm_init || room == rm_splash || room == rm_menuRoom || room == rm_nameScreen || room == rm_introCutscene)
{
	x = -50;
	y = -50;
	can_move = false;
	can_open_menu = false;
}
else {
	can_open_menu = true;
}