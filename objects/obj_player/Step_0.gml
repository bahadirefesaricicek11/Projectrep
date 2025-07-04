up_key = keyboard_check(ord("W"));
left_key = keyboard_check(ord("A"));
down_key = keyboard_check(ord("S"));
right_key = keyboard_check(ord("D"));
run_key = keyboard_check_pressed(vk_shift);

xspd = (right_key - left_key) * walk_spd;
yspd = (down_key - up_key) * walk_spd;

if place_meeting(x+xspd, y, obj_wall)
{
	xspd = 0;
}
if place_meeting(x ,y+yspd, obj_wall)
{
	yspd = 0;
}

if xspd > 0 {
	sprite_index = spr_player_right;
} else if xspd < 0 {
	sprite_index = spr_player_left;
} else if yspd < 0 {
	sprite_index = spr_player_down;
} else if yspd < 0 {
	sprite_index = spr_player_up;
}


x += xspd;
y += yspd;

