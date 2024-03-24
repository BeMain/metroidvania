shader_type canvas_item;

/// How much the blade is displaced.
uniform float displacement = 0.0;

void vertex() {
	// Displace along a circle
	float angle = displacement * PI / 2.0;
	float radius = 1.0 / TEXTURE_PIXEL_SIZE.y;
	VERTEX += vec2(sin(angle), 1.0 - cos(angle)) * radius * (1.0 - UV.y);
}
