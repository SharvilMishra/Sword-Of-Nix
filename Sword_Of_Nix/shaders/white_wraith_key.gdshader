shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV) * COLOR;
	float green_dominance = color.g - max(color.r, color.b);
	float key = smoothstep(0.08, 0.24, green_dominance) * smoothstep(0.30, 0.72, color.g);
	color.a *= 1.0 - key;
	if (color.a < 0.015) {
		discard;
	}
	COLOR = color;
}
