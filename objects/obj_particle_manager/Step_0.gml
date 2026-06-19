/// @description Process Particle Physics (Updated)
var _count = array_length(particles);

for (var _i = _count - 1; _i >= 0; _i--) {
    var _p = particles[_i];
    
    _p.life -= 1;
    if (_p.life <= 0) {
        array_delete(particles, _i, 1);
        continue;
    }
    
    // Apply movement
    _p.x += _p.hsp;
    _p.y += _p.vsp;
    
    // If it's a number pop-up, apply upward friction instead of gravity
    if (variable_struct_exists(_p, "is_text") && _p.is_text) {
        _p.vsp *= 0.92; // Smoothly slows down the upward float
    } else {
        _p.vsp += _p.grav; // Standard falling physics for regular particles
    }
    
    var _life_pct = _p.life / _p.life_max;
    _p.alpha = lerp(0, _p.alpha_max, clamp(_life_pct * 3, 0, 1)); // Clean fade out
}