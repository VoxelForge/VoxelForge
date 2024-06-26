uniform lowp vec4 fogColor;
uniform float fogDistance;
uniform float fogShadingParameter;
varying highp vec3 eyeVec;

varying lowp vec4 varColor;

void main(void)
{
	vec4 col = varColor;

	float clarity = clamp(fogShadingParameter
		- fogShadingParameter * length(eyeVec) / fogDistance, 0.0, 1.0);
	col.rgb = mix(fogColor.rgb, col.rgb, clarity);

	gl_FragColor = col;
}

/*uniform lowp vec4 fogColor;      // Color of the clouds
uniform float fogDistance;       // Distance at which fog affects fully
uniform float fogShadingParameter;  // Intensity of fog
varying highp vec3 eyeVec;       // Vector from fragment to eye
varying lowp vec4 varColor;      // Vertex color

void main(void)
{
    vec4 col = varColor;  // Initialize with vertex color

    // Calculate the fog factor based on eye distance
    float fogFactor = clamp(fogShadingParameter
                            - fogShadingParameter * length(eyeVec) / fogDistance, 0.0, 1.0);
    
    // Interpolate between fogColor and col.rgb based on fogFactor
    col.rgb = mix(fogColor.rgb, col.rgb, fogFactor);

    // Apply time-based color modulation for sunrise/sunset effect
    // Assuming time is a uniform float representing the current time of day
    float time = mod(gl_FragCoord.x / 100.0 + gl_FragCoord.y / 100.0 + fogDistance, 24.0);

    // Calculate color gradient based on time
    vec3 sunriseColor = vec3(1.0, 0.5, 0.0);   // Orangish color for sunrise
    vec3 sunsetColor = vec3(0.5, 0.0, 1.0);    // Purplish color for sunset

    if (time < 6.0 || time > 18.0) {
        // Night time, keep the fog color
        col.rgb = fogColor.rgb;
    } else if (time < 12.0) {
        // Sunrise to midday
        float t = (time - 6.0) / 6.0;  // Normalize time to range [0,1]
        col.rgb = mix(fogColor.rgb, sunriseColor, t) * col.rgb;
    } else {
        // Midday to sunset
        float t = (time - 12.0) / 6.0; // Normalize time to range [0,1]
        col.rgb = mix(col.rgb, sunsetColor, t);
    }

    gl_FragColor = col;  // Output final color
}
*/

/*uniform lowp vec4 fogColor;          // Color of the clouds
uniform float fogDistance;           // Distance at which fog affects fully
uniform float fogShadingParameter;   // Intensity of fog
varying highp vec3 eyeVec;           // Vector from fragment to eye
varying lowp vec4 varColor;          // Vertex color

// Simple 2D noise function
float random(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void main(void) {
    vec4 col = varColor;  // Initialize with vertex color

    // Calculate the fog factor based on eye distance
    float fogFactor = clamp(fogShadingParameter
                            - fogShadingParameter * length(eyeVec) / fogDistance, 0.0, 1.0);
    
    // Interpolate between fogColor and col.rgb based on fogFactor
    col.rgb = mix(fogColor.rgb, col.rgb, fogFactor);

    // Apply time-based color modulation for sunrise/sunset effect
    // Assuming time is a uniform float representing the current time of day
    float time = mod(gl_FragCoord.x / 100.0 + gl_FragCoord.y / 100.0 + fogDistance, 24.0);

    // Calculate color gradient based on time
    vec3 sunriseColor = vec3(1.0, 0.5, 0.0);   // Orangish color for sunrise
    vec3 sunsetColor = vec3(0.5, 0.0, 1.0);    // Purplish color for sunset
    vec3 noonColor = vec3(1.0, 1.0, 1.0);      // White color for midday

    if (time < 6.0 || time > 18.0) {
        // Night time, keep the fog color
        col.rgb = fogColor.rgb;
    } else if (time < 12.0) {
        // Sunrise to midday
        float t = (time - 6.0) / 6.0;  // Normalize time to range [0,1]
        col.rgb = mix(fogColor.rgb, mix(sunriseColor, noonColor, t), t) * col.rgb;
    } else {
        // Midday to sunset
        float t = (time - 12.0) / 6.0; // Normalize time to range [0,1]
        col.rgb = mix(col.rgb, mix(noonColor, sunsetColor, t), t);
    }

    // Add noise for a soft, fluffy cloud effect
    vec2 uv = gl_FragCoord.xy / vec2(100.0, 100.0);
    float cloudNoise = noise(uv * 3.0);
    cloudNoise = smoothstep(0.3, 0.7, cloudNoise); // Soft edges
    col.rgb = mix(col.rgb, fogColor.rgb, cloudNoise * 0.5);

    gl_FragColor = col;  // Output final color
}
*/

/*void main(void) {
    vec4 col = varColor;  // Initialize with vertex color

    // Calculate the fog factor based on eye distance
    float fogFactor = clamp(fogShadingParameter
                            - fogShadingParameter * length(eyeVec) / fogDistance, 0.0, 1.0);
    
    // Interpolate between fogColor and col.rgb based on fogFactor
    col.rgb = mix(fogColor.rgb, col.rgb, fogFactor);

    // Apply time-based color modulation for sunrise/sunset effect
    // Assuming time is a uniform float representing the current time of day
    float time = mod(gl_FragCoord.x / 100.0 + gl_FragCoord.y / 100.0 + fogDistance, 24.0);

    // Calculate color gradient based on time
    vec3 sunriseColor = vec3(1.0, 0.5, 0.0);   // Orangish color for sunrise
    vec3 sunsetColor = vec3(0.5, 0.0, 1.0);    // Purplish color for sunset
    vec3 noonColor = vec3(1.0, 1.0, 1.0);      // White color for midday

    // Pale fog color for night time
    vec3 nightFogColor = vec3(0.8, 0.8, 0.8);  // Adjust brightness as needed

    if (time < 6.0 || time > 18.0) {
        // Night time, use the pale fog color
        col.rgb = mix(nightFogColor, fogColor.rgb, fogFactor);
    } else if (time < 12.0) {
        // Sunrise to midday
        float t = smoothstep(0.0, 1.0, (time - 6.0) / 6.0);  // Use smoothstep for smoother transition
        col.rgb = mix(fogColor.rgb, mix(sunriseColor, noonColor, t), t) * col.rgb;
    } else {
        // Midday to sunset
        float t = smoothstep(0.0, 1.0, (time - 12.0) / 6.0); // Use smoothstep for smoother transition
        col.rgb = mix(col.rgb, mix(noonColor, sunsetColor, t), t);
    }

    // Add noise for a soft, fluffy cloud effect
    vec2 uv = gl_FragCoord.xy / vec2(100.0, 100.0);
    float cloudNoise = noise(uv * 3.0);
    cloudNoise = smoothstep(0.3, 0.7, cloudNoise); // Soft edges
    col.rgb = mix(col.rgb, fogColor.rgb, cloudNoise * 0.5);

    gl_FragColor = col;  // Output final color
}
*/
