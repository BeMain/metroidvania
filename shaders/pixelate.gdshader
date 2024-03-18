shader_type canvas_item;
render_mode unshaded;

uniform int pixel_size = 8;

void fragment()
{
	vec2 num_divisions = vec2(textureSize(TEXTURE, 0)) / float(pixel_size);
	vec2 pixel_uv = (vec2(ivec2( UV * num_divisions ))+0.5) / num_divisions;
	// read the texture using the highest LOD to avoid 
	// filtering problems on discontinuities
	COLOR = textureLod( TEXTURE, pixel_uv, 0);; 
}
