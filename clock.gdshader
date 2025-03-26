shader_type canvas_item;

const float SMOOTHING = 1.5;
const float RING_THICKNESS = 0.1;

varying flat vec4 clock_data;

uniform vec3 second_color : source_color = vec3(0.5, 0.0, 0.0);
uniform vec3 minute_color : source_color = vec3(0.0, 0.5, 0.0);
uniform vec3 hour_color : source_color = vec3(0.0, 0.0, 0.5);

//void fragment(){
	//// Clock radius at fragment, normalized so it is 1.0 at its face edge.
	//float radius = 2.0 * length(UV-vec2(0.5)); // x,y from center i.e. 0.5 on both axis
	//COLOR = vec4(1.0);
	//COLOR.rgb *= radius;
	//if (radius > 1.0) {
		//COLOR.w *= 0.0; // don't render beyond radius
	//}
//}
float smooth_above(float threshold, float value) {
	return smoothstep(threshold, threshold + fwidth(SMOOTHING*value), value);
}

float smooth_below(float threshold, float value) {
	return smoothstep(threshold, threshold - fwidth(SMOOTHING*value), value);
}

float ring_weight(float start_radius, float radius) {
	return ( 
		smooth_above(start_radius, radius) *
		smooth_below(start_radius + RING_THICKNESS, radius)
	);
}

vec3 add_ring(vec3 color, vec3 ring_color, float start_radius, float radius) {
	return mix(color, ring_color, ring_weight(start_radius, radius));
}

void vertex() {
	clock_data = COLOR;
}

void fragment() {
	float choice = clock_data.w;
	COLOR.rgb = texture(
		TEXTURE,
		vec2(
			choice > 0.5 ? UV.x : 1.0 - UV.x, // randomized x mirroring
			choice < 0.25 || choice > 0.75 ? UV.y : 1.0 - UV.y // randomized y mirroring
		)).rgb;
	float radius = 2.0 * length(UV - vec2(0.5)); // normalized radius
	
	// create rings
	COLOR.rgb = add_ring(COLOR.rgb, second_color, clock_data.r, radius);
	COLOR.rgb = add_ring(COLOR.rgb, minute_color, clock_data.g, radius);
	COLOR.rgb = add_ring(COLOR.rgb, hour_color, clock_data.b, radius);

	// set alpha based on radius
	COLOR.a = smooth_below(1.0, radius);
}