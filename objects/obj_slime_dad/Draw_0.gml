switch (state) {
    case SLIME_DAD_STATE.SILHOUETTE:
        // Draw sprite tinted fully black
        draw_sprite_ext(spr_slime_dad, 0, x, y, 1, 1, 0, c_black, 1);
    break;

    case SLIME_DAD_STATE.JUMPING:
        draw_sprite_ext(spr_slime_dad, 1, x, y, 1, 1, 0, c_white, 1); // jump frame
    break;

    case SLIME_DAD_STATE.IDLE:
        draw_self();
    break;
}