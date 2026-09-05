shader_type spatial;
// Disable modern PBR lighting logic to achieve that flat, bright 2000s anime/cartoon look
render_mode unshaded, blend_mix, depth_draw_always;

uniform sampler2D wave_noise_tex : repeat_enable, filter_linear_mipmap;

// Sunshine Color Palette
uniform vec4 deep_water_color : source_color = vec4(0.0, 0.45, 0.85, 0.8);
uniform vec4 shallow_water_color : source_color = vec4(0.0, 0.8, 0.9, 0.6);
uniform vec4 wave_shimmer_color : source_color = vec4(0.8, 1.0, 1.0, 1.0);

// Vertex Wave Animation
uniform float vertex_wave_speed = 1.5;
uniform float vertex_wave_height = 0.25;
uniform float vertex_wave_freq = 0.5;

// Texture Scrolling Coordinates
uniform vec2 scroll_speed_1 = vec2(0.03, 0.02);
uniform vec2 scroll_speed_2 = vec2(-0.02, 0.03);
uniform float shimmer_cutoff : hint_range(0.0, 1.0) = 0.55; // Controls how thick the bright patterns are

void vertex() {
    // Large, gentle rolling sine waves for physical mesh bobbing
    float wave = sin(VERTEX.x * vertex_wave_freq + TIME * vertex_wave_speed) 
               * cos(VERTEX.z * vertex_wave_freq + TIME * vertex_wave_speed);
    VERTEX.y += wave * vertex_wave_height;
}

void fragment() {
    // Scroll texture layers across each other
    vec2 uv1 = UV + TIME * scroll_speed_1;
    vec2 uv2 = UV + TIME * scroll_speed_2;
    
    // Read the texture maps (using just the red channel)
    float tex1 = texture(wave_noise_tex, uv1).r;
    float tex2 = texture(wave_noise_tex, uv2).r;
    
    // Multiply them together to find the overlapping intersection points
    float combined_shimmer = tex1 * tex2;
    
    // Use step() to give it a sharp, crisp, cartoony outline (no soft gradients)
    float final_shimmer_mask = step(shimmer_cutoff, combined_shimmer);
    
    // Create a base water gradient shifting from deep to shallow based on texture depth
    vec3 base_water = mix(deep_water_color.rgb, shallow_water_color.rgb, tex1 * 0.4);
    
    // Layer the bright shimmer textures directly over the top
    vec3 final_albedo = mix(base_water, wave_shimmer_color.rgb, final_shimmer_mask);
    
    // Output properties
    ALBEDO = final_albedo;
    
    // Maintain a consistent stylized alpha transparency
    ALPHA = mix(deep_water_color.a, wave_shimmer_color.a, final_shimmer_mask);
}