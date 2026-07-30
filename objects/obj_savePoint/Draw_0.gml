var _w = sprite_width;
var _h = sprite_height;

var _visual_left   = x - sprite_get_xoffset(sprite_index);
var _visual_top    = y - sprite_get_yoffset(sprite_index);
var _visual_bottom = _visual_top + _h;

// 1. Ensure the surface exists
if (!surface_exists(mirror_surface)) {
    mirror_surface = surface_create(_w, _h);
}

// 2. Target the surface and clear it to a fully transparent canvas
surface_set_target(mirror_surface);
draw_clear_alpha(c_black, 0); 

if (instance_exists(obj_player)) {
    
    // 1. Horizontal centering inside the surface canvas
    var _reflect_x = obj_player.x - _visual_left;
    
    // 2. Locate the glass baseline inside the surface canvas
    var _glass_baseline_y = _h - 8; // Adjust to pixel distance from top to inner frame base
    
    // 3. FORCE THE COUPLING: 
    // In room space, the absolute highest the player can stand is when their feet 
    // touch the bottom of the mirror instance. 
    var _mirror_base_in_room = y + _h - sprite_get_yoffset(sprite_index);
    
    // Calculate how far away the player's feet are from the mirror's base line
    var _distance_from_base = obj_player.y - _mirror_base_in_room;
    
    // 4. THE CORRECTED VERTICAL POSITION:
    // When standing right at the base, the player's feet touch the frame, 
    // and the reflection's feet should touch the frame (_glass_baseline_y).
    // As the player walks backwards, the reflection moves upward into the glass depth.
    var _perspective_scale = 0.5;
    
    // Subtracting an asset compensation constant to force the sprite upward out of the frame
    var _sprite_height_compensation = 20; 
    
    var _reflect_y = _glass_baseline_y - _sprite_height_compensation - (_distance_from_base * _perspective_scale);
    
    // Direction Check
    var _player_face = obj_player.face;
    var _reflected_face = _player_face;
    
    if (_player_face == FACE_DOWN) {
        _reflected_face = FACE_UP;
    } else if (_player_face == FACE_UP) {
        _reflected_face = FACE_DOWN;
    }
    
    var _reflection_sprite = obj_player.sprite[_reflected_face];
    
    // Draw the reflection
    draw_sprite_ext(
        _reflection_sprite,
        obj_player.image_index,
        _reflect_x,
        _reflect_y,
        obj_player.image_xscale,
        obj_player.image_yscale,
        obj_player.image_angle,
        obj_player.image_blend,
        obj_player.image_alpha
    );
}

// Step B: Erase anything outside the glass bounds
// bm_subtract takes the solid parts of your mask (the frame/outside area) 
// and cuts them out of whatever we just drew, leaving the glass completely empty.
gpu_set_blendmode(bm_subtract);
draw_sprite(spr_mirror_mask, 0, sprite_get_xoffset(sprite_index), sprite_get_yoffset(sprite_index));
gpu_set_blendmode(bm_normal); // Always reset!

surface_reset_target();

// --- FINAL COMPOSITION ---
// Draw the clipped surface (only the glass area contains the reflection now)
draw_surface(mirror_surface, _visual_left, _visual_top);

// Draw your main decorative mirror frame and vines on top
draw_self();