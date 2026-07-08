shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.13, 0.13, 0.14);
uniform vec3 seam_color : source_color = vec3(0.05, 0.05, 0.06);
uniform vec3 accent_color : source_color = vec3(0.15, 0.9, 0.3);
uniform float panel_scale = 2.0;
uniform float seam_width = 0.04;
uniform float accent_width = 0.015;
uniform float metallic_amount : hint_range(0.0, 1.0) = 0.6;
uniform float roughness_amount : hint_range(0.0, 1.0) = 0.45;
uniform float brushed_strength : hint_range(0.0, 1.0) = 0.15;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV * panel_scale;
	vec2 cell = fract(uv);
	vec2 cell_id = floor(uv);

	// Panel seam border
	float seam = step(cell.x, seam_width) + step(1.0 - seam_width, cell.x)
		+ step(cell.y, seam_width) + step(1.0 - seam_width, cell.y);
	seam = clamp(seam, 0.0, 1.0);

	// Thin glowing accent pinstripe near the bottom of each panel
	float accent = step(0.48, cell.y) * step(cell.y, 0.48 + accent_width);

	// Fine brushed-metal streaks, varying per panel column
	float brushed = (hash(vec2(floor(UV.y * 400.0), cell_id.x)) - 0.5) * brushed_strength;

	vec3 color = mix(base_color, seam_color, seam);
	color = mix(color, accent_color, accent * 0.6);
	color += brushed;

	ALBEDO = color;
	METALLIC = metallic_amount;
	ROUGHNESS = clamp(roughness_amount - brushed * 0.3, 0.0, 1.0);
	EMISSION = accent_color * accent * 0.4;
}
