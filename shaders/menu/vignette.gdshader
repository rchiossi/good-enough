shader_type canvas_item;

// --- SETTINGS ---
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// How far from the center the darkness starts (0.0 = center, 1.0 = edges)
uniform float radius : hint_range(0.0, 2.0) = 0.7;

// How smooth the transition is (Hard vs Soft edge)
uniform float softness : hint_range(0.0, 2.0) = 0.5;

// Strength of the darkening effect
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

// Set this to true to force a perfect circle, false for an oval that fits the screen
uniform bool correct_aspect_ratio = false; 

void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv = UV;
	
	// OPTIONAL: Fix Aspect Ratio so the vignette is a perfect circle
	if (correct_aspect_ratio) {
		float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
		// We stretch the UV on the X axis to counteract the screen width
		uv.x = (uv.x - 0.5) * aspect + 0.5; 
		// Note: This effectively zooms the UV out on the X axis
		center.x = 0.5; // Center remains effectively 0.5
	}

	// Calculate distance from center
	float dist = distance(uv, center);
	
	// Generate the vignette alpha
	// smoothstep(min, max, value) returns 0.0 if value < min, 1.0 if value > max
	// We want the reverse: clear at center (low dist), dark at edges (high dist)
	float vignette = smoothstep(radius, radius + softness, dist);
	
	// Apply intensity and color
	COLOR = vec4(vignette_color.rgb, vignette * intensity);
}