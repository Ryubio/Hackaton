// Sea region shader: mobile-optimized single-octave math for top water, glowing rim band, and walls.
// Healthy water is bright bioluminescent turquoise with caustics, sparkles and gentle waves;
// sick water turns dark, oily and reddish with damped waves and toxic veins.
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float health : hint_range(0.0, 1.0) = 0.6;
uniform float pollution : hint_range(0.0, 1.0) = 0.4;
uniform float highlight : hint_range(0.0, 1.0) = 0.0;
uniform float selected : hint_range(0.0, 1.0) = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform float pulse : hint_range(0.0, 1.0) = 0.0;
uniform float coral : hint_range(0.0, 1.0) = 0.6;
uniform float seagrass : hint_range(0.0, 1.0) = 0.6;
uniform int layer_mode = 0;
uniform float protection : hint_range(0.0, 1.0) = 0.0;
uniform float spread_risk : hint_range(0.0, 1.0) = 0.0;
uniform float biodiversity : hint_range(0.0, 1.0) = 0.5;
uniform float blue_carbon : hint_range(0.0, 1.0) = 0.0;
uniform float wave_phase = 0.0;
uniform float seed = 0.0;
uniform vec2 anchor = vec2(0.0, 0.0);
uniform vec3 healthy_color : source_color = vec3(0.098, 0.902, 0.757);
uniform vec3 crisis_color : source_color = vec3(1.0, 0.231, 0.188);
uniform vec3 warning_color : source_color = vec3(1.0, 0.784, 0.239);
uniform vec3 accent_color : source_color = vec3(0.91, 0.639, 0.239);
uniform vec3 pulse_color : source_color = vec3(0.098, 0.902, 0.757);
uniform vec2 label_center = vec2(0.0, 0.0);
uniform vec2 label_half = vec2(0.0, 0.0);
uniform float world_width = 69.12;

varying vec3 wpos;
varying float v_part;
varying float v_extra;

// Rotated warped interference waves for natural flowing mobile water (zero grid waffle)
float fast_wave_pattern(vec2 p, float t) {
	vec2 q = vec2(p.x * 0.82 - p.y * 0.57, p.x * 0.57 + p.y * 0.82);
	float w1 = sin(q.x * 1.35 + sin(q.y * 0.75 + t * 0.6) * 0.9 + t * 0.85);
	float w2 = sin(q.y * 1.75 + cos(q.x * 0.85 - t * 0.5) * 0.9 - t * 0.72);
	float w3 = sin((p.x * 0.95 - p.y * 1.55) + sin((p.x + p.y) * 0.6 + t * 0.4) * 0.8 + t * 1.05);
	return clamp(0.5 + 0.22 * w1 + 0.16 * w2 + 0.12 * w3, 0.0, 1.0);
}

float vis_health() {
	return smoothstep(0.28, 0.82, health);
}

float wave_amp(float vh) {
	return mix(0.02, 0.13, vh);
}

float waves(vec2 p, float t, float amp) {
	return amp * (sin(p.x * 0.9 + t * 1.3) * 0.55 + sin(p.y * 1.3 - t * 1.05) * 0.45);
}

vec3 status_color(float vh) {
	vec3 low = mix(crisis_color, warning_color, clamp(vh * 2.0, 0.0, 1.0));
	return mix(low, healthy_color, clamp(vh * 2.0 - 1.0, 0.0, 1.0));
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_part = UV.x;
	v_extra = UV.y;
	float vh = vis_health();
	VERTEX.y += waves(wpos.xz, wave_phase, wave_amp(vh)) * UV2.x;
}

void fragment() {
	vec2 p = wpos.xz;
	float t = TIME;
	float vh = vis_health();
	float sick = 1.0 - vh;
	vec3 scol = status_color(vh);
	float shield01 = clamp(protection / 0.65, 0.0, 1.0);
	float threat01 = clamp((1.0 - shield01) * 0.7 + spread_risk * 0.65, 0.0, 1.0);
	float bio01 = clamp(smoothstep(0.25, 0.85, biodiversity), 0.0, 1.0);
	vec3 layer_rim_col = scol;
	if (layer_mode == 1) {
		layer_rim_col = mix(vec3(0.14, 0.72, 0.98), mix(warning_color, crisis_color, spread_risk), threat01);
	} else if (layer_mode == 2) {
		vec3 gold_bio = mix(vec3(0.16, 0.20, 0.28), accent_color * 1.1, bio01);
		layer_rim_col = mix(gold_bio, healthy_color, blue_carbon * 0.85);
	}
	vec2 d_anch = p - anchor;
	vec2 d_lbl = p - label_center;
	if (world_width > 0.0) {
		float hw = world_width * 0.5;
		d_anch.x = mod(d_anch.x + hw, world_width) - hw;
		d_lbl.x = mod(d_lbl.x + hw, world_width) - hw;
	}
	float r = length(d_anch);

	float sel_w = fract(r * 0.22 - t * 0.35);
	float sel_ring = smoothstep(0.0, 0.03, sel_w) * (1.0 - smoothstep(0.03, 0.16, sel_w)) * selected;
	vec2 ld = abs(d_lbl);
	float under_label = (1.0 - smoothstep(label_half.x, label_half.x + 0.35, ld.x))
		* (1.0 - smoothstep(label_half.y, label_half.y + 0.35, ld.y));
	sel_ring *= 1.0 - under_label;
	float flash_ring = clamp(1.0 - abs(r - (1.0 - flash) * 9.0) * 0.6, 0.0, 1.0) * flash;
	float pulse_rad = (1.0 - pulse) * 10.0;
	float pulse_ring = clamp(1.0 - abs(r - pulse_rad) * 0.8, 0.0, 1.0) * pulse;

	if (v_part < 0.5) {
		float sh = clamp(v_extra, 0.0, 1.0);
		float shallow = 1.0 - smoothstep(0.0, 0.42, sh);
		float deep = smoothstep(0.35, 1.0, sh);

		vec3 h_shallow = healthy_color * 0.75 + vec3(0.02, 0.05, 0.05);
		vec3 h_mid = healthy_color * 0.26 + vec3(0.0, 0.015, 0.055);
		vec3 h_deep = vec3(0.004, 0.045, 0.1);
		vec3 water_h = mix(mix(h_mid, h_deep, deep), h_shallow, shallow);

		vec3 s_shallow = vec3(0.22, 0.085, 0.03);
		vec3 s_mid = crisis_color * 0.11 + vec3(0.035, 0.014, 0.01);
		vec3 s_deep = vec3(0.026, 0.009, 0.011);
		vec3 water_s = mix(mix(s_mid, s_deep, deep), s_shallow, shallow);
		vec3 water = mix(water_s, water_h, vh);

		float mid = 1.0 - abs(vh * 2.0 - 1.0);
		vec3 murk = warning_color * 0.16 + vec3(0.015, 0.035, 0.01);
		water = mix(water, murk, mid * 0.42);

		// Fast single-octave caustic & vein pattern
		float c1 = fast_wave_pattern(p * 1.1, t);
		float ridge = 1.0 - abs(c1 * 2.0 - 1.0);
		float caustic = ridge * ridge * ridge * vh * (0.35 + 0.65 * (1.0 - deep));

		float slick = smoothstep(0.45, 0.65, c1) * clamp(pollution * 0.85 + sick * 0.4 - 0.2, 0.0, 1.0);
		vec3 oil = vec3(0.03, 0.018, 0.028);

		float vein = ridge * ridge * ridge * sick * sick * (0.6 + 0.4 * sin(t * 2.2 - r * 0.5));
		float near_coast = 1.0 - smoothstep(0.15, 0.6, sh);
		float grass = smoothstep(0.55, 0.8, c1) * near_coast * seagrass;

		vec3 em = water * mix(0.62, 0.90, vh);
		float amp = wave_amp(vh);
		vec2 wg = vec2(cos(p.x * 0.9 + wave_phase * 1.3) * 0.5, cos(p.y * 1.3 - wave_phase * 1.05) * 0.5) * amp * 12.0;
		float sun_glint = pow(clamp(dot(normalize(vec3(-wg.x, 1.0, -wg.y)), normalize(vec3(-0.32, 0.82, 0.48))), 0.0, 1.0), 18.0) * vh * 0.48;
		em += healthy_color * caustic * 1.25 + vec3(0.82, 0.96, 1.0) * sun_glint;
		em = mix(em, oil, slick * 0.8);
		em += crisis_color * vein * 0.65;
		em += vec3(0.3, 1.0, 0.55) * grass * 0.3;
		if (layer_mode == 1) {
			float scan = 0.72 + 0.28 * sin(t * 2.8 - r * 0.45);
			vec3 shield_fill = mix(vec3(0.02, 0.14, 0.25), vec3(0.06, 0.42, 0.65), shallow);
			vec3 threat_fill = mix(warning_color * 0.26, crisis_color * 0.36, spread_risk) * scan;
			vec3 base_l = mix(shield_fill, threat_fill, threat01);
			float warn_stripe = smoothstep(0.55, 0.88, 0.5 + 0.5 * sin((p.x + p.y) * 2.0 - t * 1.6)) * threat01;
			em = mix(em * 0.25, base_l, 0.85) + crisis_color * warn_stripe * (0.14 + spread_risk * 0.28);
			em += vec3(0.15, 0.78, 1.0) * shield01 * (1.0 - threat01) * shallow * 0.25;
		} else if (layer_mode == 2) {
			float pulse_bio = 0.82 + 0.18 * sin(t * 1.9 + near_coast * 3.0);
			vec3 dim_sea = mix(vec3(0.015, 0.032, 0.075), vec3(0.03, 0.07, 0.14), shallow);
			vec3 blue_fill = healthy_color * mix(0.30, 0.62, near_coast) * blue_carbon * pulse_bio;
			vec3 gold_fill = accent_color * mix(0.24, 0.58, shallow) * bio01 * pulse_bio;
			em = em * 0.22 + dim_sea + blue_fill + gold_fill * (1.0 - blue_carbon * 0.45);
			em += healthy_color * grass * 0.75;
		}

		em = em * (1.0 + highlight * 0.55) + layer_rim_col * highlight * 0.035;
		em += accent_color * (sel_ring * 1.1 + selected * 0.025);
		em += pulse_color * pulse_ring * 1.6;
		em = mix(em, em * vec3(1.25, 0.28, 0.22) + crisis_color * 0.2, flash * 0.8);
		em += crisis_color * flash_ring * 1.4;
		ALBEDO = em;
	} else if (v_part < 1.5) {
		float along = UV2.y;
		float run = 0.78 + 0.22 * sin(along * 2.2 - t * 2.4);
		float across = 1.0 - v_extra * 0.65;
		vec3 rim = layer_rim_col * (1.0 + highlight * 1.6) * run * across;
		rim = mix(rim, accent_color * 2.2 * across, selected);
		rim += crisis_color * flash * 2.0;
		rim += pulse_color * pulse * 1.5;
		ALBEDO = rim;
	} else {
		float k = 1.0 - clamp(v_extra, 0.0, 1.0);
		float k2 = k * k;
		float glow = 0.06 + 0.7 * k2 * k2;
		vec3 wall = layer_rim_col * glow * (1.0 + highlight * 0.9);
		wall = mix(wall, accent_color * glow * 1.4, selected * 0.85);
		wall += crisis_color * flash * k2 * 1.2;
		ALBEDO = vec3(0.02) + wall;
	}
}
