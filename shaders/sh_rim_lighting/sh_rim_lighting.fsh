varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_NormalMap;
uniform vec2 u_LightPos;
uniform vec2 u_PlayerPos;
uniform vec3 u_LightColor;
uniform float u_LightIntensity;

void main()
{
    vec4 normalMap = texture2D(u_NormalMap, v_vTexcoord);
    if (normalMap.a == 0.0)
    {
        discard;
    }
    
    vec3 normal = normalize((normalMap.rgb * 2.0) - 1.0);
    vec2 lightDir = normalize(u_LightPos - u_PlayerPos);
    float diffuse = max(dot(normal.xy, lightDir), 0.0);
    
    float dist = distance(u_LightPos, u_PlayerPos);
    float attenuation = smoothstep(u_LightIntensity, u_LightIntensity * 0.5, dist);
    
    vec3 highlight = diffuse * attenuation * u_LightColor * 3.0;
    gl_FragColor = vec4(highlight, attenuation * normalMap.a);
}