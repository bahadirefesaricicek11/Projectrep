depth = -9999;

inv_open = false;

textfont = font_add("Project_Font_Better.ttf",24,false,false,32,128);
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

function create_item(_name, _desc, _price, _ico, _effect, _rarity, _itemType, _canDrop) constructor
	{
		name = _name;
		description = _desc;
		price = _price;
		icon = _ico;
		effect = _effect;
		rarity = _rarity;
		itemType = _itemType;
		canDrop = _canDrop
	}
	
inv = array_create(0);
inv_length = max_inv_length;
inv_full = false;

// Simple equipment system
equipped = [undefined, undefined, undefined, undefined, undefined];


selected_option = 0;

		

global.item_list = {
	
	apple : new create_item(
		"Apple",
		"recovers 10 HP.",
		10,
		spr_apple,
		function ()
		{
				global.player_hp += 10;
				array_delete(inv,selected_item,1);
		},
		"common",
		"Misc",
		true
	),
	bread : new create_item(
		"Bread",
		"recovers 5 HP.",
		5,
		spr_bread,
		function ()
		{
				global.player_hp += 5;
				array_delete(inv,selected_item,1);
		},
		"rare",
		"Misc",
		true
	),
	hamburger : new create_item(
		"Hamburger",
		"recovers 25 HP.",
		35,
		spr_hamburger,
		function ()
		{
				global.player_hp += 25;
				array_delete(inv,selected_item,1);
		},
		"epic",
		"Misc",
		true
	),
	iron_helmet : new create_item(
		"Iron Helmet",
		"+5 Armor Density.",
		100,
		spr_iron_helmet,
		function ()
		{
			equipped[0] = global.item_list.iron_helmet;
			global.player_defense += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Head",
		true
	),
	iron_chestplate : new create_item(
		"Iron Chestplate",
		"+10 Armor Density.",
		100,
		spr_iron_chestplate,
		function ()
		{
			equipped[1] = global.item_list.iron_chestplate;
			global.player_defense += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Chest",
		true
	),
	iron_bottom : new create_item(
		"Iron Bottom",
		"+5 Armor Density.",
		100,
		spr_iron_bottom,
		function ()
		{
			equipped[2] = global.item_list.iron_bottom;
			global.player_defense += 10;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Armor_Bottom",
		true
	),
	normal_shield : new create_item(
		"Normal Shield",
		"+5 Armor Density.",
		100,
		spr_normal_shield,
		function ()
		{
			equipped[3] = global.item_list.normal_shield;
			global.player_defense += 5;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Shield",
		true
	),
	iron_sword : new create_item(
		"Iron Sword",
		"+5 Strength.",
		100,
		spr_iron_sword,
		function ()
		{
			equipped[4] = global.item_list.iron_sword;
			global.player_attack += 5;
			array_delete(inv, selected_item, 1);
		},
		"rare",
		"Weapon",
		true
	),
}

