alpha = dsin(alpha_amt);
alpha_amt += 5;

if (InputPressedMany(-1) || keyboard_check_pressed(vk_anykey) && !mouse_check_button_pressed(mb_any) == true)
{
	room_goto(rm_introCutscene);
}