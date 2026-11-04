shader_type canvas_item;

uniform float alpha_cutoff = 0.90;

void fragment() {
	vec4 sampled = texture(TEXTURE, UV);
	if (sampled.a < alpha_cutoff) {
		discard;
	}
	COLOR = sampled * COLOR;
}
