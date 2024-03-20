shader_type canvas_item;
render_mode world_vertex_coords;

uniform float speed = 3.0;
uniform float magnitude = 10.0;

uniform int pixel_size = 8;

varying vec2 world_pos;

void vertex() {
	// Waviness
	world_pos = VERTEX;
	//VERTEX.x += sin(TIME * speed) * magnitude * (UV.y - 1.0) * (UV.y - 1.0) *  (UV.y - 1.0);
}

void fragment() {
	vec2 texture_size = vec2(textureSize(TEXTURE, 0));
	vec2 texture_position = world_pos - UV * texture_size;
	vec2 offset = texture_position / float(pixel_size) - vec2(ivec2(texture_position / float(pixel_size)));
	vec2 num_divisions = texture_size / float(pixel_size);
	vec2 pixel_uv = (vec2(ivec2( UV * texture_size / float(pixel_size) + offset )) + 0.5) / num_divisions;
	// read the texture using the highest LOD to avoid 
	// filtering problems on discontinuities
	COLOR = textureLod(TEXTURE, pixel_uv, 0);
}
