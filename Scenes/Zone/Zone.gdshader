// This shader is based on Minionsart's stylized fire
// https://twitter.com/minionsart/status/1132593681452683264?s=20
shader_type spatial;
render_mode blend_mix;

uniform sampler2D noise_texture;

uniform sampler2D texture_mask;
uniform float emission_intensity = 2.0;
uniform float time_scale = 3.0;
uniform vec2 texture_scale = vec2(1.0);
uniform float edge_softness = 0.1;

varying vec3 world_coord;
varying float world_x_dot;


void vertex() {
	mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	mat_world = mat_world * mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
	
	world_coord = (mat_world * vec4(VERTEX, 1.0)).rgb;
	vec4 world_normal = (mat_world * vec4(NORMAL, 0.0));
	world_x_dot =  abs(dot(normalize(world_normal.rgb), vec3(1.0,0.0,0.0)));
}


void fragment() {
	float mask = texture(texture_mask, UV).r;
	
	vec2 time_based_pan = vec2(0.2, 1.0) * (- TIME * time_scale);
	float noise_xy = texture(noise_texture, world_coord.xy * texture_scale + time_based_pan).r;
	float noise_zy = texture(noise_texture, world_coord.zy * texture_scale + time_based_pan + vec2(0.7, 0.3)).r;
	
	float noise = mix(noise_xy, noise_zy, clamp(world_x_dot, 0.0, 1.0));
	
	ALBEDO = COLOR.rgb;
	EMISSION = ALBEDO * emission_intensity;
	
	float erosion_amount = (1.0 - COLOR.a);
	float alpha = (noise * mask) - erosion_amount;
	
	alpha = clamp(alpha, 0.0, 1.0);
	ALPHA = smoothstep(0.0, edge_softness, alpha);
}