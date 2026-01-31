var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);

if (menu_option[page] != previous_menu_option) {
    xo = 0;
}
previous_menu_option = menu_option[page];
xo = lerp(xo, -15, lerpAmt);

var input_up_p = InputPressed(INPUT_VERB.UP) || keyboard_check_pressed(vk_up);
var input_down_p = InputPressed(INPUT_VERB.DOWN) || keyboard_check_pressed(vk_down);
var input_right_p = InputPressed(INPUT_VERB.RIGHT) || keyboard_check_pressed(vk_right);
var input_left_p = InputPressed(INPUT_VERB.LEFT) || keyboard_check_pressed(vk_left);
var input_right_c = InputCheck(INPUT_VERB.RIGHT) || keyboard_check(vk_right);
var input_left_c = InputCheck(INPUT_VERB.LEFT) || keyboard_check(vk_left);
var input_enter_p = InputPressed(INPUT_VERB.ACCEPT) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var input_back_p = InputPressed(INPUT_VERB.CANCEL) || keyboard_check_pressed(vk_escape);

if ((input_down_p || input_up_p) && !inputting) {
    audio_play_sound(snd_menu_move, 0, false);
}

if (inputting) {
    switch (ds_grid[# 1, menu_option[page]]) {
        case menu_element_type.shift:
            var hinput = input_right_p - input_left_p;
            if (hinput != 0) {
                ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]] + hinput, 
                0, array_length_1d(ds_grid[# 4, menu_option[page]]) - 1);
            }
            break;
            
        case menu_element_type.slider:
            var hinput = input_right_c - input_left_c;
            if (hinput != 0) {
                ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]] + (hinput * 0.01), 0, 1);
                script_execute(ds_grid[# 2, menu_option[page]], ds_grid[# 3, menu_option[page]]);
            }
            break;
            
        case menu_element_type.toggle:
            if (input_right_p || input_left_p) {
                ds_grid[# 3, menu_option[page]] = 1 - ds_grid[# 3, menu_option[page]];
                script_execute(ds_grid[# 2, menu_option[page]], ds_grid[# 3, menu_option[page]]);
            }
            break;
    }
    
    if (input_back_p || input_enter_p) {
        inputting = false;
        audio_play_sound(snd_menu_move, 0, false);
    }
} 
else {
    var nav_input = input_down_p - input_up_p;
    if (nav_input != 0) {
        menu_option[page] = (menu_option[page] + nav_input + ds_height) % ds_height;
    }

    if (input_enter_p) {
        switch (ds_grid[# 1, menu_option[page]]) {
            case menu_element_type.script_runner:
                script_execute(ds_grid[# 2, menu_option[page]]);
                break;
                
            case menu_element_type.page_transfer:
                page = ds_grid[# 2, menu_option[page]]; 
                break;
                
            case menu_element_type.shift:
            case menu_element_type.slider:
            case menu_element_type.toggle:
                inputting = true;
                break;
        }
    }
}


if (fade_active)
{
    fade_alpha -= fade_speed;

    if (fade_alpha <= 0)
    {
        fade_alpha = 0;
        fade_active = false;
    }
}