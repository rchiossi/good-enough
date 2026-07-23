shader_type canvas_item;

uniform vec4 flash_color: source_color = vec4(1.0f);
uniform float flash_percentage: hint_range(0.0, 1.0) = 0.0f;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	vec4 mixed_color = mix(original_color, flash_color, flash_percentage);
	mixed_color.a = original_color.a;
	
	COLOR = mixed_color;
}
