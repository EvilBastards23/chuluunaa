shader_type canvas_item;

// Sky projection shader for displaying presentation slides
// Creates a floating, semi-transparent projection effect

uniform sampler2D slide_texture : hint_default_white;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.1;
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;
uniform vec3 glow_color : source_color = vec3(0.5, 0.7, 1.0);

void fragment() {
	vec2 uv = UV;
	
	// Sample the slide texture
	vec4 slide_color = texture(slide_texture, uv);
	
	// Apply brightness and contrast
	slide_color.rgb = (slide_color.rgb - 0.5) * contrast + 0.5;
	slide_color.rgb *= brightness;
	
	// Create edge softness effect
	float edge_factor = 1.0;
	if (edge_softness > 0.0) {
		vec2 edge_distance = min(uv, 1.0 - uv);
		float min_edge = min(edge_distance.x, edge_distance.y);
		edge_factor = smoothstep(0.0, edge_softness, min_edge);
	}
	
	// Mix with edge color
	slide_color = mix(edge_color, slide_color, edge_factor);
	
	// Add subtle glow effect
	if (glow_intensity > 0.0) {
		vec3 glow = glow_color * glow_intensity * (1.0 - edge_factor);
		slide_color.rgb += glow;
	}
	
	// Apply alpha
	slide_color.a *= alpha * edge_factor;
	
	COLOR = slide_color;
}
