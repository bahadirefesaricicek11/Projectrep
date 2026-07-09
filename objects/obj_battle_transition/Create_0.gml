/// @description Initialize Encounter Card Intro System

timer = 0;
encounter_composition = []; // Passed dynamically from the overworld trigger
target_room_reached = false;

card_width = 128;
card_count = 3;

// Set up the starting positions ONCE (prevents snapping frames)
card_y = array_create(card_count, 0);
card_y[0] = -230; // Left Card (Starts Top)
card_y[1] = 230;  // Middle Card (Starts Bottom)
card_y[2] = -230; // Right Card (Starts Top)

card_back_sprite = spr_enemy_encounter;

depth = -9999; // Force this object to stay pinned to the very front of the render listh