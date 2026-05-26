varying vec2 v_vTexcoord;
uniform float threshold;

void main() {
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    // Standard luminance formula
    float lum = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    // If it's darker than threshold, make it black
    gl_FragColor = (lum > threshold) ? color : vec4(0.0, 0.0, 0.0, 1.0);
}