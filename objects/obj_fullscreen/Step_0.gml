if keyboard_check_pressed(vk_f11) and window_get_fullscreen() { 
		window_set_fullscreen(false) 
} else if keyboard_check_pressed(vk_f11) { 
		window_set_fullscreen(true) 
}