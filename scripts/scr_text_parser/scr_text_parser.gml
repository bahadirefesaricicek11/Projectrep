// Helper function to check if a font only supports uppercase
function font_is_uppercase_only(_font_asset) {
    switch (_font_asset) {
        // ADD YOUR UPPERCASE-ONLY FONTS HERE:
        case Bitmap_Font: 
            return true;
            
        // Add any other custom fonts that only have uppercase letters:
        // case fnt_retro_bold: return true; 
        
        default: 
            return false;
    }
}

// Helper function to dynamically scale fonts that are too small
function get_font_scale(_font_asset) {
    switch (_font_asset) {
        case Bitmap_Font: 
            return 0.75; // Render this font 1.5x larger. Change this value to adjust size!
            
        default: 
            return 1.0;  // Standard scale for your main/default font
    }
}

// Helper function to return 4-corner colors for gradient/solid tags
function get_gradient_colors(_color_name) {
    // Default fallback (solid white)
    var _col_tl = c_white, _col_tr = c_white, _col_bl = c_white, _col_br = c_white;

    switch (_color_name) {
        // --- GRADIENT PRESETS ---
        case "gold":
            var _yellow = c_yellow;   // Bright Gold/Yellow
            var _orange = c_orange;   // Warm Deep Orange
            _col_tl = _yellow;
            _col_tr = _yellow;
            _col_bl = _orange;
            _col_br = _orange;
            break;
            
        case "ice":
            var _light_blue = make_color_rgb(180, 240, 255);
            var _deep_blue  = make_color_rgb(0, 100, 220);
            _col_tl = _light_blue;
            _col_tr = _light_blue;
            _col_bl = _deep_blue;
            _col_br = _deep_blue;
            break;

        // --- STANDARD SOLID COLORS ---
        case "red":    
            _col_tl = c_red; _col_tr = c_red; _col_bl = c_red; _col_br = c_red; 
            break;
        case "blue":   
            _col_tl = c_blue; _col_tr = c_blue; _col_bl = c_blue; _col_br = c_blue; 
            break;
        case "yellow": 
            _col_tl = c_yellow; _col_tr = c_yellow; _col_bl = c_yellow; _col_br = c_yellow; 
            break;
        case "green":  
            _col_tl = c_lime; _col_tr = c_lime; _col_bl = c_green; _col_br = c_green; 
            break;
        case "white":  
            _col_tl = c_white; _col_tr = c_white; _col_bl = c_white; _col_br = c_white; 
            break;
            
        default:
            // Support Custom Hex Colors: [color=#FF00FF]
            if (string_char_at(_color_name, 1) == "#") {
                var _hex = string_delete(_color_name, 1, 1);
                var _r = real("0x" + string_copy(_hex, 1, 2));
                var _g = real("0x" + string_copy(_hex, 3, 2));
                var _b = real("0x" + string_copy(_hex, 5, 2));
                var _hex_color = make_color_rgb(_r, _g, _b);
                
                _col_tl = _hex_color; _col_tr = _hex_color; _col_bl = _hex_color; _col_br = _hex_color;
            }
            break;
    }

    return { tl: _col_tl, tr: _col_tr, bl: _col_bl, br: _col_br };
}

function parse_text_effects(_raw_text) {
    var _processed = _raw_text;
    _processed = string_replace_all(_processed, "%name%", string(global.player_name));
    _processed = string_replace_all(_processed, "%gold%", string(global.gold_amount));
    
    if (variable_global_exists("item_found_name")) {
        _processed = string_replace_all(_processed, "%item%", string(global.item_found_name));
    }

    var _clean_text = "";
    var _effects_data = []; 
    
    var _len = string_length(_processed);
    
    // Active tag states
    var _effect_shake = false;
    var _effect_wave = false;
    var _effect_rainbow = false;
    
    var _pending_pause = 0;
    
    var _current_colors = { tl: c_white, tr: c_white, bl: c_white, br: c_white };
    
    var _current_font = draw_get_font(); 
    var _default_font = _current_font; 

    var i = 1;
    while (i <= _len) {
        // --- LOOP TO CONSUME ALL CONSECUTIVE TAGS BEFORE PRINTING A CHAR ---
        while (i <= _len && string_char_at(_processed, i) == "[") {
            var _close_pos = string_pos_ext("]", _processed, i);
            if (_close_pos > 0) {
                var _tag = string_copy(_processed, i + 1, _close_pos - i - 1);
                
                // Toggle effect states
                if (_tag == "shake")           _effect_shake = true;
                else if (_tag == "/shake")     _effect_shake = false;
                else if (_tag == "wave")       _effect_wave = true;
                else if (_tag == "/wave")      _effect_wave = false;
                else if (_tag == "rainbow")    _effect_rainbow = true;
                else if (_tag == "/rainbow")   _effect_rainbow = false;
                
                // Pause tag
                else if (string_copy(_tag, 1, 6) == "pause=") {
                    var _pause_val = real(string_delete(_tag, 1, 6));
                    
                    var _data_len = array_length(_effects_data);
                    if (_data_len > 0) {
                        _effects_data[_data_len - 1].pause = _pause_val;
                    } else {
                        _pending_pause = _pause_val;
                    }
                }
                
                // Font tag
                else if (string_copy(_tag, 1, 5) == "font=") {
                    var _font_name = string_delete(_tag, 1, 5);
                    var _font_asset = asset_get_index(_font_name);
                    if (_font_asset != -1 && asset_get_type(_font_name) == asset_font) {
                        _current_font = _font_asset;
                    }
                }
                else if (_tag == "/font") {
                    _current_font = _default_font;
                }
                
                // Color tag
                else if (string_copy(_tag, 1, 6) == "color=") {
                    var _col_val = string_delete(_tag, 1, 6);
                    _current_colors = get_gradient_colors(_col_val);
                }
                else if (_tag == "/color") {
                    _current_colors = { tl: c_white, tr: c_white, bl: c_white, br: c_white };
                }
                
                // Jump past ] and continue internal while loop in case another tag follows immediately
                i = _close_pos + 1;
            } else {
                // If there's no closing bracket ], treat [ as raw text
                break;
            }
        }
        
        // Safety break if we reached the end of the text while parsing trailing tags
        if (i > _len) break;
        
        var _char = string_char_at(_processed, i);
        
        if (font_is_uppercase_only(_current_font)) {
            _char = string_upper(_char);
        }
        
        _clean_text += _char;
        
        // Push character formatting struct with ALL active states applied
        array_push(_effects_data, {
            shake: _effect_shake,
            wave: _effect_wave,
            rainbow: _effect_rainbow,
            color_tl: _current_colors.tl,
            color_tr: _current_colors.tr,
            color_bl: _current_colors.bl,
            color_br: _current_colors.br,
            font: _current_font,
            scale: get_font_scale(_current_font),
            pause: _pending_pause
        });
        
        _pending_pause = 0; // Clear start-of-line pending pause once used
        
        i++;
    }
    
    return {
        clean_text: _clean_text,
        effects: _effects_data
    };
}