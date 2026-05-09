if (change = true && fade_state == 0) {
    fade_state = 1;
	obj_textbox.ready = false;
}

switch (fade_state) {
    case 1:
        fade_alpha += fade_speed;
        
        if (fade_alpha >= 1) {
            fade_alpha = 1;
            
            image_index += 1;
            
            fade_state = 2;
        }
    break;

    case 2:
        fade_alpha -= fade_speed;
        
        if (fade_alpha <= 0) {
            fade_alpha = 0;
            fade_state = 0;
			change = false;
			obj_textbox.ready = true;
        }
    break;
}