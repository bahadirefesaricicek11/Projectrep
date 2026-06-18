timer = 0;
encounter_composition = [];
target_room_reached = false;

card_width = 128;
card_count = 3;

// Set up the starting positions
card_y = array_create(card_count, 0);
card_y[0] = -230; // Left (Top)
card_y[1] = 230;  // Middle (Bottom)
card_y[2] = -230; // Right (Top)

card_back_sprite = spr_enemy_encounter;