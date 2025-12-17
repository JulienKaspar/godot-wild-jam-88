// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_disabled;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float wall_height = 3.5;

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

// uniform float specular : hint_range(0.0, 1.0, 0.01);

uniform vec2 uv_offset;

uniform ivec2 repeat = ivec2(3, 1);

uniform int random_seed = 100;

uniform float hue_shift : hint_range(0.0, 1.0, 0.01);

// random number generator
int pcg(int u)
{
	uint state = uint(u+random_seed) * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return int((word >> 22u) ^ word) % 1000;
}

const mat3 RGBtoYIQ = mat3(vec3(0.299, 0.5959, 0.2115),
                          vec3(0.587, -0.2746, -0.5227), 
						  vec3(0.114, -0.3213, 0.3112));

const mat3 YIQtoRGB = mat3(vec3(1, 1, 1),
                          vec3(0.956, -0.272, -1.106), 
						  vec3(0.619, -0.647, 1.703));

vec3 shift_hue(vec3 rgb, float ang) {
	vec3 yiq = RGBtoYIQ * rgb;
    //Rotate I and Q chrominance values and scale for saturation
    yiq.yz *= mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));

    //Convert back to RGB colour space
    return YIQtoRGB * yiq;
}

void vertex() {
	ivec2 albedo_tex_size = textureSize(texture_albedo, 0);
	UV.x = VERTEX.x * float(albedo_tex_size.y) / float(albedo_tex_size.x) / wall_height;
	UV.y = -VERTEX.y / wall_height + uv_offset.y;
}

void fragment() {
	vec2 base_uv = UV;
	base_uv.x = mod(UV.x, 1.0 / float(repeat.x));
	base_uv.x += float(pcg(int(floor(UV.x*float(repeat.x))))) / float(repeat.x);

	vec4 albedo_tex = textureGrad(texture_albedo, base_uv, dFdx(UV), dFdy(UV));
    ALBEDO = albedo.rgb * shift_hue(albedo_tex.rgb, hue_shift * 2.0 * PI);
	
	// SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
