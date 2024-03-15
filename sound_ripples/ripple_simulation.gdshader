shader_type canvas_item;

uniform float a;
uniform float amplitude;
uniform vec2 grid_points;

uniform sampler2D z_tex;
uniform sampler2D old_z_tex;

uniform sampler2D collision_texture;
uniform sampler2D old_collision_texture;

uniform sampler2D land_texture;

/// Wave height is multiplied by this.
const float damping = 0.99f;

/// Waves below this treshold are removed.
const float treshold = 0.008f;

void fragment() {
	vec2 pix_size = vec2(1.0f)/grid_points;
	
	vec4 z = a * (texture(z_tex, UV + vec2(pix_size.x, 0.0f))
				+ texture(z_tex, UV - vec2(pix_size.x, 0.0f))
				+ texture(z_tex, UV + vec2(0.0f, pix_size.y)) 
				+ texture(z_tex, UV - vec2(0.0f, pix_size.y)))
			+ (2.0f - 4.0f * a) * (texture(z_tex, UV)) - (texture(old_z_tex, UV));
	z *= damping;
				
	float z_new_pos = z.r; // positive waves are stored in the red channel
	float z_new_neg = z.g; // negative waves are stored in the green channel
	
	float collision_state_old = texture(old_collision_texture, UV).r;
	float collision_state_new = texture(collision_texture, UV).r;
	
	if (collision_state_new > 0.0f && collision_state_old == 0.0f) {
		z_new_pos = amplitude * collision_state_new;
	} else if (collision_state_new == 0.0f && collision_state_old > 0.0f) {
		z_new_neg = amplitude * collision_state_old;
	}
	
	
	float land = texture(land_texture, UV).r;
	if (UV.x <= pix_size.x || UV.x >= 1.0f - pix_size.x  // Avoid waves bouncing on the borders
	 || UV.y <= pix_size.y || UV.y >= 1.0f - pix_size.y
	 || land > 0.0f  // Remove waves that collide with land masses
	 || length(vec2(z_new_pos, z_new_neg)) < treshold
	) {
		z_new_pos = 0.0f;
		z_new_neg = 0.0f;
	}
	
	COLOR = vec4(z_new_pos, 0.0f, z_new_neg, 1.0f);
}