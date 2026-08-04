/// @desc Global Item Registry & Data Models
function create_item(_name_key, _desc_key, _price, _ico, _effect, _healAmt, _rarity, _itemType, _canDrop, _hit_effect = noone) constructor
{
    name_key = _name_key;
    description_key = _desc_key;
    price = _price;
    icon = _ico;
    effect = _effect;
    heal_amount = _healAmt; 
    rarity = _rarity;
    itemType = _itemType;
    canDrop = _canDrop;
    hit_effect = _hit_effect;
    count = 1; // Default stack count initialized
}

global.item_list = {
    apple : new create_item(
        "items.apple.name", "items.apple.desc", 10, spr_apple,
        function(_target) { return item_effect_heal(_target, 10); },
        10, "common", "Misc", true
    ),
    bread : new create_item(
        "items.bread.name", "items.bread.desc", 5, spr_bread,
        function(_target) { return item_effect_heal(_target, 5); },
        5, "rare", "Misc", true
    ),    
    hamburger : new create_item(
        "items.hamburger.name", "items.hamburger.desc", 35, spr_hamburger,
        function(_target) { return item_effect_heal(_target, 25); },
        25, "epic", "Misc", true
    ),
    iron_helmet : new create_item(
        "items.iron_helmet.name", "items.iron_helmet.desc", 100, spr_iron_helmet,
        function(_target) { return item_effect_equip(0, "iron_helmet", "player_defense", 5); },
        0, "rare", "Armor_Head", true
    ),
    iron_chestplate : new create_item(
        "items.iron_chestplate.name", "items.iron_chestplate.desc", 100, spr_iron_chestplate,
        function(_target) { return item_effect_equip(1, "iron_chestplate", "player_defense", 10); },
        0, "rare", "Armor_Chest", true
    ),
    iron_bottom : new create_item(
        "items.iron_bottom.name", "items.iron_bottom.desc", 100, spr_iron_bottom,
        function(_target) { return item_effect_equip(2, "iron_bottom", "player_defense", 5); },
        0, "rare", "Armor_Bottom", true
    ),
    normal_shield : new create_item(
        "items.normal_shield.name", "items.normal_shield.desc", 100, spr_normal_shield,
        function(_target) { return item_effect_equip(3, "normal_shield", "player_defense", 5); },
        0, "rare", "Shield", true
    ),
    iron_sword : new create_item(
        "items.iron_sword.name", "items.iron_sword.desc", 100, spr_iron_sword,
        function(_target) { return item_effect_equip(4, "iron_sword", "player_attack", 10); },
        0, "rare", "Weapon", true,
        spr_slash_effect 
    )
};

// --- CORE INVENTORY UTILITY FUNCTIONS ---

