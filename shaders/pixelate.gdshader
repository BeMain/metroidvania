/// Pixelates a node according to a unviersal grid, where each pixel is of size [pixel_size].
/// Note that this does not work for scaled nodes. For that, use the PixelateGroup node.

shader_type canvas_item;
render_mode world_vertex_coords;

/// The size of the pixels
uniform int pixel_size = 4;

varying vec2 world_pos;

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 texture_position = world_pos - UV * texture_size;
	vec2 pixel = floor(world_pos / float(pixel_size));
	vec2 relative_pixel = pixel - texture_position / float(pixel_size);
	vec2 pixel_uv = (relative_pixel) * float(pixel_size) / texture_size;
	
	// read the texture using the highest LOD to avoid 
	// filtering problems on discontinuities
	COLOR = textureLod(TEXTURE, pixel_uv, 0);
}
