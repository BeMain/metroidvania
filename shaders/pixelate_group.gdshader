shader_type canvas_item;
render_mode unshaded, world_vertex_coords;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform int pixel_size = 4;

/// The zoom level of the root viewport
uniform vec2 zoom = vec2(1.0);

varying vec2 world_pos;

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	vec2 screen_size = vec2(textureSize(screen_texture, 0));
	vec2 screen_position = zoom * world_pos - SCREEN_UV * screen_size;
	vec2 pixel = zoom * floor(world_pos / float(pixel_size) + 0.5);
	vec2 relative_pixel = pixel - screen_position / float(pixel_size);
	vec2 pixel_uv = (relative_pixel) * float(pixel_size) / screen_size;
	
	// read the texture using the highest LOD to avoid 
	// filtering problems on discontinuities
	vec4 c = textureLod(screen_texture, pixel_uv, 0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	COLOR *= c;
}
