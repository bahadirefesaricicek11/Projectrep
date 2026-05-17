function cards_get_pool() {
    return [
        { label: "Savaş Çığlığı", stat: "atk", value: 8,  desc: "Tüm takım +8 ATK" },
        { label: "Demir Deri",    stat: "def", value: 6,  desc: "Tüm takım +6 DEF" },
        { label: "Saha Hekimi",  stat: "hp",  value: 25, desc: "Tüm takım +25 HP"  },
        { label: "Kan Hırsı",    stat: "atk", value: 15, desc: "Tüm takım +15 ATK" },
        { label: "Kalkan",       stat: "def", value: 12, desc: "Tüm takım +12 DEF" },
        { label: "Toparlan",     stat: "hp",  value: 50, desc: "Tüm takım +50 HP"  },
    ];
}

function cards_pick_random(n) {
    var _pool   = cards_get_pool();
    var _picked = [];
    var _used   = array_create(array_length(_pool), false);
    repeat (min(n, array_length(_pool))) {
        var _idx;
        do { _idx = irandom(array_length(_pool) - 1); }
        until (!_used[_idx]);
        _used[_idx] = true;
        array_push(_picked, _pool[_idx]);
    }
    return _picked;
}

function card_picker_show(count) {
    var _cards  = cards_pick_random(count);
    var _picker = instance_create_layer(0, 0, "UI", obj_card_picker);
    _picker.offered_cards = _cards;
}