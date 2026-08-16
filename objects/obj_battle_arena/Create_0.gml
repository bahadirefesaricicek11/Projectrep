// ---------------- CREATE EVENT ----------------
phase          = "TELL";
tell_timer     = 0;
tell_duration  = 0.6;

attackers      = [];   // set by scr_battle_arena_begin() right after spawn
beats          = [];   // live beat data, each tagged with attacker_index
parries        = 0;
done           = false;

// platformer physics
// Tuned for snappier, less floaty feel -- the previous values (gravity 0.35,
// jump_speed -6, move_max_speed 2.2) meant crossing the whole arena took nearly
// 2 full seconds and the jump arc hung in the air a while, which reads as sluggish
// regardless of any visual polish. Gravity/jump_speed below are scaled together
// to keep roughly the same jump HEIGHT (~49px, close to the old ~51px) but a
// noticeably shorter, punchier airtime.
gravity_val      = 0.5;   // was 0.35
jump_speed       = -7;    // was -6
parry_hop_speed  = -4; // small upward bounce on a successful parry, sells the feel

// Horizontal movement accelerates/decelerates rather than snapping straight to
// max speed. Both max speed and the accel/decel rates are bumped up from the
// first pass -- 2.2px/frame was genuinely slow for reactive dodging, this should
// feel meaningfully more responsive while still ramping (not instant on/off).
avatar_hspeed    = 0;
move_max_speed   = 3.2;  // was 2.2
move_accel       = 0.75; // was 0.5 -- reaches max speed in ~4 frames
move_decel       = 1.0;  // was 0.7 -- stops in ~3 frames, stays snappy

avatar_vspeed    = 0;
avatar_grounded  = true;

// Coyote time -- a short grace window after walking off a ledge/platform where
// jump still works, like it does in most platformers people describe as "feeling
// good." Without this, missing a jump by one frame right at an edge feels unfair
// rather than tense.
coyote_timer = 0;
coyote_max   = 6; // frames of grace after leaving the ground

// Jump buffer -- a press slightly BEFORE landing still triggers a jump the moment
// you touch down, instead of being silently dropped because you weren't grounded
// yet. Makes chained jumps feel responsive instead of needing frame-perfect timing.
jump_buffer_timer = 0;
jump_buffer_max   = 6;

// Variable jump height -- tap the button for a short hop, hold it for the full
// jump. Releasing early cuts the ascent short. This is what gives jumping actual
// player agency/tension instead of every jump being identical regardless of input.
jump_active        = false;
jump_cut_multiplier = 0.45;

// Parry input -- a genuinely SEPARATE press from jump, not just "is the button
// currently held". If parry read InputCheck() the same way jump did, holding the
// button through a normal jump (which you naturally do for full height) would
// auto-parry the instant you touched a yellow beat, with no real intent required.
// Instead: a press while grounded means jump. A press while ALREADY airborne is
// treated as a deliberate parry attempt. Buffered briefly so the timing is still
// forgiving, same idea as jump_buffer_timer above.
parry_press_buffer_timer = 0;
parry_press_buffer_max   = 8;

// Landing squash -- a brief flatten on touchdown, purely cosmetic, for a bit of
// physical weight instead of the avatar just stopping dead silently.
landing_squash_timer = 0;
landing_squash_max   = 8;

// Local hit/parry feedback -- flashes the avatar and pops a callout text right at
// the avatar's position, so a hit or parry is unmistakable while you're actually
// looking at the arena. The controller's own damage popup/screenshake still fire
// too (over at the HP box), but that's easy to miss mid-dodge -- this is the
// immediate, can't-miss-it feedback.
hit_flash_timer   = 0;
parry_flash_timer = 0;
local_popups      = []; // {x, y, text, color, life, max_life}

// arena footprint -- tune these once it's actually on screen
box_w = 240;
box_h = 130;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _center_x = _gui_w / 2;
var _center_y = (_gui_h / 2) - 10; // matches where the old dodge ring used to sit

box_l    = _center_x - (box_w / 2);
box_r    = _center_x + (box_w / 2);
box_t    = _center_y - (box_h / 2);
ground_y = _center_y + (box_h / 2); // floor sits at the bottom of the box

avatar_x = _center_x;
avatar_y = ground_y;

// Surfaces the avatar can stand on -- the ground floor plus a couple of raised
// platforms. One-way: you can jump UP through a platform from below, but only
// land on it while falling. Add/remove/reposition freely; y is an offset from
// ground_y (negative = above the floor), kept comfortably inside jump_speed's
// reach (roughly 50px at these physics values -- see the Step event comment).
platforms = [
    { x1: box_l,        x2: box_r,        y: ground_y      }, // the main floor
    { x1: box_l + 20,    x2: box_l + 80,   y: ground_y - 35 }, // left platform
    { x1: box_r - 80,    x2: box_r - 20,   y: ground_y - 35 }  // right platform
];
