depth = -9999;

inv_open = false;

textfont = font_add("Project_Font.ttf",24,false,false,32,128);
font_enable_sdf(textfont, true)

name_x = 16;
name_y = 230;
info_x = 394;
info_y = 16;


sep = 20;
sepx = 18;
_x = 192;
_y = 59;
rowLength = 4;

max_inv_length = 32;
max_equipped_length = 5;

selected_item = -1;

posx = 0;

function create_item(_name, _desc, _ico, _effect, _rarity, _itemType, _canDrop) constructor
	{
		name = _name;
		description = _desc;
		icon = _ico;
		effect = _effect;
		rarity = _rarity;
		itemType = _itemType;
		canDrop = _canDrop
	}
	
inv = array_create(0);
inv_length = max_inv_length;

// Simple equipment system
equipped = [undefined, undefined, undefined, undefined, undefined];


selected_option = 0;

		

global.item_list = {
	
	apple : new create_item(
		"Apple",
		"recovers 10 HP.",
		spr_apple,
		function ()
		{
				obj_player.hp += 10;
				array_delete(inv,selected_item,1);
		},
		"common",
		"Misc",
		true
	),
	bread : new create_item(
		"Bread",
		"recovers 5 HP.",
		spr_bread,
		function ()
		{
				obj_player.hp += 5;
				array_delete(inv,selected_item,1);
		},
		"rare",
		"Misc",
		true
	),
	hamburger : new create_item(
		"Hamburger",
		"recovers 25 HP.",
		spr_hamburger,
		function ()
		{
				obj_player.hp += 25;
				array_delete(inv,selected_item,1);
		},
		"epic",
		"Misc",
		true
	),
	iron_helmet : new create_item(
		"Iron Helmet",
		"+5 Armor Density.",
		spr_iron_helmet,
		function ()
		{
			equipped[0] = global.item_list.iron_helmet;
			obj_player.armor_density += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Head",
		true
	),
	iron_chestplate : new create_item(
		"Iron Chestplate",
		"+10 Armor Density.",
		spr_iron_chestplate,
		function ()
		{
			equipped[1] = global.item_list.iron_chestplate;
			obj_player.armor_density += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Chest",
		true
	),
	iron_bottom : new create_item(
		"Iron Bottom",
		"+5 Armor Density.",
		spr_iron_bottom,
		function ()
		{
			equipped[2] = global.item_list.iron_bottom;
			obj_player.armor_density += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Bottom",
		true
	),
	normal_shield : new create_item(
		"Normal Shield",
		"+5 Armor Density.",
		spr_normal_shield,
		function ()
		{
			equipped[3] = global.item_list.normal_shield;
			obj_player.armor_density += 5;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Shield",
		true
	),
	iron_sword : new create_item(
		"Iron Sword",
		"+5 Strength.",
		spr_iron_sword,
		function ()
		{
			equipped[4] = global.item_list.iron_sword;
			obj_player.strength += 5;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Weapon",
		true
	),
}

