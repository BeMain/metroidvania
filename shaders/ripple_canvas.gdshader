shader_type canvas_item;

uniform sampler2D simulation_texture;
/// The size of the additional area, outside of the screen, where ripples are simulated. In UV coordinates.
uniform vec2 simulation_texture_margin;
/// The amplitude of waves.
uniform float amplitude: hint_range(0.0, 1.0, 0.05) = 0.5;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = simulation_texture_margin + UV * (1.0 - 2.0 * simulation_texture_margin);
	vec4 tex = texture(simulation_texture, uv);
	vec4 tex_dx = texture(simulation_texture, uv + vec2(0.01, 0.0));
	vec4 tex_dy = texture(simulation_texture, uv + vec2(0.0, 0.01));
	float height = tex.r + tex.g + tex.b;
	float height_dx = tex_dx.r + tex_dx.g + tex_dx.b;
	float height_dy = tex_dy.r + tex_dy.g + tex_dy.b;
	vec2 displacement = (vec2(height_dx, height_dy) - height) * amplitude;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - displacement);
}
