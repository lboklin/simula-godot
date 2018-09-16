shader_type spatial;
//render_mode blend_add, diffuse_lambert_wrap;

uniform vec4 atmosphere_color : hint_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float atmosphere_amount = 0.5;


/* Support Functions */

float blendSoftLight(float base, float blend) {
	return (blend<0.5)?(2.0*base*blend+base*base*(1.0-2.0*blend)):(sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend));
}

vec3 softLight(vec3 base, vec3 blend) {
	return vec3(blendSoftLight(base.r,blend.r),blendSoftLight(base.g,blend.g),blendSoftLight(base.b,blend.b));
}

float blendOverlay(float base, float blend) {
	return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}

vec3 hardLight(vec3 base, vec3 blend) {
	return vec3(blendOverlay(blend.r,base.r),blendOverlay(blend.g,base.g),blendOverlay(blend.b,base.b));
}


/* The lighting, including atmospheric effects */
void light(){
	float surface_light_amt = clamp(dot(LIGHT, NORMAL) - 0.2, 0.0, 1.0);
	vec3 surface = hardLight(vec3(surface_light_amt), ALBEDO*0.5);
	
	float scattered_light_amt = dot(LIGHT, normalize(mix(NORMAL, TRANSMISSION, atmosphere_amount)));
	scattered_light_amt = clamp(scattered_light_amt * 0.5 + 0.3, 0.0, 1.0);
	scattered_light_amt = sign(scattered_light_amt) * pow(scattered_light_amt, 3.0);
	vec3 scattered_light = softLight(vec3(scattered_light_amt), atmosphere_color.rgb);
	
	float atmo_thickness = 1.0 - dot(TRANSMISSION, VIEW);
	float atmo_light = atmo_thickness * (dot(TRANSMISSION, LIGHT) * 0.5 + atmosphere_amount * 1.0);
	atmo_light = pow(atmo_light, 3.0);
	vec3 atmo = vec3(atmo_light) + atmo_light * atmosphere_color.rgb;
	atmo = atmo * atmosphere_amount;
	
	
	
	DIFFUSE_LIGHT = mix(surface, scattered_light, pow(atmosphere_amount, 4.0));
	DIFFUSE_LIGHT = mix(DIFFUSE_LIGHT, atmo, atmo_thickness);
}


void fragment(){
	TRANSMISSION = NORMAL;
    ALBEDO=vec3(0,0,0);
    ALPHA=atmosphere_color.a;
}