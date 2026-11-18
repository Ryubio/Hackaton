// Tactical terrain shader shared by three opaque map layers (uniform "layer"):
// 0 = deep-sea floor with a faint lat/lon grid, sonar ping from HQ and vignette falloff,
// 1 = raised dark land slabs with faint topographic contours and terracotta cliff glow,
// 2 = thin amber/terracotta glowing coastline ribbons.
// Mesh contract (map_builder.gd): land UV.x = part (0 top, 2 wall), UV.y = wall depth 0..1;
// coast UV.x = distance along the coast, UV.y = 0..1 across the ribbon.
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform int layer = 0;
uniform vec3 bg_color : source_color = vec3(0.043, 0.059, 0.098);
uniform vec3 deep_color : source_color = vec3(0.03, 0.06, 0.1);
uniform vec3 grid_color : source_color = vec3(0.2, 0.42, 0.5);
uniform vec3 land_color : source_color = vec3(0.09, 0.1, 0.13);
uniform vec3 cliff_color : source_color = vec3(0.78, 0.357, 0.224);
uniform vec3 coast_color : source_color = vec3(0.91, 0.639, 0.239);
uniform vec3 ping_color : source_color = vec3(0.91, 0.639, 0.239);
uniform vec2 focus = vec2(1.5, 1.0);
uniform vec2 hero = vec2(16.7, 2.75);
uniform float fade_near = 20.0;
uniform float fade_far = 36.0;
uniform float coast_energy = 2.2;
uniform float world_width = 69.12;

varying vec3 wpos;
varying vec3 v_norm;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.5 * vnoise(p);
	p = mat2(vec2(0.8, -0.6), vec2(0.6, 0.8)) * p * 2.07 + vec2(3.1, 7.3);
	v += 0.25 * vnoise(p);
	return v * 1.333;
}

// Anti-aliased line mask for integer crossings of coord, width in pixels.
float line_mask(float coord, float width_px) {
	float w = max(fwidth(coord), 1e-4);
	float d = abs(fract(coord - 0.5) - 0.5) / w;
	return 1.0 - clamp(d / width_px, 0.0, 1.0);
}

// Geographic grid: inverse Miller projection centered at 155E (same as region.gd & build_world_map.gd).
vec2 grid_masks(vec2 p) {
	float lon = p.x / 0.192 + 155.0;
	float my = -p.y / 15.84079;
	float lat = degrees(2.5 * atan(exp(clamp(my * 0.8, -4.0, 4.0))) - 1.9634954);
	float major = max(line_mask(lon / 15.0, 1.1), line_mask(lat / 15.0, 1.1));
	float minor = max(line_mask(lon / 5.0, 0.8), line_mask(lat / 5.0, 0.8));
	return vec2(major, minor);
}

float vignette(vec2 p) {
	vec2 df = p - focus;
	if (world_width > 0.0) {
		float hw = world_width * 0.5;
		df.x = mod(df.x + hw, world_width) - hw;
	}
	float d = length(df * vec2(0.8, 1.0));
	return 1.0 - smoothstep(fade_near, fade_far, d);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_norm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 p = wpos.xz;
	float fade = vignette(p);
	vec3 col;
	vec3 sun_dir = normalize(vec3(-0.60, 0.66, -0.45));
	if (layer == 0) {
		// deep-sea floor
		float n = fbm(p * 0.18 + vec2(TIME * 0.004, 0.0));
		vec3 base = deep_color * (0.75 + 0.5 * n);
		vec2 g = grid_masks(p);
		col = base + grid_color * (g.x * 0.12 + g.y * 0.035);
		// slow sonar ping expanding from the HQ hero position
		vec2 dh = p - hero;
		if (world_width > 0.0) {
			float hw = world_width * 0.5;
			dh.x = mod(dh.x + hw, world_width) - hw;
		}
		float r = length(dh);
		float front = fract(TIME / 11.0) * 48.0;
		float ping = exp(-abs(r - front) * 1.6) * (1.0 - front / 48.0);
		col += ping_color * ping * 0.12;
		// fine scan lines drifting north
		float scan = 0.5 + 0.5 * sin(p.y * 2.2 + TIME * 0.6);
		col *= 0.92 + 0.08 * scan;
	} else if (layer == 1) {
		if (UV.x < 1.0) {
			// 3D sculpted terrain top (mobile-efficient single fbm + analytic mesh slope normal)
			float e0 = fbm(p * 0.42 + vec2(5.2, 1.3));
			vec3 surf_n = normalize(v_norm + vec3(dFdx(e0) * 1.4, 0.0, dFdy(e0) * 1.4));
			float elev = clamp((wpos.y - 0.72) / 1.35, 0.0, 1.0);
			float ndl = dot(surf_n, sun_dir);
			float shade = 0.48 + 0.85 * clamp(ndl, 0.0, 1.0) - 0.12 * clamp(-ndl, 0.0, 1.0);
			vec3 lowland = land_color * 1.02;
			vec3 upland = mix(lowland, land_color * 1.32 + vec3(0.032, 0.028, 0.025), smoothstep(0.12, 0.72, elev));
			vec3 alpine = mix(upland, vec3(0.19, 0.22, 0.27), smoothstep(0.72, 1.0, elev));
			col = alpine * shade * (0.86 + 0.24 * e0);
			float contour = line_mask(wpos.y * 5.2, 0.75);
			col += cliff_color * contour * 0.038;
			vec2 g = grid_masks(p);
			col += grid_color * (g.x * 0.038 + g.y * 0.01);
		} else {
			// 3D extruded cliff wall: directional sunlit/shadowed facets + upper rim + abyssal base
			float k = 1.0 - clamp(UV.y, 0.0, 1.0);
			vec3 wn = normalize(v_norm);
			float wlit = clamp(dot(wn, normalize(vec3(-0.62, 0.25, -0.74))), -0.5, 1.0);
			float facet = 0.45 + 0.75 * max(wlit, 0.0) - 0.16 * max(-wlit, 0.0);
			float k2 = k * k;
			col = land_color * facet * (0.35 + 0.65 * k) + cliff_color * (k2 * k2) * (0.65 + 0.55 * max(wlit, 0.0));
		}
	} else {
		// coastline ribbon: hot core, gentle shimmer travelling along the coast
		float across = 1.0 - abs(UV.y * 2.0 - 1.0);
		float shimmer = 0.8 + 0.2 * sin(UV.x * 0.7 - TIME * 1.2);
		vec3 hue = mix(cliff_color, coast_color, 0.55 + 0.45 * sin(UV.x * 0.13 + 1.7));
		col = hue * coast_energy * shimmer * (0.55 + 0.45 * across);
	}
	ALBEDO = mix(bg_color, col, fade);
}
