varying vec2 v_vTexcoord;
uniform vec2 texelSize;
uniform int direction;

void main() {
    vec4 color = vec4(0.0);
    
    // Explicitly define the array and values to avoid compiler issues
    float weight[5];
    weight[0] = 0.227027;
    weight[1] = 0.1945946;
    weight[2] = 0.1216216;
    weight[3] = 0.054054;
    weight[4] = 0.016216;
    
    vec2 offset = texelSize * float(direction);
    
    // Sum the samples
    color += texture2D(gm_BaseTexture, v_vTexcoord) * weight[0];
    
    for (int i = 1; i < 5; i++) {
        vec2 off = offset * float(i);
        color += texture2D(gm_BaseTexture, v_vTexcoord + off) * weight[i];
        color += texture2D(gm_BaseTexture, v_vTexcoord - off) * weight[i];
    }
	// This makes the glow "roll off" nicely instead of blurring everything
	color.rgb = pow(color.rgb, vec3(1.2)); // Adjust 1.2: higher = more contrasty glow
	gl_FragColor = color;
	
    
    gl_FragColor = color;
}