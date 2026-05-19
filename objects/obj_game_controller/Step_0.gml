if (room == rm_init || room == rm_splash)
{
    if (instance_exists(obj_player)) obj_player.can_move = false;
}

if (room == rm_menuRoom || room == rm_nameScreen)
{
    draw_sprite_tiled(spr_warp_transition, 0, 0, 0);
    if (instance_exists(obj_player)) obj_player.can_move = false;
    
    // Menü müziğini güvenle çal
    if (!audio_is_playing(msc_menu)) {
        audio_play_sound(msc_menu, 1, true); // Döngü (loop) true olsun ki menüde müzik bitmesin
    }
} 
else 
{
    // BURADAKİ audio_stop_all(); YAZISINI SİLDİK!
    // Sadece menü odasından BAŞKA bir odaya geçildiği an menü müziğini tek seferlik durduruyoruz:
    if (audio_is_playing(msc_menu)) {
        audio_stop_sound(msc_menu);
    }
}