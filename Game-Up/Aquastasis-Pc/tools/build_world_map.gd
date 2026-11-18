extends SceneTree
## Tool script: generates Natural Earth 1:110m simplified continent (LAND) and 12 global ocean
## region polygons on a 360-degree seamless periodic Miller-cylindrical projection centered at 155E
## (lon in [-25, +335], WORLD_W = 69.12), height-compensated for 3D oblique camera viewing so
## continents keep natural globe proportions without vertical squashing. Exports to res://scripts/region.gd
## and res://tools/generated_land.txt.
## Run: godot --headless --path . -s res://tools/build_world_map.gd

const GEOJSON_PATH := "res://tools/ne_110m_land.geojson"
const CENTER_LON := 155.0
const SEAM_MIN_LON := -25.0
const SEAM_MAX_LON := 335.0
const SCALE_X := 0.192
const SCALE_Y_MILLER := 0.192 * (180.0 / PI) * 1.44
const WORLD_W := 360.0 * SCALE_X          # 69.12 exact 360 deg period
const HALF_W := WORLD_W * 0.5             # 34.56


static func proj(lon: float, lat: float) -> Vector2:
	var phi: float = deg_to_rad(clampf(lat, -79.0, 80.5))
	var my: float = 1.25 * log(tan(PI * 0.25 + 0.40 * phi))
	return Vector2((lon - CENTER_LON) * SCALE_X, -my * SCALE_Y_MILLER)


static func proj_poly(pts_ll: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for pt in pts_ll:
		out.append(proj(float(pt[0]), float(pt[1])))
	return out


static func signed_area(poly: PackedVector2Array) -> float:
	var s: float = 0.0
	var n: int = poly.size()
	for i in n:
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		s += a.x * b.y - b.x * a.y
	return s * 0.5


static func ensure_ccw(poly: PackedVector2Array) -> PackedVector2Array:
	if signed_area(poly) < 0.0:
		var rev := PackedVector2Array()
		for i in range(poly.size() - 1, -1, -1):
			rev.append(poly[i])
		return rev
	return poly


static func densify(poly: PackedVector2Array, step: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n: int = poly.size()
	for i in n:
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		var segs: int = maxi(1, ceili(a.distance_to(b) / step))
		for s in segs:
			out.append(a.lerp(b, float(s) / float(segs)))
	return out


static func can_triangulate(poly: PackedVector2Array, check_dense: bool = false) -> bool:
	if poly.size() < 3:
		return false
	if Geometry2D.triangulate_polygon(poly).size() < 3:
		return false
	if check_dense:
		if Geometry2D.triangulate_polygon(densify(poly, 0.45)).size() < 3:
			return false
		if Geometry2D.triangulate_polygon(densify(poly, 1.50)).size() < 3:
			return false
	return true


static func sanitize_poly(raw: PackedVector2Array) -> Array:
	var grown: Array = Geometry2D.offset_polygon(raw, 0.012, Geometry2D.JOIN_MITER)
	var out_polys: Array = []
	for g in grown:
		var gp: PackedVector2Array = g
		if Geometry2D.is_polygon_clockwise(gp):
			continue
		var shrunk: Array = Geometry2D.offset_polygon(gp, -0.012, Geometry2D.JOIN_MITER)
		for s in shrunk:
			var sp: PackedVector2Array = s
			if not Geometry2D.is_polygon_clockwise(sp) and absf(signed_area(sp)) >= 0.05:
				out_polys.append(ensure_ccw(sp))
	return out_polys


static func clean_poly(poly: PackedVector2Array, min_dist: float = 0.04, eps: float = 0.025, check_dense: bool = false) -> PackedVector2Array:
	var pts: PackedVector2Array = ensure_ccw(poly)
	if pts.size() <= 4:
		return pts
	var changed: bool = true
	while changed and pts.size() > 4:
		changed = false
		var n: int = pts.size()
		for i in n:
			var prev: Vector2 = pts[(i - 1 + n) % n]
			var cur: Vector2 = pts[i]
			var nxt: Vector2 = pts[(i + 1) % n]
			var c: Vector2 = Geometry2D.get_closest_point_to_segment(cur, prev, nxt)
			if cur.distance_to(prev) < min_dist or cur.distance_to(c) < eps:
				var cand := pts.duplicate()
				cand.remove_at(i)
				if can_triangulate(cand, check_dense):
					pts = cand
					changed = true
					break
	var rounded := PackedVector2Array()
	for p in pts:
		rounded.append(Vector2(snappedf(p.x, 0.01), snappedf(p.y, 0.01)))
	if can_triangulate(rounded, check_dense):
		return ensure_ccw(rounded)
	return ensure_ccw(pts)


## Subdivides a lon/lat chain and applies deterministic multi-octave jagged displacement
## normal to the chain tangent. Endpoints t=0 and t=1 are pinned (displacement=0) so shared
## triple junctions and 360-degree periodic wrap points match cleanly.
static func make_jagged_edge(waypoints: Array, edge_seed: int, amp_deg: float = 1.25, step_deg: float = 1.45, saw_amp: float = 0.38) -> Array:
	var n: int = waypoints.size()
	if n < 2:
		return waypoints.duplicate()
	# Cumulative arc length in degrees
	var cum: Array = [0.0]
	var total_len: float = 0.0
	for i in range(1, n):
		var a := Vector2(float(waypoints[i - 1][0]), float(waypoints[i - 1][1]))
		var b := Vector2(float(waypoints[i][0]), float(waypoints[i][1]))
		total_len += a.distance_to(b)
		cum.append(total_len)
	if total_len < 0.25:
		return waypoints.duplicate()

	var steps: int = maxi(3, ceili(total_len / step_deg))
	var samples: Array = []
	for s in range(steps + 1):
		var target_d: float = total_len * float(s) / float(steps)
		var seg_i: int = 0
		while seg_i < n - 2 and cum[seg_i + 1] < target_d:
			seg_i += 1
		var d0: float = cum[seg_i]
		var d1: float = cum[seg_i + 1]
		var f: float = (target_d - d0) / maxf(d1 - d0, 0.0001)
		var pa := Vector2(float(waypoints[seg_i][0]), float(waypoints[seg_i][1]))
		var pb := Vector2(float(waypoints[seg_i + 1][0]), float(waypoints[seg_i + 1][1]))
		samples.append(pa.lerp(pb, clampf(f, 0.0, 1.0)))

	var out: Array = []
	var ph1: float = float(edge_seed * 1.73 + 0.4)
	var ph2: float = float(edge_seed * 3.17 + 1.9)
	var ph3: float = float(edge_seed * 5.91 + 0.7)
	var k1: float = 2.0 + float(edge_seed % 3)
	var k2: float = 5.0 + float((edge_seed * 2) % 4)
	var k3: float = 11.0 + float((edge_seed * 3) % 5)

	for s in range(samples.size()):
		var p: Vector2 = samples[s]
		if s == 0 or s == samples.size() - 1:
			out.append([p.x, p.y])
			continue
		var t: float = float(s) / float(samples.size() - 1)
		var env: float = sin(PI * t)
		# Fade near ends so vertices stay crisp inside small straits
		env = clampf(env * 1.35, 0.0, 1.0)
		var prev_p: Vector2 = samples[s - 1]
		var next_p: Vector2 = samples[s + 1]
		var tang: Vector2 = (next_p - prev_p).normalized()
		var nrm := Vector2(-tang.y, tang.x)
		var wave: float = (
			0.58 * sin(t * TAU * k1 + ph1)
			+ 0.34 * cos(t * TAU * k2 + ph2)
			+ 0.24 * sin(t * TAU * k3 + ph3)
		)
		# Quasi-random deterministic per-vertex jitter (non-uniform craggy serrations)
		var h1: float = sin(float(s) * 12.9898 + ph1 * 7.13) * 43758.5453
		var jitter: float = (fposmod(absf(h1), 1.0) * 2.0 - 1.0) * saw_amp * 1.15
		var zig: float = (1.0 if (s % 2 == 1) else -1.0) * saw_amp * 0.45 + jitter
		var disp: float = env * (amp_deg * wave + zig)
		var q: Vector2 = p + nrm * disp
		q.y = clampf(q.y, -79.5, 81.5)
		out.append([q.x, q.y])
	return out


## Periodic 360-degree jagged curve where s=0 (lon=-25) and s=N (lon=335) have identical y offset.
static func make_periodic_edge(waypoints: Array, edge_seed: int, amp_deg: float = 1.6, step_deg: float = 2.4, saw_amp: float = 0.55) -> Array:
	var n: int = waypoints.size()
	var cum: Array = [0.0]
	var total_len: float = 0.0
	for i in range(1, n):
		var a := Vector2(float(waypoints[i - 1][0]), float(waypoints[i - 1][1]))
		var b := Vector2(float(waypoints[i][0]), float(waypoints[i][1]))
		total_len += a.distance_to(b)
		cum.append(total_len)
	var steps: int = maxi(24, ceili(total_len / step_deg))
	var out: Array = []
	var ph1: float = float(edge_seed * 1.37)
	var ph2: float = float(edge_seed * 2.71)
	var ph3: float = float(edge_seed * 4.43)
	for s in range(steps + 1):
		var t: float = float(s) / float(steps)
		var target_d: float = total_len * t
		var seg_i: int = 0
		while seg_i < n - 2 and cum[seg_i + 1] < target_d:
			seg_i += 1
		var d0: float = cum[seg_i]
		var d1: float = cum[seg_i + 1]
		var f: float = (target_d - d0) / maxf(d1 - d0, 0.0001)
		var pa := Vector2(float(waypoints[seg_i][0]), float(waypoints[seg_i][1]))
		var pb := Vector2(float(waypoints[seg_i + 1][0]), float(waypoints[seg_i + 1][1]))
		var p: Vector2 = pa.lerp(pb, clampf(f, 0.0, 1.0))
		# Strictly periodic at t=0 and t=1 -> sin/cos of integer multiples of TAU!
		var edge_taper: float = sin(PI * t)  # keeps seam endpoints exact for clean joining
		var wave: float = (
			0.50 * sin(t * TAU * 7.0 + ph1)
			+ 0.30 * cos(t * TAU * 13.0 + ph2)
			+ 0.22 * sin(t * TAU * 23.0 + ph3)
		)
		var zig: float = (1.0 if (s % 2 == 1 and s > 0 and s < steps) else (-1.0 if (s > 0 and s < steps) else 0.0)) * saw_amp
		var lat: float = clampf(p.y + (amp_deg * wave + zig) * clampf(edge_taper * 4.0, 0.0, 1.0), -76.0, 80.5)
		out.append([p.x, lat])
	return out


static func append_chain(ring: Array, chain: Array, rev: bool = false, shift_lon: float = 0.0) -> void:
	var pts: Array = chain.duplicate()
	if rev:
		pts.reverse()
	for pt in pts:
		var lon: float = float(pt[0]) + shift_lon
		var lat: float = float(pt[1])
		if ring.is_empty():
			ring.append([lon, lat])
		else:
			var last: Array = ring[ring.size() - 1]
			if absf(lon - float(last[0])) > 0.01 or absf(lat - float(last[1])) > 0.01:
				ring.append([lon, lat])


static func clip_against_list(base_poly: PackedVector2Array, cutters: Array) -> PackedVector2Array:
	var current: PackedVector2Array = ensure_ccw(base_poly)
	for cutter in cutters:
		var cp: PackedVector2Array = cutter
		var res: Array = Geometry2D.clip_polygons(current, cp)
		var best := PackedVector2Array()
		var best_area: float = 0.0
		for part in res:
			var cand: PackedVector2Array = part
			if Geometry2D.is_polygon_clockwise(cand):
				continue
			var a: float = absf(signed_area(cand))
			if a > best_area:
				best_area = a
				best = cand
		if best.size() >= 3:
			current = ensure_ccw(best)
	return current


static func intersect_seam_box(poly: PackedVector2Array) -> PackedVector2Array:
	var box := PackedVector2Array([
		Vector2(-HALF_W, -30.0),
		Vector2(-HALF_W, 30.0),
		Vector2(HALF_W, 30.0),
		Vector2(HALF_W, -30.0),
	])
	var res: Array = Geometry2D.intersect_polygons(ensure_ccw(poly), ensure_ccw(box))
	var best := PackedVector2Array()
	var best_area: float = 0.0
	for part in res:
		var cand: PackedVector2Array = part
		if Geometry2D.is_polygon_clockwise(cand):
			continue
		var a: float = absf(signed_area(cand))
		if a > best_area:
			best_area = a
			best = cand
	if best.size() >= 3:
		return ensure_ccw(best)
	return ensure_ccw(poly)


static func format_vec2_array(poly: PackedVector2Array, indent: String) -> String:
	var lines: Array = []
	var cur: Array = []
	for i in poly.size():
		var p: Vector2 = poly[i]
		cur.append("Vector2(%.2f, %.2f)" % [p.x, p.y])
		if cur.size() == 5 or i == poly.size() - 1:
			lines.append(indent + ", ".join(cur) + ",")
			cur.clear()
	return "\n".join(lines)


func _init() -> void:
	var raw_text: String = FileAccess.get_file_as_string(GEOJSON_PATH)
	var data: Dictionary = JSON.parse_string(raw_text)
	var features: Array = data.get("features", [])

	var land_polys: Array = []
	var mainlands: Array = []
	var feat91_poly := PackedVector2Array()
	var feat112_poly := PackedVector2Array()

	for i in features.size():
		var feat: Dictionary = features[i]
		var geom: Dictionary = feat["geometry"]
		var rings: Array = []
		if geom["type"] == "Polygon":
			rings.append(geom["coordinates"][0])
		elif geom["type"] == "MultiPolygon":
			for p in geom["coordinates"]:
				rings.append(p[0])
		for r in rings:
			# Antarctica (feature 7): continuous 360 deg ribbon sliced strictly at [-25, +335]
			if i == 7:
				var coast1: Array = []
				for pt in r:
					var lon: float = float(pt[0])
					var lat: float = float(pt[1])
					if lat > -89.5:
						coast1.append([lon, lat])
				if coast1.size() > 2 and float(coast1[0][0]) > float(coast1[coast1.size() - 1][0]):
					coast1.reverse()
				var ant_ll: Array = [[-30.0, -83.0]]
				var prev_lon: float = -999.0
				for pass_idx in 3:
					var offset_lon: float = float(pass_idx - 1) * 360.0
					for pt in coast1:
						var lon: float = float(pt[0]) + offset_lon
						var lat: float = clampf(float(pt[1]), -78.5, -60.0)
						if lon >= -28.0 and lon <= 338.0 and lon >= prev_lon - 2.0:
							ant_ll.append([lon, lat])
							prev_lon = maxf(prev_lon, lon)
				ant_ll.append([338.0, -83.0])
				for sp in sanitize_poly(proj_poly(ant_ll)):
					var clipped_ant := intersect_seam_box(sp)
					var cp: PackedVector2Array = clean_poly(clipped_ant, 0.05, 0.035)
					if can_triangulate(cp):
						land_polys.append(cp)
						mainlands.append(cp)
				continue

			var min_lon: float = 999.0
			for pt in r:
				min_lon = minf(min_lon, float(pt[0]))
			# Keep Europe/Africa/Iceland (min_lon >= -25.0) on tile 0; shift Americas/Greenland (< -25) by +360
			var shift: float = 360.0 if min_lon < SEAM_MIN_LON else 0.0
			var pts_ll: Array = []
			for pt_idx in r.size():
				var pt: Array = r[pt_idx]
				var lon: float = float(pt[0]) + shift
				var lat: float = clampf(float(pt[1]), -83.0, 83.5)
				if i == 112:
					if pt_idx >= 776 and pt_idx <= 779:
						lat -= 0.60 # Morocco side of Gibraltar
					elif pt_idx >= 1038 and pt_idx <= 1041:
						lat += 0.60 # Spain side of Gibraltar
					elif pt_idx >= 867 and pt_idx <= 871:
						lat -= 0.65 # Anatolia side of Dardanelles/Bosporus
						lon += 0.45
					elif pt_idx >= 922 and pt_idx <= 929:
						lat += 0.65 # Thrace side of Dardanelles/Bosporus
						lon -= 0.45
					elif pt_idx >= 365 and pt_idx <= 368:
						lat += 0.70 # Iran side of Hormuz
					elif pt_idx >= 404 and pt_idx <= 409:
						lat -= 0.70 # Oman/UAE side of Hormuz
					elif pt_idx >= 454 and pt_idx <= 459:
						lon += 0.70 # Yemen side of Bab-el-Mandeb
						lat += 0.65
					elif pt_idx >= 521 and pt_idx <= 527:
						lon -= 0.70 # Djibouti/Eritrea side of Bab-el-Mandeb
						lat -= 0.65
				pts_ll.append([lon, lat])
			var raw_p: PackedVector2Array = proj_poly(pts_ll)
			if i == 91:
				feat91_poly = raw_p
			elif i == 112:
				feat112_poly = raw_p
			else:
				for sp in sanitize_poly(raw_p):
					var cp: PackedVector2Array = clean_poly(sp, 0.045, 0.03)
					if can_triangulate(cp) and absf(signed_area(cp)) >= 0.05:
						land_polys.append(cp)
						if i in [21, 95, 126]:
							mainlands.append(cp)

	if feat112_poly.size() >= 3 and feat91_poly.size() >= 3:
		var exp91: Array = Geometry2D.offset_polygon(feat91_poly, 0.05)
		var m_list: Array = Geometry2D.merge_polygons(feat112_poly, exp91[0] if exp91.size() > 0 else feat91_poly)
		for mp in m_list:
			var cand: PackedVector2Array = mp
			if Geometry2D.is_polygon_clockwise(cand):
				continue
			for sp in sanitize_poly(cand):
				var cp: PackedVector2Array = clean_poly(sp, 0.05, 0.035)
				if can_triangulate(cp) and absf(signed_area(cp)) >= 1.0:
					land_polys.push_front(cp)
					mainlands.push_front(cp)

	# Build mainland cutters across tile 0 AND +WORLD_W/+360 deg so Atlantic polygons
	# spanning [-85..+20E] (+275..+380) clip accurately against Europe & Africa coastlines!
	var mainland_cutters: Array = []
	for ml in mainlands:
		var poly_ml: PackedVector2Array = ml
		var off: Array = Geometry2D.offset_polygon(poly_ml, 0.04, Geometry2D.JOIN_MITER)
		for o in off:
			var op: PackedVector2Array = o
			if not Geometry2D.is_polygon_clockwise(op) and absf(signed_area(op)) >= 0.05:
				var c0 := ensure_ccw(op)
				mainland_cutters.append(c0)
				# Also add +WORLD_W shifted copy for Atlantic polygons reaching 335..382 deg lon
				var c_east := PackedVector2Array()
				for pt in c0:
					c_east.append(pt + Vector2(WORLD_W, 0.0))
				mainland_cutters.append(c_east)

	# --- Shared Organic Jagged Maritime Boundaries (lon/lat) -------------------------------
	# Every ocean-to-ocean boundary is computed ONCE and shared (forward/reverse) by neighbors.

	# 1. Polar Front in Northern Hemisphere (Arctic <-> North Atlantic / North Pacific)
	var e_arc_west := make_jagged_edge([
		[335.0, 66.0], [340.5, 65.2], [347.0, 63.8], [354.5, 62.6], [362.5, 62.2], [368.0, 62.5]
	], 11, 1.15, 1.5, 0.40) # Seam to Norway (on tile 0 Atlantic: 335..368)
	var e_arc_east := make_jagged_edge([
		[296.5, 63.2], [302.5, 63.6], [310.0, 61.5], [317.5, 59.5], [326.0, 63.2], [335.0, 66.0]
	], 12, 1.20, 1.5, 0.42) # Davis Strait to Seam (on tile 0 Atlantic: 296.5..335)
	var e_arc_bering := make_jagged_edge([
		[196.5, 65.5], [191.5, 64.8], [186.5, 65.4], [181.0, 64.5], [174.5, 65.2]
	], 13, 0.85, 1.3, 0.32) # Alaska -> Bering Strait -> Chukotka

	# 2. Antarctic Polar Front (Southern Ocean north edge; exact -25 == 335 wrap!)
	var e_polar_satl := make_jagged_edge([
		[295.0, -58.5], [305.0, -54.5], [318.0, -51.5], [335.0, -47.0]
	], 21, 1.45, 1.8, 0.48)
	var e_polar_satl_e := make_jagged_edge([
		[335.0, -47.0], [348.0, -45.5], [364.0, -46.2], [380.0, -47.0]
	], 22, 1.45, 1.8, 0.48)
	var e_polar_ind := make_jagged_edge([
		[20.0, -47.0], [45.0, -45.0], [72.0, -46.5], [102.0, -45.2], [128.0, -46.8], [146.0, -49.5]
	], 23, 1.55, 1.8, 0.50)
	var e_polar_spac := make_jagged_edge([
		[146.0, -49.5], [174.0, -51.0], [208.0, -47.5], [242.0, -48.5], [272.0, -52.5], [295.0, -58.5]
	], 24, 1.55, 1.8, 0.50)

	# 3. Atlantic boundaries
	var e_natl_carib := make_jagged_edge([
		[278.5, 27.0], [283.0, 25.5], [292.5, 20.8], [299.8, 18.2], [301.2, 14.0], [298.8, 9.0]
	], 31, 0.90, 1.3, 0.34)
	var e_natl_satl := make_jagged_edge([
		[310.0, 1.0], [317.0, 3.2], [326.0, 6.2], [336.0, 4.4], [345.0, 7.2], [352.5, 6.0]
	], 32, 1.35, 1.6, 0.45)
	var e_gib_med_natl := make_jagged_edge([
		[-6.8, 37.2], [-7.0, 35.9], [-6.8, 34.8]
	], 33, 0.32, 0.5, 0.14)
	var e_satl_ind := make_jagged_edge([
		[20.0, -34.2], [21.6, -39.2], [18.8, -43.2], [20.0, -47.0]
	], 34, 1.05, 1.3, 0.36)
	var e_spac_satl := make_jagged_edge([
		[291.0, -54.0], [293.0, -56.2], [295.0, -58.5]
	], 35, 0.65, 1.0, 0.24)

	# 4. Indian / Red & Arabian / Coral / East Asian boundaries
	var e_arab_ind := make_jagged_edge([
		[49.0, 11.6], [56.0, 10.4], [64.0, 7.2], [72.0, 8.6], [77.8, 8.6]
	], 41, 1.15, 1.4, 0.38)
	var e_ind_coral := make_jagged_edge([
		[97.5, 16.5], [95.0, 9.0], [94.8, 4.8], [100.5, -4.0], [108.5, -8.8], [122.5, -11.2], [126.5, -16.0]
	], 42, 1.15, 1.5, 0.38)
	var e_ind_spac := make_jagged_edge([
		[146.5, -42.5], [148.2, -46.0], [146.0, -49.5]
	], 43, 0.70, 1.0, 0.25)

	# 5. Coral / East Asian / Pacific boundaries
	var e_coral_easian := make_jagged_edge([
		[108.0, 19.0], [114.5, 19.8], [121.0, 21.0]
	], 51, 0.75, 1.1, 0.28)
	var e_easian_npac := make_jagged_edge([
		[121.0, 21.0], [127.5, 23.0], [135.5, 29.2], [144.2, 36.0], [149.8, 43.8], [161.5, 55.0]
	], 52, 1.15, 1.5, 0.38)
	var e_coral_npac := make_jagged_edge([
		[155.0, 3.0], [143.5, 10.8], [134.0, 16.8], [121.0, 21.0]
	], 53, 1.15, 1.5, 0.38)
	var e_coral_spac := make_jagged_edge([
		[142.5, -10.8], [152.5, -10.2], [157.5, -4.8], [155.0, 3.0]
	], 54, 1.05, 1.4, 0.36)
	var e_npac_spac := make_jagged_edge([
		[155.0, 3.0], [174.0, 5.6], [194.0, 2.4], [216.0, 6.0], [238.0, 3.0], [260.0, 6.4], [283.5, 6.5]
	], 55, 1.45, 1.8, 0.48)

	# Assemble closed region boundary loops (in [lon, lat])
	var rings_ll := {}

	# mediterranean: inland around Europe/Black Sea/Levant/N.Africa + Gibraltar edge
	rings_ll["mediterranean"] = []
	append_chain(rings_ll["mediterranean"], e_gib_med_natl, true)
	append_chain(rings_ll["mediterranean"], [[-6.8, 29.5], [36.5, 29.5], [37.5, 38.0], [43.0, 40.2], [43.0, 47.8], [26.0, 47.8], [12.0, 46.2], [2.0, 44.2], [-6.8, 37.2]])

	# red_arabian: Suez/Persian Gulf inland + shared Arabian Sea boundary + Oman/India inland
	rings_ll["red_arabian"] = []
	append_chain(rings_ll["red_arabian"], e_arab_ind, false)
	append_chain(rings_ll["red_arabian"], [[77.8, 24.0], [66.0, 26.8], [47.5, 31.2], [31.5, 30.5], [31.5, 22.0], [39.0, 12.0], [49.0, 11.6]])

	# indian: Cape Agulhas -> Arabia -> Burma/Java -> Timor/W.Australia inland -> Tasmania -> Polar Front
	rings_ll["indian"] = []
	append_chain(rings_ll["indian"], e_satl_ind, false)
	append_chain(rings_ll["indian"], e_polar_ind, false)
	append_chain(rings_ll["indian"], e_ind_spac, true)
	append_chain(rings_ll["indian"], [[138.0, -34.0], [132.0, -25.0], [126.5, -16.0]])
	append_chain(rings_ll["indian"], e_ind_coral, true)
	append_chain(rings_ll["indian"], [[96.0, 23.5], [77.8, 23.5], [77.8, 8.6]])
	append_chain(rings_ll["indian"], e_arab_ind, true)
	append_chain(rings_ll["indian"], [[42.0, 8.0], [38.0, -5.0], [28.0, -24.0], [20.0, -34.2]])

	# coral_triangle: Java Trench -> Thailand/China inland -> Luzon -> Palau -> Solomons -> Cape York/Outback inland
	rings_ll["coral_triangle"] = []
	append_chain(rings_ll["coral_triangle"], e_ind_coral, false)
	append_chain(rings_ll["coral_triangle"], [[132.0, -21.5], [141.0, -21.5], [142.5, -18.0], [142.5, -10.8]])
	append_chain(rings_ll["coral_triangle"], e_coral_spac, false)
	append_chain(rings_ll["coral_triangle"], e_coral_npac, false)
	append_chain(rings_ll["coral_triangle"], e_coral_easian, true)
	append_chain(rings_ll["coral_triangle"], [[98.0, 18.5], [97.5, 16.5]])

	# east_asian: Hainan/China inland -> Siberia inland -> Kamchatka -> Kurils -> Taiwan -> Hainan
	rings_ll["east_asian"] = []
	append_chain(rings_ll["east_asian"], e_coral_easian, false)
	append_chain(rings_ll["east_asian"], e_easian_npac, false)
	append_chain(rings_ll["east_asian"], [[160.0, 61.5], [135.0, 60.0], [115.0, 42.0], [100.0, 23.0], [108.0, 19.0]])

	# north_pacific: Chukotka inland -> Bering Strait -> N.America coast inland -> Panama -> Equatorial Pacific -> Palau -> Luzon -> Kamchatka
	rings_ll["north_pacific"] = []
	append_chain(rings_ll["north_pacific"], e_easian_npac, true)
	append_chain(rings_ll["north_pacific"], e_coral_npac, true)
	append_chain(rings_ll["north_pacific"], e_npac_spac, false)
	append_chain(rings_ll["north_pacific"], [[283.5, 6.5], [279.0, 12.0], [268.0, 16.5], [258.0, 21.0], [244.0, 36.0], [225.0, 63.0], [196.5, 65.5]])
	append_chain(rings_ll["north_pacific"], e_arc_bering, false)
	append_chain(rings_ll["north_pacific"], [[166.0, 62.0], [161.5, 55.0]])

	# south_pacific: Cape York -> Solomons -> Equatorial Pacific -> S.America Andes inland -> Drake Passage -> Polar Front -> Tasmania -> Australia east coast inland
	rings_ll["south_pacific"] = []
	append_chain(rings_ll["south_pacific"], e_coral_spac, false)
	append_chain(rings_ll["south_pacific"], e_npac_spac, false)
	append_chain(rings_ll["south_pacific"], [[288.0, -8.0], [292.0, -34.0], [291.0, -54.0]])
	append_chain(rings_ll["south_pacific"], e_spac_satl, false)
	append_chain(rings_ll["south_pacific"], e_polar_spac, true)
	append_chain(rings_ll["south_pacific"], e_ind_spac, true)
	append_chain(rings_ll["south_pacific"], [[146.5, -36.0], [142.5, -18.0], [142.5, -10.8]])

	# caribbean: Mexico/Panama/Colombia inland + Antilles arc + Florida inland
	rings_ll["caribbean"] = []
	append_chain(rings_ll["caribbean"], e_natl_carib, false)
	append_chain(rings_ll["caribbean"], [[292.0, 8.0], [282.0, 8.0], [262.0, 19.0], [261.0, 31.0], [278.5, 31.0], [278.5, 27.0]])

	# north_atlantic: spans seamlessly [276..374] (= [-84W..+14E])
	# American coast -> Florida -> Antilles -> Amazon -> Equator -> Sierra Leone/Morocco -> Gibraltar (+360) -> Iberia/France/NorthSea/Norway -> Arctic Front
	rings_ll["north_atlantic"] = []
	append_chain(rings_ll["north_atlantic"], e_natl_carib, false)
	append_chain(rings_ll["north_atlantic"], [[298.8, 9.0], [306.0, 4.0], [310.0, 1.0]])
	append_chain(rings_ll["north_atlantic"], e_natl_satl, false)
	append_chain(rings_ll["north_atlantic"], [[353.2, 22.0], [353.2, 34.8]])
	append_chain(rings_ll["north_atlantic"], e_gib_med_natl, true, 360.0)
	append_chain(rings_ll["north_atlantic"], [[356.0, 40.0], [362.0, 44.0], [372.0, 52.0], [372.0, 62.5], [368.0, 62.5]])
	append_chain(rings_ll["north_atlantic"], e_arc_west, true)
	append_chain(rings_ll["north_atlantic"], e_arc_east, true)
	append_chain(rings_ll["north_atlantic"], [[285.0, 62.0], [275.0, 45.0], [278.5, 30.0], [278.5, 27.0]])

	# south_atlantic: spans seamlessly [290..382] (= [-70W..+22E])
	# S.America inland -> Equator -> W.Africa inland -> Cape Agulhas (+360) -> Polar Front -> Drake -> Cape Horn
	rings_ll["south_atlantic"] = []
	append_chain(rings_ll["south_atlantic"], [[291.0, -54.0], [295.0, -34.0], [310.0, -5.0], [310.0, 1.0]])
	append_chain(rings_ll["south_atlantic"], e_natl_satl, false)
	append_chain(rings_ll["south_atlantic"], [[366.0, 5.0], [374.0, -8.0], [378.0, -24.0], [380.0, -34.2]])
	append_chain(rings_ll["south_atlantic"], e_satl_ind, false, 360.0)
	append_chain(rings_ll["south_atlantic"], e_polar_satl_e, true)
	append_chain(rings_ll["south_atlantic"], e_polar_satl, true)
	append_chain(rings_ll["south_atlantic"], e_spac_satl, true)

	# arctic: full 360 deg polar band [-25..+335] bounded south by Arctic Front + Eurasia/N.America inland (incl Hudson Bay)
	rings_ll["arctic"] = []
	append_chain(rings_ll["arctic"], e_arc_west, false, -360.0) # [-25..+8]
	append_chain(rings_ll["arctic"], [[174.5, 65.2]])           # crosses inland N.Russia
	append_chain(rings_ll["arctic"], e_arc_bering, true)        # [174.5..196.5]
	append_chain(rings_ll["arctic"], [[278.0, 55.0], [288.0, 58.0], [296.5, 63.2]]) # Hudson Bay & Labrador
	append_chain(rings_ll["arctic"], e_arc_east, false)         # [296.5..335]
	rings_ll["arctic"].append([338.0, 66.0])
	rings_ll["arctic"].append([338.0, 82.5])
	rings_ll["arctic"].append([-28.0, 82.5])
	rings_ll["arctic"].append([-28.0, 66.0])
	rings_ll["arctic"].append([-25.0, 66.0])

	# southern: full 360 deg polar band [-25..+335] bounded north by Antarctic Polar Front + south by -83
	rings_ll["southern"] = []
	append_chain(rings_ll["southern"], e_polar_satl_e, false, -360.0) # [-25..+20]
	append_chain(rings_ll["southern"], e_polar_ind, false)            # [20..146]
	append_chain(rings_ll["southern"], e_polar_spac, false)           # [146..295]
	append_chain(rings_ll["southern"], e_polar_satl, false)           # [295..335]
	rings_ll["southern"].append([338.0, -47.0])
	rings_ll["southern"].append([338.0, -83.0])
	rings_ll["southern"].append([-28.0, -83.0])
	rings_ll["southern"].append([-28.0, -47.0])
	rings_ll["southern"].append([-25.0, -47.0])

	var anchors_ll := {
		"north_atlantic": [323.0, 35.0],
		"south_atlantic": [345.0, -21.0],
		"caribbean": [286.0, 15.8],
		"mediterranean": [18.5, 35.2],
		"red_arabian": [61.5, 16.0],
		"indian": [74.0, -20.0],
		"coral_triangle": [127.5, -5.5],
		"east_asian": [134.5, 38.0],
		"north_pacific": [198.0, 32.0],
		"south_pacific": [212.0, -22.0],
		"arctic": [165.0, 73.5],
		"southern": [165.0, -61.5],
	}

	var coastal_pops := {
		"north_atlantic": 0.75,
		"south_atlantic": 0.55,
		"caribbean": 0.80,
		"mediterranean": 0.85,
		"red_arabian": 0.75,
		"indian": 0.85,
		"coral_triangle": 0.90,
		"east_asian": 1.05,
		"north_pacific": 0.70,
		"south_pacific": 0.45,
		"arctic": 0.25,
		"southern": 0.15,
	}

	var heat_sens := {
		"north_atlantic": 0.90,
		"south_atlantic": 0.85,
		"caribbean": 1.15,
		"mediterranean": 1.05,
		"red_arabian": 1.15,
		"indian": 1.00,
		"coral_triangle": 1.30,
		"east_asian": 0.95,
		"north_pacific": 0.90,
		"south_pacific": 1.10,
		"arctic": 1.35,
		"southern": 1.15,
	}

	var region_ids := [
		"north_atlantic", "south_atlantic", "caribbean", "mediterranean",
		"red_arabian", "indian", "coral_triangle", "east_asian",
		"north_pacific", "south_pacific", "arctic", "southern"
	]

	var region_polys := {}
	var region_anchors := {}
	for rid in region_ids:
		var raw_cell: PackedVector2Array = proj_poly(rings_ll[rid])
		var inset_cells: Array = Geometry2D.offset_polygon(raw_cell, -0.055, Geometry2D.JOIN_MITER)
		var cell: PackedVector2Array = ensure_ccw(inset_cells[0]) if not inset_cells.is_empty() else raw_cell
		var clipped: PackedVector2Array = clip_against_list(cell, mainland_cutters)
		var san: Array = sanitize_poly(clipped)
		var best := clipped
		var best_a: float = 0.0
		for ins in san:
			var cand: PackedVector2Array = ins
			var a: float = absf(signed_area(cand))
			if a > best_a:
				best_a = a
				best = cand
		var cleaned: PackedVector2Array = clean_poly(best, 0.035, 0.015, false)
		if rid == "arctic" or rid == "southern":
			cleaned = intersect_seam_box(cleaned)
		if not can_triangulate(cleaned, true):
			cleaned = clean_poly(cleaned, 0.04, 0.02, true)
			if rid == "arctic" or rid == "southern":
				cleaned = intersect_seam_box(cleaned)
		region_polys[rid] = cleaned
		var anc: Vector2 = proj(float(anchors_ll[rid][0]), float(anchors_ll[rid][1]))
		region_anchors[rid] = Vector2(snappedf(anc.x, 0.01), snappedf(anc.y, 0.01))

	# Generate scripts/region.gd
	var reg_lines: Array = [
		"extends RefCounted",
		"## RegionData: static geography of the 12 global ocean regions (polygons generated from",
		"## Natural Earth 1:110m via tools/build_world_map.gd, anchors, routes, coastal weights,",
		"## heat sensitivity) plus the live 0-100 state of one region. Pure logic, no nodes.",
		"## Map plane coordinates: x = east, y = south (3D: Vector3(x, 0, y)); north is far from camera.",
		"",
		"const B := preload(\"res://scripts/balance.gd\")",
		"",
		"const WORLD_W := %.2f" % WORLD_W,
		"const HALF_W := %.2f" % HALF_W,
		"",
		"const IDS := [",
		"\t\"north_atlantic\", \"south_atlantic\", \"caribbean\", \"mediterranean\",",
		"\t\"red_arabian\", \"indian\", \"coral_triangle\", \"east_asian\",",
		"\t\"north_pacific\", \"south_pacific\", \"arctic\", \"southern\",",
		"]",
		"const HERO_ID := \"mediterranean\"",
		"",
		"## Miller cylindrical height-compensated world projection centered at 155E (lon in [-25, 335],",
		"## period WORLD_W): natural proportions under 3D oblique camera without vertical squashing.",
		"const DEFS := {",
	]
	for rid in region_ids:
		var anc: Vector2 = region_anchors[rid]
		var poly: PackedVector2Array = region_polys[rid]
		reg_lines.append("\t\"%s\": {" % rid)
		reg_lines.append("\t\t\"name_key\": \"region.%s.name\"," % rid)
		reg_lines.append("\t\t\"species_key\": \"region.%s.species\"," % rid)
		reg_lines.append("\t\t\"coastal_pop\": %.2f," % float(coastal_pops[rid]))
		reg_lines.append("\t\t\"heat_sensitivity\": %.2f," % float(heat_sens[rid]))
		reg_lines.append("\t\t\"anchor\": Vector2(%.2f, %.2f)," % [anc.x, anc.y])
		reg_lines.append("\t\t\"polygon\": [")
		reg_lines.append(format_vec2_array(poly, "\t\t\t"))
		reg_lines.append("\t\t],")
		reg_lines.append("\t},")
	reg_lines.append("}")
	reg_lines.append("")
	reg_lines.append("## Global ocean currents and major shipping lanes (Gulf Stream, Kuroshio, Antarctic")
	reg_lines.append("## Circumpolar Current, Gibraltar, Suez, Panama, Malacca, Cape Agulhas, etc.).")
	reg_lines.append("const ROUTES := [")
	reg_lines.append("\t{\"a\": \"caribbean\", \"b\": \"north_atlantic\", \"kind\": \"current\", \"weight\": 0.85},")
	reg_lines.append("\t{\"a\": \"north_atlantic\", \"b\": \"arctic\", \"kind\": \"current\", \"weight\": 0.75},")
	reg_lines.append("\t{\"a\": \"north_atlantic\", \"b\": \"south_atlantic\", \"kind\": \"current\", \"weight\": 0.70},")
	reg_lines.append("\t{\"a\": \"mediterranean\", \"b\": \"north_atlantic\", \"kind\": \"shipping\", \"weight\": 0.80},")
	reg_lines.append("\t{\"a\": \"caribbean\", \"b\": \"south_atlantic\", \"kind\": \"shipping\", \"weight\": 0.65},")
	reg_lines.append("\t{\"a\": \"caribbean\", \"b\": \"north_pacific\", \"kind\": \"shipping\", \"weight\": 0.80},")
	reg_lines.append("\t{\"a\": \"caribbean\", \"b\": \"south_pacific\", \"kind\": \"shipping\", \"weight\": 0.75},")
	reg_lines.append("\t{\"a\": \"north_pacific\", \"b\": \"arctic\", \"kind\": \"current\", \"weight\": 0.70},")
	reg_lines.append("\t{\"a\": \"east_asian\", \"b\": \"north_pacific\", \"kind\": \"current\", \"weight\": 0.90},")
	reg_lines.append("\t{\"a\": \"coral_triangle\", \"b\": \"east_asian\", \"kind\": \"shipping\", \"weight\": 0.85},")
	reg_lines.append("\t{\"a\": \"coral_triangle\", \"b\": \"north_pacific\", \"kind\": \"current\", \"weight\": 0.75},")
	reg_lines.append("\t{\"a\": \"coral_triangle\", \"b\": \"south_pacific\", \"kind\": \"current\", \"weight\": 0.80},")
	reg_lines.append("\t{\"a\": \"north_pacific\", \"b\": \"south_pacific\", \"kind\": \"current\", \"weight\": 0.70},")
	reg_lines.append("\t{\"a\": \"indian\", \"b\": \"coral_triangle\", \"kind\": \"shipping\", \"weight\": 0.90},")
	reg_lines.append("\t{\"a\": \"red_arabian\", \"b\": \"indian\", \"kind\": \"current\", \"weight\": 0.85},")
	reg_lines.append("\t{\"a\": \"mediterranean\", \"b\": \"red_arabian\", \"kind\": \"shipping\", \"weight\": 0.90},")
	reg_lines.append("\t{\"a\": \"south_atlantic\", \"b\": \"indian\", \"kind\": \"current\", \"weight\": 0.75},")
	reg_lines.append("\t{\"a\": \"indian\", \"b\": \"southern\", \"kind\": \"current\", \"weight\": 0.75},")
	reg_lines.append("\t{\"a\": \"south_pacific\", \"b\": \"southern\", \"kind\": \"current\", \"weight\": 0.80},")
	reg_lines.append("\t{\"a\": \"south_atlantic\", \"b\": \"southern\", \"kind\": \"current\", \"weight\": 0.80},")
	reg_lines.append("]")
	reg_lines.append("")
	reg_lines.append("var id: String = \"\"")
	reg_lines.append("var name_key: String = \"\"")
	reg_lines.append("var species_key: String = \"\"")
	reg_lines.append("var polygon: PackedVector2Array = PackedVector2Array()")
	reg_lines.append("var anchor: Vector2 = Vector2.ZERO")
	reg_lines.append("var coastal_pop: float = 0.0")
	reg_lines.append("var heat_sensitivity: float = 1.0")
	reg_lines.append("")
	reg_lines.append("var pollution: float = 0.0")
	reg_lines.append("var coral_health: float = 0.0")
	reg_lines.append("var seagrass: float = 0.0")
	reg_lines.append("var fish_stock: float = 0.0")
	reg_lines.append("var awareness: float = 0.0")
	reg_lines.append("var protection: float = 0.0")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func _init(region_id: String) -> void:")
	reg_lines.append("\tid = region_id")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\tname_key = def[\"name_key\"]")
	reg_lines.append("\tspecies_key = str(def.get(\"species_key\", \"region.\" + region_id + \".species\"))")
	reg_lines.append("\tcoastal_pop = float(def[\"coastal_pop\"])")
	reg_lines.append("\theat_sensitivity = float(B.REGION_HEAT_SENSITIVITY.get(region_id, def.get(\"heat_sensitivity\", 1.0)))")
	reg_lines.append("\tanchor = def[\"anchor\"]")
	reg_lines.append("\tpolygon = polygon_of(region_id)")
	reg_lines.append("\treset()")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func reset() -> void:")
	reg_lines.append("\tvar start: Dictionary = B.REGION_START[id]")
	reg_lines.append("\tpollution = start[\"pollution\"]")
	reg_lines.append("\tcoral_health = start[\"coral_health\"]")
	reg_lines.append("\tseagrass = start[\"seagrass\"]")
	reg_lines.append("\tfish_stock = start[\"fish_stock\"]")
	reg_lines.append("\tawareness = start[\"awareness\"]")
	reg_lines.append("\tprotection = start[\"protection\"]")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func clamp_all() -> void:")
	reg_lines.append("\tpollution = clampf(pollution, 0.0, 100.0)")
	reg_lines.append("\tcoral_health = clampf(coral_health, 0.0, 100.0)")
	reg_lines.append("\tseagrass = clampf(seagrass, 0.0, 100.0)")
	reg_lines.append("\tfish_stock = clampf(fish_stock, 0.0, 100.0)")
	reg_lines.append("\tawareness = clampf(awareness, 0.0, 100.0)")
	reg_lines.append("\tprotection = clampf(protection, 0.0, 100.0)")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func crisis_level() -> float:")
	reg_lines.append("\tvar c: float = pollution * B.CRISIS_W_POLLUTION \\")
	reg_lines.append("\t\t+ (100.0 - coral_health) * B.CRISIS_W_CORAL \\")
	reg_lines.append("\t\t+ (100.0 - seagrass) * B.CRISIS_W_SEAGRASS \\")
	reg_lines.append("\t\t+ (100.0 - fish_stock) * B.CRISIS_W_FISH \\")
	reg_lines.append("\t\t- protection * 0.18 \\")
	reg_lines.append("\t\t- awareness * 0.14")
	reg_lines.append("\treturn clampf(c, 0.0, 100.0)")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func health() -> float:")
	reg_lines.append("\treturn 100.0 - crisis_level()")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func status() -> String:")
	reg_lines.append("\tvar c: float = crisis_level()")
	reg_lines.append("\tif c >= B.STATUS_COLLAPSED:")
	reg_lines.append("\t\treturn \"collapsed\"")
	reg_lines.append("\tif c >= B.STATUS_CRITICAL:")
	reg_lines.append("\t\treturn \"critical\"")
	reg_lines.append("\tif c >= B.STATUS_STRESSED:")
	reg_lines.append("\t\treturn \"stressed\"")
	reg_lines.append("\treturn \"healthy\"")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("func to_dict() -> Dictionary:")
	reg_lines.append("\treturn {")
	reg_lines.append("\t\t\"id\": id,")
	reg_lines.append("\t\t\"name_key\": name_key,")
	reg_lines.append("\t\t\"species_key\": species_key,")
	reg_lines.append("\t\t\"pollution\": pollution,")
	reg_lines.append("\t\t\"coral_health\": coral_health,")
	reg_lines.append("\t\t\"seagrass\": seagrass,")
	reg_lines.append("\t\t\"fish_stock\": fish_stock,")
	reg_lines.append("\t\t\"awareness\": awareness,")
	reg_lines.append("\t\t\"protection\": protection,")
	reg_lines.append("\t\t\"coastal_pop\": coastal_pop,")
	reg_lines.append("\t\t\"heat_sensitivity\": heat_sensitivity,")
	reg_lines.append("\t\t\"crisis\": crisis_level(),")
	reg_lines.append("\t\t\"health\": health(),")
	reg_lines.append("\t\t\"status\": status(),")
	reg_lines.append("\t}")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func polygon_of(region_id: String) -> PackedVector2Array:")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\tvar pts: Array = def[\"polygon\"]")
	reg_lines.append("\tvar poly := PackedVector2Array()")
	reg_lines.append("\tfor p in pts:")
	reg_lines.append("\t\tpoly.append(p)")
	reg_lines.append("\treturn poly")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func anchor_of(region_id: String) -> Vector2:")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\treturn def[\"anchor\"]")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func name_key_of(region_id: String) -> String:")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\treturn def[\"name_key\"]")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func species_key_of(region_id: String) -> String:")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\treturn str(def.get(\"species_key\", \"region.\" + region_id + \".species\"))")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func heat_sensitivity_of(region_id: String) -> float:")
	reg_lines.append("\tvar def: Dictionary = DEFS[region_id]")
	reg_lines.append("\treturn float(B.REGION_HEAT_SENSITIVITY.get(region_id, def.get(\"heat_sensitivity\", 1.0)))")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func neighbors_of(region_id: String) -> Array:")
	reg_lines.append("\tvar result: Array = []")
	reg_lines.append("\tfor r in ROUTES:")
	reg_lines.append("\t\tvar route: Dictionary = r")
	reg_lines.append("\t\tvar a: String = route[\"a\"]")
	reg_lines.append("\t\tvar b: String = route[\"b\"]")
	reg_lines.append("\t\tif a == region_id:")
	reg_lines.append("\t\t\tresult.append({\"id\": b, \"kind\": route[\"kind\"], \"weight\": route[\"weight\"]})")
	reg_lines.append("\t\telif b == region_id:")
	reg_lines.append("\t\t\tresult.append({\"id\": a, \"kind\": route[\"kind\"], \"weight\": route[\"weight\"]})")
	reg_lines.append("\treturn result")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("## Shortest route path (array of region ids including from_id and to_id) via BFS.")
	reg_lines.append("static func shortest_path(from_id: String, to_id: String) -> Array:")
	reg_lines.append("\tif from_id == to_id:")
	reg_lines.append("\t\treturn [from_id]")
	reg_lines.append("\tif not DEFS.has(from_id) or not DEFS.has(to_id):")
	reg_lines.append("\t\treturn []")
	reg_lines.append("\tvar queue: Array = [[from_id]]")
	reg_lines.append("\tvar visited: Dictionary = {from_id: true}")
	reg_lines.append("\twhile not queue.is_empty():")
	reg_lines.append("\t\tvar path: Array = queue.pop_front()")
	reg_lines.append("\t\tvar cur: String = str(path[path.size() - 1])")
	reg_lines.append("\t\tfor nb in neighbors_of(cur):")
	reg_lines.append("\t\t\tvar nxt: String = str(nb[\"id\"])")
	reg_lines.append("\t\t\tif nxt == to_id:")
	reg_lines.append("\t\t\t\tvar full: Array = path.duplicate()")
	reg_lines.append("\t\t\t\tfull.append(nxt)")
	reg_lines.append("\t\t\t\treturn full")
	reg_lines.append("\t\t\tif not visited.has(nxt):")
	reg_lines.append("\t\t\t\tvisited[nxt] = true")
	reg_lines.append("\t\t\t\tvar next_path: Array = path.duplicate()")
	reg_lines.append("\t\t\t\tnext_path.append(nxt)")
	reg_lines.append("\t\t\t\tqueue.append(next_path)")
	reg_lines.append("\treturn [from_id, to_id]")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func route_distance(from_id: String, to_id: String) -> int:")
	reg_lines.append("\tvar p: Array = shortest_path(from_id, to_id)")
	reg_lines.append("\treturn maxi(p.size() - 1, 1)")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func region_at(point: Vector2) -> String:")
	reg_lines.append("\tvar wx: float = wrapf(point.x + HALF_W, 0.0, WORLD_W) - HALF_W")
	reg_lines.append("\tfor shift in [0.0, WORLD_W, -WORLD_W]:")
	reg_lines.append("\t\tvar tp := Vector2(wx + float(shift), point.y)")
	reg_lines.append("\t\tfor rid in IDS:")
	reg_lines.append("\t\t\tvar region_id: String = rid")
	reg_lines.append("\t\t\tif Geometry2D.is_point_in_polygon(tp, polygon_of(region_id)):")
	reg_lines.append("\t\t\t\treturn region_id")
	reg_lines.append("\treturn \"\"")
	reg_lines.append("")
	reg_lines.append("")
	reg_lines.append("static func centroid(poly: PackedVector2Array) -> Vector2:")
	reg_lines.append("\tif poly.is_empty():")
	reg_lines.append("\t\treturn Vector2.ZERO")
	reg_lines.append("\tvar sum := Vector2.ZERO")
	reg_lines.append("\tfor p in poly:")
	reg_lines.append("\t\tsum += p")
	reg_lines.append("\treturn sum / float(poly.size())")
	reg_lines.append("")

	var f_reg := FileAccess.open("res://scripts/region.gd", FileAccess.WRITE)
	f_reg.store_string("\n".join(reg_lines))
	f_reg.close()

	# Also export LAND and CITY_LIGHTS snippet for map_builder.gd
	var cities_ll := [
		[-0.1, 51.5, 1], [-9.1, 38.7, 1], [2.2, 41.4, 1], [5.4, 43.3, 0], [12.5, 41.9, 1],
		[12.3, 45.4, 0], [23.7, 38.0, 1], [29.0, 41.0, 1], [27.1, 38.4, 0], [30.7, 46.5, 0],
		[29.9, 31.2, 1], [3.1, 36.8, 0], [2.3, 48.9, 2], [13.4, 52.5, 2], [37.6, 55.8, 2],
		[-16.5, 14.7, 0], [3.4, 6.5, 1], [18.4, -33.9, 1], [31.0, -29.9, 0], [39.3, -6.8, 0],
		[39.7, -4.0, 0], [39.2, 21.5, 1], [55.3, 25.3, 1], [58.4, 23.6, 0], [67.0, 24.9, 1],
		[72.9, 19.1, 1], [80.3, 13.1, 1], [88.4, 22.6, 1], [79.9, 6.9, 0], [115.9, -32.0, 1],
		[31.2, 30.0, 2], [36.8, -1.3, 2], [77.2, 28.6, 2], [103.8, 1.35, 1], [106.8, -6.2, 1],
		[112.7, -7.25, 0], [100.5, 13.75, 1], [106.6, 10.8, 1], [121.0, 14.6, 1], [125.6, 7.1, 0],
		[114.2, 22.3, 1], [121.5, 25.0, 1], [121.5, 31.2, 1], [120.4, 36.1, 0], [129.1, 35.2, 1],
		[127.0, 37.6, 1], [135.5, 34.7, 1], [139.7, 35.7, 1], [141.3, 43.1, 0], [131.9, 43.1, 0],
		[116.4, 39.9, 2], [151.2, -33.9, 1], [145.0, -37.8, 1], [153.0, -27.5, 1], [174.8, -36.8, 1],
		[178.4, -18.1, 0], [202.1, 21.3, 1], [210.1, 61.2, 0], [236.9, 49.3, 1], [237.7, 47.6, 1],
		[237.6, 37.8, 1], [241.8, 34.0, 1], [260.1, 16.9, 0], [280.5, 9.0, 1], [283.0, -12.0, 1],
		[288.4, -33.0, 1], [264.6, 29.8, 1], [263.9, 19.2, 0], [277.6, 23.1, 1], [290.1, 18.5, 0],
		[284.5, 10.4, 0], [279.8, 25.8, 1], [286.0, 40.7, 1], [289.0, 42.4, 1], [296.4, 44.6, 0],
		[338.1, 64.1, 0], [325.1, -8.0, 1], [321.5, -13.0, 0], [316.8, -22.9, 1], [313.4, -23.5, 1],
		[301.6, -34.6, 1], [303.8, -34.9, 0], [260.9, 19.4, 2], [272.4, 41.9, 2],
		[33.1, 69.0, 0], [19.0, 69.6, 0], [308.3, 64.2, 0],
	]

	var land_lines: Array = [
		"## Natural Earth 1:110m simplified land polygons in 360-deg periodic equirectangular",
		"## projection centered at 155E (generated by tools/build_world_map.gd).",
		"const LAND := [",
	]
	for lp in land_polys:
		land_lines.append("\t[")
		land_lines.append(format_vec2_array(lp, "\t\t"))
		land_lines.append("\t],")
	land_lines.append("]")
	land_lines.append("")
	land_lines.append("## Global coastal (z = 1 major, 0 minor) and inland (z = 2) city lights.")
	land_lines.append("const CITY_LIGHTS := [")
	var city_cur: Array = []
	for i in cities_ll.size():
		var c: Array = cities_ll[i]
		var lon: float = float(c[0])
		if lon >= SEAM_MAX_LON:
			lon -= 360.0
		var cp: Vector2 = proj(lon, float(c[1]))
		city_cur.append("Vector3(%.2f, %.2f, %d)" % [cp.x, cp.y, int(c[2])])
		if city_cur.size() == 4 or i == cities_ll.size() - 1:
			land_lines.append("\t" + ", ".join(city_cur) + ",")
			city_cur.clear()
	land_lines.append("]")

	var f_land := FileAccess.open("res://tools/generated_land.txt", FileAccess.WRITE)
	f_land.store_string("\n".join(land_lines))
	f_land.close()
	print("Wrote res://scripts/region.gd and res://tools/generated_land.txt successfully. polys=", land_polys.size())
	quit(0)
