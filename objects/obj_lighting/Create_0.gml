// Main canvas reference pointer
lighting_surface = noone;

// Atmosphere Interpolation Channels
current_color = c_white;
current_alpha = 0.0;

target_color  = c_white;
target_alpha  = 0.0;

transition_speed = 0.04; // Lower value = smoother mood transitions

// Geometric Mesh Resolution
circle_segments = 32; // Higher value = smoother code-drawn curves

// Global animation timer clock
pulse_timer = 0;