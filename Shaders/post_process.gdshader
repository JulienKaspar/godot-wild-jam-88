shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float offset_scale : hint_range(0.0, 1.0) = 0.04;
uniform int distortion_samples : hint_range(1, 100) = 8;

uniform float drunkness : hint_range(0.0, 1.0) = 0.;

#include "./noise.gdshaderinc"

void fragment() {
	float sat = 1.;
	float vignette_mask = pow(smoothstep(.25, 1., length(SCREEN_UV - vec2(.5)) * 2. / sqrt(2)), 2.);
	float dither_pattern = ign(int((SCREEN_UV/SCREEN_PIXEL_SIZE).x), int((SCREEN_UV/SCREEN_PIXEL_SIZE).y));
	vignette_mask += .1 * (dither_pattern - .5);
	
	float t = TIME * 1.;
		
	float distortion_strength = mix(1., 4., vignette_mask);
	distortion_strength += .01 * (dither_pattern - .5) * float(distortion_samples);
	distortion_strength *= offset_scale * drunkness;
	
	float time_offset = noise2D(SCREEN_UV * vec2( 1., SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y) * 4.) * 4.;
	
	t += time_offset;
	
	vec2 offset_r = (vec2(noise1D(t + 50.), noise1D(t + 150.)) - vec2(.5)) * distortion_strength;
	vec2 offset_g = (vec2(noise1D(t + 200.), noise1D(t + 300.)) - vec2(.5)) * distortion_strength;
	vec2 offset_b = -offset_r;
	
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	vec2 sample_offset_r;
	vec2 sample_offset_g;
	vec2 sample_offset_b;
	float sample_scale;
	vec2 sample_offset;
	
	vec3 distortion_buffer = vec3(.0);
	
	for (int i=0;i<distortion_samples;++i){
		sample_scale = float(i + 1)/float(distortion_samples);
		
		distortion_buffer.r += textureLod(screen_texture, SCREEN_UV + offset_r * sample_scale, 0.0).r;
		distortion_buffer.g += textureLod(screen_texture, SCREEN_UV + offset_g * sample_scale, 0.0).g;
		distortion_buffer.b += textureLod(screen_texture, SCREEN_UV + offset_b * sample_scale, 0.0).b;
	}
	
	c = distortion_buffer / float(distortion_samples);
	
	//Saturation
	sat *= mix(1., 2., vignette_mask);
	sat *= mix(1., 1.5, drunkness);
    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, sat);
	
	//Contrast
	float contrast = mix(.8, 1.5, drunkness);
    c.rgb = mix(vec3(0.5), c.rgb, contrast);
	
	// Brightness
	float vignette_strength = mix(.25, .8, drunkness);
	c = mix(c, vec3(0.), vignette_mask * .5);
	c *= mix(1., 1.25, pow(drunkness, 2.));
	
	
	COLOR.rgb = c;
}