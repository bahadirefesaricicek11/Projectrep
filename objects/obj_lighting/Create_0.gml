// Initialize the canvas pointer
lighting_surface = noone;

// Current visual state (Defaults to completely transparent daylight)
current_color = c_white;
current_alpha = 0.0;

// Target state we want to shift toward (Change these to trigger transitions!)
target_color = c_white;
target_alpha = 0.0;

// How smoothly the atmosphere shifts (0.05 = elegant and gradual)
transition_speed = 0.05;

// Circle fidelity configuration (24 steps makes a perfect code-drawn circle)
circle_segments = 24;