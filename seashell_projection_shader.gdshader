shader_type canvas_item;

// Seashell projector shader for realistic projection effects
// Creates a more focused, projector-like appearance

uniform sampler2D slide_texture : hint_default_white;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float intensity : hint_range(0.0, 3.0) = 1.0;
uniform vec3 projection_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float focus_sharpness : hint_range(0.0, 1.0) = 0.8;
uniform float edge_falloff : hint_range(0.0, 0.5) = 0.1;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;
uniform float light_bleed : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 uv = UV;
	
	// Sample the slide texture
	vec4 slide_color = texture(slide_texture, uv);
	
	// Apply intensity and color tint
	slide_color.rgb *= intensity * projection_color;
	
	// Create edge falloff effect (like a real projector)
	float edge_factor = 1.0;
	if (edge_falloff > 0.0) {
		vec2 edge_distance = min(uv, 1.0 - uv);
		float min_edge = min(edge_distance.x, edge_distance.y);
		edge_factor = smoothstep(0.0, edge_falloff, min_edge);
	}
	
	// Add vignette effect (darker edges like real projectors)
	float vignette = 1.0;
	if (vignette_strength > 0.0) {
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(uv, center);
		vignette = 1.0 - smoothstep(0.3, 0.7, dist) * vignette_strength;
	}
	
	// Apply focus sharpness (slight blur at edges)
	if (focus_sharpness < 1.0) {
		vec2 center = vec2(0.5, 0.5);
		float dist_from_center = distance(uv, center);
		float focus_factor = smoothstep(0.0, 0.5, 1.0 - dist_from_center);
		focus_factor = mix(0.8, 1.0, focus_factor * focus_sharpness);
		slide_color.rgb *= focus_factor;
	}
	
	// Add subtle light bleed effect
	if (light_bleed > 0.0) {
		vec3 bleed_color = projection_color * light_bleed * 0.1;
		slide_color.rgb += bleed_color;
	}
	
	// Combine all effects
	slide_color.rgb *= edge_factor * vignette;
	slide_color.a *= alpha * edge_factor;
	
	COLOR = slide_color;
}
