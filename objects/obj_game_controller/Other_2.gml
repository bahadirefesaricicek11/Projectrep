global.vol_master = 0.5;
global.vol_sfx = 1;
global.vol_music = 1;
global.fullscreen = 1;
window_set_size(960	, 540);
alarm[0] = 1;

load_settings();

audio_master_gain(global.vol_master);
audio_group_set_gain(audiogroup_sound, global.vol_sfx);
audio_group_set_gain(audiogroup_music, global.vol_music);

battle_system_init();
