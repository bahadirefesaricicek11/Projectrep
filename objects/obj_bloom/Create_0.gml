surf_width = 384 / 4; 
surf_height = 216 / 4;

surf_bloom = surface_create(surf_width, surf_height);
surf_blur  = surface_create(surf_width, surf_height);

u_texel = shader_get_uniform(shd_blur, "texelSize");
u_dir   = shader_get_uniform(shd_blur, "direction");
u_thresh = shader_get_uniform(shd_bloom_filter, "threshold");

application_surface_draw_enable(false);