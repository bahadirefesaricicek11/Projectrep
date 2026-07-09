/// @description obj_npc Create Event
text_id = ""; // Set this to "susie_talk" or whatever in the room editor
has_joined = false; 

// Define the battle profile data right here on the overworld instance
battle_blueprint = {
    name: "Whitey",
    hp: 80,
    max_hp: 80,
    atk: 80,
    def: 4,
    clover_leaves: 3,
    sprite: spr_npc, // The sprite asset used inside the battle room
};