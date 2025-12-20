// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_disabled;

uniform vec4 albedo = vec4(0.5, 0.5, 0.5, 0.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float scale = 1.0;

uniform float roughness : hint_range(0.0, 1.0);

// uniform float specular : hint_range(0.0, 1.0, 0.01);

uniform vec2 uv_offset;
varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;

/**
 * Number of tiles in the atlas
 */
uniform int tile = 5;

uniform int random_seed = 50;

/**
 * Randomly flip some tiles in x direction.
 */

uniform bool flip_x = false;
/**
 * Randomly flip some tiles in y direction.
 */
uniform bool flip_y = false;

uniform float hue_shift : hint_range(0.0, 1.0, 0.01);

#include "./util.gdshaderinc"

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
    uv_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    uv_triplanar_pos.x *= float(albedo_tex_size.y) / (float(albedo_tex_size.x) * scale);
	uv_triplanar_pos.z /= scale;
    uv_triplanar_pos += vec3(uv_offset.x, 0.0, uv_offset.y);
    uv_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec3 uv) {
    return textureGrad(p_sampler, p_triplanar_pos.xz, dFdx(uv.xz), dFdy(uv.xz)) * p_weights.y;
}

vec2 random_repeat_tile(vec2 pos, float num_tile) {
	vec3 seed = vec3(floor(pos * vec2(num_tile, 1)), float(random_seed));
	float new_pos_x = mod(pos.x, 1.0 / num_tile);
	ivec3 rand = pcg3d(seed);
	if (flip_x && (rand.x % 2 == 1)) {
		new_pos_x = 1.0 / num_tile - new_pos_x;
	}
	float new_pos_y = pos.y;
	if (flip_y && (rand.y % 2 == 1)) {
		new_pos_y = 1.0 - pos.y + 2.0 * floor(pos.y);
	}
    float offset = float(rand.z);
	return vec2(new_pos_x + offset/num_tile, new_pos_y);
}

void fragment() {
    vec3 base_uv = uv_triplanar_pos;
    base_uv.xz = random_repeat_tile(base_uv.xz, float(tile));

    vec4 albedo_tex = triplanar_texture(texture_albedo, uv_power_normal, base_uv, uv_triplanar_pos);
    ALBEDO = albedo.rgb * shift_hue(albedo_tex.rgb, hue_shift * TAU);

    // SPECULAR = specular;

    ROUGHNESS = roughness;
}
