start = InputCheck(INPUT_VERB.ACCEPT);

if start
{
	scr_text();
	room_goto(rm_menuRoom);
	show_debug_message("room changed");
}
