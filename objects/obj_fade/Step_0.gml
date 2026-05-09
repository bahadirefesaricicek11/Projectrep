// Check if the integer part of image_index has changed
if (floor(image_index) != floor(last_frame)) {
    is_fading = true;
    fade_alpha = 1; // Start fully opaque (or 0 if you want to fade IN first)
}

// Update last_frame for the next step
last_frame = image_index;

// Handle the fade logic
if (is_fading) {
    fade_alpha -= fade_speed;
    if (fade_alpha <= 0) {
        fade_alpha = 0;
        is_fading = false;
    }
}