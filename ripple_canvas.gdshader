shader_type canvas_item;

uniform sampler2D simulation_texture;
uniform float amplitude;


void fragment() {
	COLOR = texture(simulation_texture, UV);
	
	if (false && COLOR.r > 0.0f) {
		vec4 tex = texture(simulation_texture, UV);
		vec4 tex_dx = texture(simulation_texture, UV + vec2(0.01, 0.0));
		vec4 tex_dy = texture(simulation_texture, UV + vec2(0.0, 0.01));
		float height = tex.r - tex.g;
		float height_dx = tex_dx.r - tex_dx.g;
		float height_dy = tex_dy.r - tex_dy.g;
		NORMAL = COLOR.r * normalize((vec3(height_dx - height, 1.0, height_dx - height) / 0.01)) + (1.0f - COLOR.r) * NORMAL;
	}
	
	//float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	//ALBEDO = water_color.rgb + (0.1f * fresnel);
}
