// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_disabled;

uniform vec4 albedo = vec4(0.5, 0.5, 0.5, 0.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float wall_height = 3.5;
uniform float stretch = 1.0;

uniform float roughness : hint_range(0.0, 1.0);

// uniform float specular : hint_range(0.0, 1.0, 0.01);

uniform vec2 uv_offset;
varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;

uniform int tile = 3;

uniform int random_seed = 100;
uniform bool flip_x = false;

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
    vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

    TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
    TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

    BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
    BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
    BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
    BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);

    // UV Triplanar: Enabled (with World Triplanar)
    uv_power_normal = abs(normal);
    ivec2 albedo_tex_size = textureSize(texture_albedo, 0);
    uv_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0) / wall_height).xyz;
    uv_triplanar_pos.xz *= float(albedo_tex_size.y) / (float(albedo_tex_size.x) * stretch);
    uv_triplanar_pos += vec3(uv_offset, uv_offset.x);
    uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec3 uv) {
    vec4 samp = vec4(0.0);
    samp += textureGrad(p_sampler, p_triplanar_pos.xy, dFdx(uv.xy), dFdy(uv.xy)) * p_weights.z;
    samp += textureGrad(p_sampler, p_triplanar_pos.xz, dFdx(uv.xz), dFdy(uv.xz)) * p_weights.y;
    samp += textureGrad(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0), dFdx(uv.zy), dFdy(uv.zy)) * p_weights.x;
    return samp;
}

float random_repeat_tile(float pos, float num_tile, bool flip) {
	int seed = int(floor(pos * num_tile));
	float new_pos = mod(pos, 1.0 / num_tile);
	if (flip && (pcg(seed + 10) % 2 == 1)) {
		new_pos = 1.0 / num_tile - new_pos;
	}
    return new_pos + float(pcg(seed)) / num_tile;
}

void fragment() {
    vec3 base_uv = uv_triplanar_pos;
    base_uv.x = random_repeat_tile(base_uv.x, float(tile), flip_x);
    base_uv.z = random_repeat_tile(base_uv.z, float(tile), flip_x);

    vec4 albedo_tex = triplanar_texture(texture_albedo, uv_power_normal, base_uv, uv_triplanar_pos);
    ALBEDO = albedo.rgb * shift_hue(albedo_tex.rgb, hue_shift * TAU);

    // SPECULAR = specular;

    ROUGHNESS = roughness;
}
