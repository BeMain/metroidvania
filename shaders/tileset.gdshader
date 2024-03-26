shader_type canvas_item;

uniform vec4 old_colors[4]:source_color;
uniform vec4 new_colors[4]:source_color;
uniform float threshold;

bool similar(vec4 col1, vec4 col2, float t) {
	for (int i = 0; i < 4; i++) {
		if (abs(col1[i] - col2[i]) > t) {
			return false;
		}
	}
	return true;
}

void fragment() {
	for (int i = 0; i < 4; i++) {
		if (similar(COLOR, old_colors[i], threshold)) {
			COLOR = new_colors[i];
		}
	}
}