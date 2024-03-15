shader_type canvas_item;

uniform sampler2D simulation_texture;
uniform float amplitude;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {

	vec4 tex = texture(simulation_texture, UV);
	vec4 tex_dx = texture(simulation_texture, UV + vec2(0.01, 0.0));
	vec4 tex_dy = texture(simulation_texture, UV + vec2(0.0, 0.01));
	float height = tex.r - tex.g;
	float height_dx = tex_dx.r - tex_dx.g;
	float height_dy = tex_dy.r - tex_dy.g;
	vec2 displacement = vec2(height_dx - height, height_dy - height);
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - displacement);
}
