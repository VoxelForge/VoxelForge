uniform sampler2D baseTexture;

uniform vec3 dayLight;
uniform lowp vec4 fogColor;
uniform float fogDistance;
uniform float fogShadingParameter;

uniform highp vec3 cameraOffset;
uniform float animationTimer;

varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 worldPosition;
varying lowp vec4 varColor;
#ifdef GL_ES
varying mediump vec2 varTexCoord;
#else
centroid varying vec2 varTexCoord;
#endif
varying highp vec3 eyeVec;
varying float nightRatio;

void main(void)
{
    vec3 color;
    vec2 uv = varTexCoord.st;

    vec4 base = texture2D(baseTexture, uv).rgba;
#ifdef USE_DISCARD
    if (base.a == 0.0)
        discard;
#endif
#ifdef USE_DISCARD_REF
    if (base.a < 0.5)
        discard;
#endif

    // Simplified Minecraft-like color handling
    color = base.rgb;
    vec4 col = vec4(color.rgb * varColor.rgb, 1.0);

    // Simple flat lighting model
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.5)); // Directional light
    float diff = max(dot(vNormal, lightDir), 0.0);
    col.rgb *= mix(vec3(0.3, 0.3, 0.3), dayLight, diff);

    // Apply fog
    float clarity = clamp(fogShadingParameter - fogShadingParameter * length(eyeVec) / fogDistance, 0.0, 1.0);
    col = mix(fogColor, col, clarity);
    col = vec4(col.rgb, base.a);

    gl_FragData[0] = col;
}

