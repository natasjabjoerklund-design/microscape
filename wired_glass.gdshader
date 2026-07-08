shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 tint_color : source_color = vec3(0.55, 0.65, 0.68);
uniform vec3 grid_color : source_color = vec3(0.05, 0.05, 0.05);
uniform float cell_size = 0.12;
uniform float grid_width = 0.05;
uniform float glass_alpha : hint_range(0.0, 1.0) = 0.25;
uniform float roughness_amount : hint_range(0.0, 1.0) = 0.1;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX.xy;
}

void fragment() {
	// Object-space position (real units) instead of UV, so the grid is
	// square and evenly spaced regardless of the face's aspect ratio.
	vec2 cell = fract(local_pos / cell_size);
	float grid = step(cell.x, grid_width) + step(1.0 - grid_width, cell.x)
		+ step(cell.y, grid_width) + step(1.0 - grid_width, cell.y);
	grid = clamp(grid, 0.0, 1.0);

	ALBEDO = mix(tint_color, grid_color, grid);
	ROUGHNESS = roughness_amount;
	METALLIC = 0.1;
	ALPHA = mix(glass_alpha, 1.0, grid);
}
