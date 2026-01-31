draw_sprite(battleBackground, 0, x, y);

var _unitWithCurrentTurn = unitRenderOrder[turn].id;
for(var i = 0; i < array_length(unitRenderOrder); i++)
{
	with(unitRenderOrder[i])
	{
		draw_self();
	}
}

draw_sprite_stretched(spr_box,0,x+2,y+154,74,60);

#macro COLUMN_ENEMY 15
#macro COLUMN_NAME 100

var _drawLimit = 3;
var _drawn = 0;
for (var i = 0; (i < array_length(enemyUnits)) && (_drawn < _drawLimit); i++)
{
	var _char = enemyUnits[i];
	if (_char.hp > 0)
	{
		_drawn++;
		draw_set_halign(fa_left);
		draw_set_colour(c_white)
		if(_char.id == _unitWithCurrentTurn) draw_set_colour(c_yellow);
		draw_text(x+COLUMN_ENEMY,y+165+(i*12),_char.name)
	}
}

for(var i = 0; i < array_length(partyUnits); i++)
{
	draw_set_halign(fa_left);
	draw_sprite_stretched(spr_box,0,x+(i*70)+92,y+154,55,60);
	draw_set_colour(c_white);
	var _char = partyUnits[i];
	if(_char.id == _unitWithCurrentTurn) draw_set_colour(c_yellow);
	if(_char.hp <=0) draw_set_colour(c_red);
	draw_text(x+COLUMN_NAME+(i*70)+10,y+165, _char.name);
	
	draw_set_colour(c_white);
	if(_char.hp < (_char.hpMax * 0.5)) draw_set_colour(c_orange);
	if(_char.hp <=0) draw_set_colour(c_red);
	draw_text(x+COLUMN_NAME+(i*70)+7,y+175,string(_char.hp) + "/" + string(_char.hpMax));
	
	draw_set_colour(c_white)
}

draw_set_font(global.font_small);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_gray);
draw_text(x+COLUMN_ENEMY,y+157,"ENEMY");
draw_text(x+COLUMN_NAME,y+157,"PLAYER 1");
draw_text(x+COLUMN_NAME+70,y+157,"PLAYER 2");
draw_text(x+COLUMN_NAME+140,y+157,"PLAYER 3");
draw_set_colour(c_white)