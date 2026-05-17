player_units = [];
enemy_units  = [];

enum BATTLE_PHASE {
    CARD_PICK_START,
    PLAYER_TURN,
    ENEMY_TURN,
    CARD_PICK_CRIT,
    BATTLE_WIN,
    BATTLE_LOSE
}

phase              = BATTLE_PHASE.CARD_PICK_START;
active_unit_index  = 0;
turn_number        = 0;

crit_bar_current   = 0;
crit_bar_max       = 100;
crit_bar_full      = false;

active_buffs = [];