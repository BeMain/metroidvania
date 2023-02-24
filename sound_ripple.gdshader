shader_type canvas_item;

/// The strength of the distortion
uniform float force;
/// The center of the ripple
uniform vec2 center;
/// The size of the ripples
uniform float size;
/// The thickness or width of the ripple
uniform float thickness;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float screen_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = ( SCREEN_UV - vec2(0.5, 0.0) ) / vec2(screen_ratio, 1.0) + vec2(0.5, 0.0);
	vec2 scaled_center = ( center - vec2(0.5, 0.0) ) / vec2(screen_ratio, 1.0) + vec2(0.5, 0.0);
	float outer_mask = 1.0 - smoothstep(size-0.1, size, length(scaled_uv - scaled_center));
	float inner_mask = smoothstep(size-thickness-0.1, size-thickness, length(scaled_uv - scaled_center));
	float mask = outer_mask * inner_mask; 
	vec2 displacement = normalize(scaled_uv - scaled_center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - displacement);
}
