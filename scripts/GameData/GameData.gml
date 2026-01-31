global.actionLibrary = 
{
	attack:
	{
		name:"Attack",
		description: "{0} attacks!",
		subMenu: -1,
		targetRequired: true,
		targetEnemyByDefault: true,
		targetAll: MODE.NEVER,
		userAnimation:"attack",
		effectSprite: spr_attack_bonk,
		effectOnTarget: MODE.ALWAYS,
		func : function(_user, _targets)
		{
			var _damage = ceil(_user.strength + random_range(-_user.strength * 0.25, _user.strength * 0.25));
			BattleChangeHP(_targets[0], -_damage, 0);
		}
	},
	ice :
	{
		name : "Ice",
		description : "{0} casts Ice!",
		subMenu : "Magic",
		mpCost : 4,
		targetRequired : true,
		targetEnemyByDefault : true, //0: party/self, 1: enemy
		targetAll : MODE.VARIES,
		userAnimation : "ice",
		effectSprite : spr_attack_bonk,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets) {
			//var _damage = irandom_range(10,15);
			//BattleChangeHP(_targets[0], -_damage, 0);
			for (var i = 0; i < array_length(_targets); i++) {
				var _damage = irandom_range(15,20);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			
			
			//BattleChangeMP(_user, -mpCost)
		}
	},
	fire :
	{
		name : "Fire",
		description : "{0} casts Fire!",
		subMenu : "Magic",
		mpCost : 4,
		targetRequired : true,
		targetEnemyByDefault : true, //0: party/self, 1: enemy
		targetAll : MODE.VARIES,
		userAnimation : "fire",
		effectSprite : spr_attack_bonk,
		effectOnTarget : MODE.ALWAYS,
		func : function(_user, _targets) {
			//var _damage = irandom_range(10,15);
			//BattleChangeHP(_targets[0], -_damage, 0);
			for (var i = 0; i < array_length(_targets); i++) {
				var _damage = irandom_range(13,22);
				if (array_length(_targets) > 1) _damage = ceil(_damage*0.75);
				BattleChangeHP(_targets[i], -_damage);
			}
			
			
			//BattleChangeMP(_user, -mpCost)
		}
	},
}
enum MODE
{
	NEVER = 0,
	ALWAYS = 0,
	VARIES = 0,
}


global.party =
[
	{
		name: "Liah",
		hp: 100,
		hpMax: 100,
		strength: 5,
		sprites: { idle: spr_player_battle_idle, down: spr_player_battle_down, attack: spr_player_battle_attack},
		actions: [global.actionLibrary.attack, global.actionLibrary.ice]
	},
	
	{
		name:"NPC1",
		hp: 50,
		hpMax: 50,
		strength: 2,
		sprites: { idle: spr_npc, attack: spr_npc, down: spr_npc},
		actions: [global.actionLibrary.attack, global.actionLibrary.ice]
	},
	
	{
		name:"NPC2",
		hp: 55,
		hpMax: 55,
		strength: 3,
		sprites: { idle: spr_npc, attack: spr_npc, down: spr_npc},
		actions: [global.actionLibrary.attack, global.actionLibrary.ice]
	},
];

global.enemies = 
{
	darkSlime:
	{
		name: "Dark Slime",
		hp: 15,
		hpMax: 15,
		strength: 1,
		sprites: {idle: spr_dark_slime},
		actions: [global.actionLibrary.attack],
		xpValue: 5,
		AIscript: function()
		{
			var _action = actions[0];
			var _possibleTargets = array_filter(obj_battle.partyUnits, function(_unit, _index)
			{
				return (_unit.hp > 0);
			});
			var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
			return [_action, _target];
		}
	},
}