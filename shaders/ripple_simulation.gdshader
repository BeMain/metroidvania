shader_type canvas_item;
render_mode unshaded;

uniform float a;
uniform float amplitude;
uniform vec2 grid_points;

uniform sampler2D z_tex;
uniform sampler2D old_z_tex;

uniform sampler2D collision_texture;
uniform sampler2D old_collision_texture;

uniform sampler2D land_texture;

/// Wave height is multiplied by this.
const float damping = 1.0f;

/// Waves below this treshold are removed.
const float treshold = 0.008f;

void fragment() {
	vec2 pix_size = vec2(1.0f) / grid_points;
	
	vec4 z = a * (texture(z_tex, UV + vec2(pix_size.x, 0.0f))
				+ texture(z_tex, UV - vec2(pix_size.x, 0.0f))
				+ texture(z_tex, UV + vec2(0.0f, pix_size.y)) 
				+ texture(z_tex, UV - vec2(0.0f, pix_size.y)))
			+ (2.0f - 4.0f * a) * (texture(z_tex, UV)) - (texture(old_z_tex, UV));
	z *= damping;
	
	vec3 collision_state_old = texture(old_collision_texture, UV).rgb;
	vec3 collision_state_new = texture(collision_texture, UV).rgb;
	
	// Each channel represents one 'type' of sound.
	vec3 new_z = z.rgb;
	
	if (length(collision_state_new) > 0.0f && length(collision_state_old) == 0.0f) {
		new_z = amplitude * collision_state_new;
	}
	
	float land = texture(land_texture, UV).r;
	if (UV.x <= pix_size.x || UV.x >= 1.0f - pix_size.x  // Avoid waves bouncing on the borders
	 || UV.y <= pix_size.y || UV.y >= 1.0f - pix_size.y
	 || land > 0.0f  // Remove waves that collide with land masses
	) {
		new_z = vec3(0.0f);
	}
	if (new_z.r < treshold) new_z.r = 0.0f;
	if (new_z.g < treshold) new_z.g = 0.0f;
	if (new_z.b < treshold) new_z.b = 0.0f;
	
	COLOR = vec4(new_z, 1.0);
}