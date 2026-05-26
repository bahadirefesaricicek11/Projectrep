var _camx = camera_get_view_x(view_camera[0]);
var _camy = camera_get_view_y(view_camera[0]);

var _p = 0.5;

if (room == rm_outside)
{
	draw_sprite_tiled(bg_sky, 0, _camx * _p,_camy * _p);

	draw_sprite_tiled(bg_sky, 1, _camx * 0.25,_camy * 0.25);
}
else if (room == rm_outside_3)
{
	draw_sprite_tiled(bg_forest_new, 1, _camx * _p, _camy * _p);
	draw_sprite_tiled(bg_forest_new, 2, _camx * 0.40, _camy * 0.40);
	draw_sprite_tiled(bg_forest_new, 3, _camx * 0.35, _camy * 0.35);
	draw_sprite_tiled(bg_forest_new, 4, _camx * 0.30, _camy * 0.30);
	draw_sprite_tiled(bg_forest_new, 5, _camx * 0.25, _camy * 0.25);
}
