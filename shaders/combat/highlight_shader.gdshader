shader_type canvas_item;

uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float border_size_px = 2.0;
uniform float alpha : hint_range(0, 1) = 0.8;
uniform bool enabled = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (enabled) {
		// Convert UV (0.0 to 1.0) into actual pixel coordinates of the texture
		vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
		vec2 pixel_coord = UV * texture_size;
		
		// Calculate distance from all 4 borders (Left, Right, Top, Bottom)
		float dist_left = pixel_coord.x;
		float dist_right = texture_size.x - pixel_coord.x;
		float dist_top = pixel_coord.y;
		float dist_bottom = texture_size.y - pixel_coord.y;
		
		// Find the shortest distance to any border
		float min_dist = min(min(dist_left, dist_right), min(dist_top, dist_bottom));
		
		// If inside the 10px zone, replace or blend with the highlight color
		if (min_dist <= border_size_px) {
            COLOR = mix(tex_color, highlight_color, alpha);
			// COLOR = vec4(highlight_color.rgb, tex_color.a);
		} else {
			COLOR = tex_color;
		}
	} else {
		COLOR = tex_color;
	}
}