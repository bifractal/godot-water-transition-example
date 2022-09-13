// MIT License
// Copyright (c) 2022 BIFRACTAL - Florian Roth

shader_type spatial;
render_mode unshaded, depth_test_disable;

/**
 * Fragment Shader
 */
void fragment()
{
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0f - 1.0f;
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0f);
	view.xyz /= view.w * 50.0f;
	float linear_depth = -view.z;
	
	ALBEDO = vec3(linear_depth, 0.0f, 0.0f);
}
