switch (state) {

    case SLIME_DAD_STATE.SILHOUETTE:
        // just draw silhouette, wait for controller to change state
    break;

    case SLIME_DAD_STATE.JUMPING:
        jump_timer++;
        var t  = jump_timer / jump_duration;
        x      = lerp(start_x, land_x, t);
        // arc: parabola
        y      = lerp(start_y, land_y, t) - sin(t * pi) * 80;

        if (jump_timer >= jump_duration) {
            x         = land_x;
            y         = land_y;
            state     = SLIME_DAD_STATE.IDLE;
            jump_done = true;
        }
    break;

    case SLIME_DAD_STATE.IDLE:
        // play idle animation
    break;
}