if (!surface_exists(surf_bloom)) surf_bloom = surface_create(surf_width, surf_height);
if (!surface_exists(surf_blur))  surf_blur  = surface_create(surf_width, surf_height);

// 1. FILTER: Only extract the bright lights
surface_set_target(surf_bloom);
shader_set(shd_bloom_filter);
shader_set_uniform_f(u_thresh, 0.7); // Tweak this! (0.5 = more glow, 0.9 = only very bright)
draw_surface_stretched(application_surface, 0, 0, surf_width, surf_height);
shader_reset();
surface_reset_target();

// 2. BLUR: Perform the blur passes
shader_set(shd_blur);
// Horizontal Pass
surface_set_target(surf_blur);
shader_set_uniform_f(u_texel, 1.0/surf_width, 0.0);
shader_set_uniform_i(u_dir, 1);
draw_surface(surf_bloom, 0, 0);
surface_reset_target();
// Vertical Pass
surface_set_target(surf_bloom);
shader_set_uniform_f(u_texel, 0.0, 1.0/surf_height);
shader_set_uniform_i(u_dir, 1);
draw_surface(surf_blur, 0, 0);
surface_reset_target();
shader_reset();

// 3. COMPOSE: Draw game, then add the glow
draw_surface_stretched(application_surface, 0, 0, display_get_gui_width(), display_get_gui_height());

gpu_set_tex_filter(true);
gpu_set_blendmode(bm_add);
draw_set_alpha(0.5); // Soften the glow intensity
draw_surface_stretched(surf_bloom, 0, 0, display_get_gui_width(), display_get_gui_height());
draw_set_alpha(1.0);
gpu_set_blendmode(bm_normal);
gpu_set_tex_filter(false);