enum SLIME_DAD_STATE {
    SILHOUETTE,
    JUMPING,
    IDLE
}

state          = SLIME_DAD_STATE.SILHOUETTE;
jump_done      = false;

// Position where he lands after jumping out of bushes
land_x         = x + 80;  // adjust to your room layout
land_y         = y;
jump_timer     = 0;
jump_duration  = 40; // frames
start_x        = x;
start_y        = y;