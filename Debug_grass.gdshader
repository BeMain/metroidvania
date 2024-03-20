shader_type canvas_item;
render_mode world_vertex_coords;

uniform float speed = 3.0;
uniform float magnitude = 10.0;

void vertex() {
	// Waviness
	VERTEX.x += sin(TIME * speed) * magnitude * (UV.y - 1.0) * (UV.y - 1.0) *  (UV.y - 1.0);
}


