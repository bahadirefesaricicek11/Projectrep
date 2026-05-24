// Prevent memory leaks by freeing the VRAM surface canvas
if (surface_exists(lighting_surface)) {
    surface_free(lighting_surface);
}