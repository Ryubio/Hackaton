extends RefCounted
## RegionData: static geography of the 12 global ocean regions (polygons generated from
## Natural Earth 1:110m via tools/build_world_map.gd, anchors, routes, coastal weights,
## heat sensitivity) plus the live 0-100 state of one region. Pure logic, no nodes.
## Map plane coordinates: x = east, y = south (3D: Vector3(x, 0, y)); north is far from camera.

const B := preload("res://scripts/balance.gd")

const WORLD_W := 69.12
const HALF_W := 34.56

const IDS := [
	"north_atlantic", "south_atlantic", "caribbean", "mediterranean",
	"red_arabian", "indian", "coral_triangle", "east_asian",
	"north_pacific", "south_pacific", "arctic", "southern",
]
const HERO_ID := "mediterranean"

## Miller cylindrical height-compensated world projection centered at 155E (lon in [-25, 335],
## period WORLD_W): natural proportions under 3D oblique camera without vertical squashing.
const DEFS := {
	"north_atlantic": {
		"name_key": "region.north_atlantic.name",
		"species_key": "region.north_atlantic.species",
		"coastal_pop": 0.75,
		"heat_sensitivity": 0.90,
		"anchor": Vector2(32.26, -10.09),
		"polygon": [
			Vector2(35.08, -21.14), Vector2(35.38, -21.32), Vector2(35.62, -21.05), Vector2(35.91, -20.84), Vector2(36.22, -20.97),
			Vector2(36.46, -20.94), Vector2(36.69, -20.48), Vector2(36.98, -20.04), Vector2(37.32, -20.28), Vector2(37.59, -20.53),
			Vector2(37.83, -20.21), Vector2(38.12, -20.32), Vector2(38.35, -20.06), Vector2(38.64, -19.33), Vector2(38.99, -19.71),
			Vector2(39.25, -20.16), Vector2(39.49, -19.91), Vector2(39.78, -19.94), Vector2(40.05, -19.86), Vector2(40.31, -19.85),
			Vector2(40.28, -19.80), Vector2(40.41, -18.36), Vector2(40.70, -18.14), Vector2(40.99, -18.24), Vector2(41.34, -18.67),
			Vector2(41.44, -18.47), Vector2(41.61, -17.91), Vector2(41.61, -16.68), Vector2(41.50, -16.65), Vector2(41.50, -16.75),
			Vector2(41.31, -16.84), Vector2(41.25, -17.14), Vector2(41.37, -17.37), Vector2(41.43, -17.33), Vector2(41.51, -17.55),
			Vector2(41.39, -17.61), Vector2(41.43, -18.06), Vector2(41.38, -18.09), Vector2(41.15, -17.86), Vector2(40.97, -17.83),
			Vector2(40.91, -17.68), Vector2(40.88, -17.17), Vector2(41.01, -16.60), Vector2(40.93, -16.49), Vector2(40.90, -16.53),
			Vector2(40.69, -16.51), Vector2(40.66, -16.43), Vector2(40.52, -16.44), Vector2(40.23, -16.27), Vector2(40.06, -15.72),
			Vector2(39.98, -15.63), Vector2(39.63, -15.48), Vector2(39.58, -15.17), Vector2(39.17, -14.92), Vector2(39.00, -15.08),
			Vector2(38.95, -15.05), Vector2(39.00, -14.68), Vector2(38.73, -14.75), Vector2(38.44, -14.67), Vector2(38.46, -14.35),
			Vector2(38.76, -14.21), Vector2(39.09, -13.69), Vector2(39.05, -13.03), Vector2(38.97, -12.86), Vector2(38.53, -12.85),
			Vector2(37.82, -12.97), Vector2(37.51, -12.69), Vector2(37.59, -12.53), Vector2(37.63, -12.07), Vector2(37.51, -11.49),
			Vector2(37.54, -11.12), Vector2(37.62, -11.09), Vector2(37.61, -10.63), Vector2(37.75, -10.67), Vector2(37.86, -10.62),
			Vector2(37.94, -10.71), Vector2(37.98, -10.70), Vector2(37.98, -10.47), Vector2(38.01, -10.33), Vector2(37.94, -10.17),
			Vector2(38.00, -10.01), Vector2(38.00, -9.85), Vector2(37.67, -9.57), Vector2(37.53, -9.35), Vector2(37.44, -8.91),
			Vector2(37.48, -8.54), Vector2(37.10, -8.03), Vector2(36.91, -8.00), Vector2(36.69, -7.57), Vector2(36.55, -7.45),
			Vector2(36.42, -6.94), Vector2(36.25, -6.70), Vector2(36.20, -6.39), Vector2(36.06, -6.16), Vector2(36.04, -5.88),
			Vector2(36.19, -5.62), Vector2(36.16, -4.51), Vector2(36.03, -4.19), Vector2(35.92, -4.11), Vector2(36.04, -3.98),
			Vector2(36.11, -3.77), Vector2(36.12, -3.43), Vector2(36.42, -3.04), Vector2(36.84, -2.14), Vector2(36.93, -2.04),
			Vector2(36.75, -2.10), Vector2(36.39, -2.12), Vector2(36.17, -1.68), Vector2(35.81, -1.88), Vector2(35.58, -1.45),
			Vector2(35.26, -1.53), Vector2(35.00, -1.30), Vector2(34.72, -1.47), Vector2(34.44, -1.50), Vector2(34.14, -1.64),
			Vector2(33.81, -1.63), Vector2(33.49, -1.43), Vector2(33.23, -1.52), Vector2(32.95, -1.73), Vector2(32.59, -1.92),
			Vector2(32.24, -1.81), Vector2(32.05, -1.26), Vector2(31.74, -1.23), Vector2(31.55, -0.79), Vector2(31.19, -1.06),
			Vector2(30.90, -0.87), Vector2(30.56, -0.94), Vector2(30.29, -0.63), Vector2(30.03, -0.43), Vector2(29.81, -0.35),
			Vector2(29.80, -0.51), Vector2(29.69, -0.56), Vector2(29.54, -1.20), Vector2(29.47, -1.19), Vector2(29.45, -1.28),
			Vector2(29.23, -1.53), Vector2(28.80, -1.71), Vector2(28.61, -1.69), Vector2(28.60, -1.65), Vector2(28.51, -1.66),
			Vector2(28.17, -2.01), Vector2(28.17, -2.05), Vector2(28.04, -2.25), Vector2(27.82, -2.42), Vector2(27.74, -2.44),
			Vector2(27.71, -2.63), Vector2(27.87, -3.11), Vector2(28.04, -3.39), Vector2(28.19, -3.74), Vector2(28.10, -4.14),
			Vector2(27.96, -4.45), Vector2(27.96, -4.85), Vector2(27.71, -5.00), Vector2(27.35, -5.34), Vector2(27.21, -5.96),
			Vector2(26.88, -5.75), Vector2(26.68, -5.98), Vector2(26.41, -5.90), Vector2(26.21, -6.18), Vector2(25.88, -5.94),
			Vector2(25.78, -6.38), Vector2(25.51, -6.43), Vector2(25.37, -6.79), Vector2(25.14, -6.95), Vector2(24.95, -7.22),
			Vector2(24.67, -7.31), Vector2(24.41, -7.32), Vector2(24.18, -7.37), Vector2(24.02, -7.52), Vector2(24.03, -7.61),
			Vector2(23.75, -8.77), Vector2(23.78, -8.98), Vector2(23.86, -9.15), Vector2(24.18, -9.49), Vector2(24.31, -9.69),
			Vector2(24.39, -9.71), Vector2(24.53, -9.90), Vector2(24.73, -10.00), Vector2(24.86, -10.25), Vector2(24.81, -10.72),
			Vector2(24.76, -10.74), Vector2(24.99, -11.17), Vector2(24.96, -11.31), Vector2(24.99, -11.27), Vector2(25.16, -11.58),
			Vector2(25.20, -11.85), Vector2(25.29, -11.85), Vector2(25.62, -11.97), Vector2(25.55, -12.05), Vector2(25.97, -12.19),
			Vector2(25.98, -12.33), Vector2(25.89, -12.44), Vector2(25.84, -12.41), Vector2(25.85, -12.32), Vector2(25.80, -12.46),
			Vector2(25.80, -12.62), Vector2(25.93, -12.87), Vector2(26.55, -13.27), Vector2(26.52, -13.36), Vector2(26.85, -13.40),
			Vector2(26.62, -13.19), Vector2(26.62, -12.84), Vector2(26.83, -12.82), Vector2(27.05, -13.07), Vector2(27.66, -13.41),
			Vector2(27.94, -13.67), Vector2(27.79, -13.81), Vector2(27.78, -14.07), Vector2(27.72, -14.09), Vector2(27.52, -13.70),
			Vector2(27.24, -13.65), Vector2(27.02, -13.80), Vector2(26.90, -14.41), Vector2(27.09, -14.66), Vector2(26.88, -14.87),
			Vector2(26.56, -14.84), Vector2(26.15, -14.53), Vector2(25.82, -14.07), Vector2(26.24, -14.74), Vector2(26.48, -14.90),
			Vector2(26.63, -15.15), Vector2(26.81, -15.17), Vector2(27.51, -15.10), Vector2(27.85, -15.15), Vector2(28.10, -15.46),
			Vector2(28.41, -15.59), Vector2(28.71, -15.87), Vector2(28.69, -16.32), Vector2(28.61, -16.48), Vector2(28.46, -16.53),
			Vector2(28.39, -16.84), Vector2(28.25, -16.98), Vector2(27.94, -17.08), Vector2(27.78, -17.30), Vector2(27.54, -17.50),
			Vector2(27.61, -17.73), Vector2(26.99, -19.14), Vector2(26.94, -19.14), Vector2(26.79, -18.93), Vector2(26.62, -18.47),
			Vector2(26.38, -18.29), Vector2(26.26, -18.50), Vector2(26.10, -18.56), Vector2(26.04, -19.44), Vector2(25.69, -19.47),
			Vector2(25.63, -19.62), Vector2(25.40, -19.84), Vector2(27.18, -20.26), Vector2(27.74, -20.34), Vector2(28.04, -20.32),
			Vector2(28.29, -20.45), Vector2(28.50, -19.97), Vector2(28.78, -19.63), Vector2(29.09, -19.65), Vector2(29.40, -19.47),
			Vector2(29.72, -19.98), Vector2(29.92, -19.35), Vector2(30.01, -19.36), Vector2(30.07, -19.28), Vector2(30.30, -19.27),
			Vector2(30.49, -18.95), Vector2(30.64, -19.05), Vector2(30.74, -18.93), Vector2(31.01, -18.96), Vector2(31.06, -18.91),
			Vector2(31.32, -18.97), Vector2(31.67, -18.78), Vector2(31.96, -19.02), Vector2(32.26, -19.15), Vector2(32.44, -19.86),
			Vector2(32.67, -20.08), Vector2(32.99, -20.03), Vector2(33.26, -20.39), Vector2(33.50, -20.79), Vector2(33.76, -21.03),
			Vector2(34.03, -21.22), Vector2(34.31, -21.35), Vector2(34.58, -21.51), Vector2(34.82, -21.54),
		],
	},
	"south_atlantic": {
		"name_key": "region.south_atlantic.name",
		"species_key": "region.south_atlantic.species",
		"coastal_pop": 0.55,
		"heat_sensitivity": 0.85,
		"anchor": Vector2(36.48, 5.89),
		"polygon": [
			Vector2(36.73, -1.99), Vector2(37.09, -1.86), Vector2(37.60, -1.31), Vector2(37.82, -1.17), Vector2(38.47, -1.39),
			Vector2(38.99, -1.26), Vector2(39.35, -1.45), Vector2(40.36, -1.34), Vector2(40.47, -1.14), Vector2(40.56, -1.14),
			Vector2(41.06, 0.04), Vector2(41.02, 0.22), Vector2(41.13, 0.61), Vector2(41.61, 1.41), Vector2(41.86, 2.36),
			Vector2(41.80, 2.48), Vector2(41.95, 2.99), Vector2(41.94, 3.33), Vector2(41.77, 3.64), Vector2(41.58, 4.39),
			Vector2(41.58, 5.06), Vector2(41.74, 5.35), Vector2(42.06, 6.22), Vector2(42.24, 7.69), Vector2(42.82, 9.06),
			Vector2(42.82, 9.27), Vector2(42.76, 9.34), Vector2(42.85, 9.84), Vector2(43.12, 10.07), Vector2(43.18, 10.06),
			Vector2(43.21, 10.23), Vector2(43.18, 10.69), Vector2(43.50, 10.95), Vector2(43.41, 11.37), Vector2(43.30, 11.70),
			Vector2(43.31, 12.22), Vector2(43.19, 12.55), Vector2(42.84, 12.74), Vector2(42.92, 13.26), Vector2(43.12, 13.61),
			Vector2(43.14, 13.97), Vector2(42.87, 13.90), Vector2(42.52, 13.98), Vector2(42.19, 14.02), Vector2(41.87, 14.10),
			Vector2(41.56, 13.92), Vector2(41.24, 13.79), Vector2(40.91, 13.16), Vector2(40.52, 13.39), Vector2(40.17, 13.54),
			Vector2(39.83, 14.02), Vector2(39.54, 14.06), Vector2(39.23, 13.91), Vector2(38.90, 13.55), Vector2(38.54, 13.53),
			Vector2(38.21, 13.59), Vector2(37.91, 13.48), Vector2(37.57, 13.09), Vector2(37.18, 13.17), Vector2(36.83, 13.49),
			Vector2(36.55, 13.93), Vector2(36.23, 13.75), Vector2(35.90, 13.87), Vector2(35.54, 13.58), Vector2(35.20, 13.82),
			Vector2(34.87, 13.84), Vector2(34.53, 13.99), Vector2(34.21, 14.19), Vector2(33.93, 14.52), Vector2(33.57, 14.45),
			Vector2(33.28, 14.78), Vector2(32.93, 14.62), Vector2(32.59, 14.74), Vector2(32.23, 14.74), Vector2(31.92, 15.03),
			Vector2(31.59, 15.10), Vector2(31.26, 15.36), Vector2(30.98, 15.88), Vector2(30.75, 16.57), Vector2(30.38, 16.12),
			Vector2(30.03, 16.42), Vector2(29.72, 16.55), Vector2(29.42, 16.59), Vector2(28.99, 16.10), Vector2(28.68, 16.71),
			Vector2(28.41, 16.98), Vector2(28.00, 16.80), Vector2(27.74, 17.47), Vector2(27.48, 17.89), Vector2(27.15, 18.00),
			Vector2(26.92, 18.23), Vector2(26.88, 17.97), Vector2(26.73, 17.77), Vector2(26.63, 17.51), Vector2(26.39, 17.04),
			Vector2(26.31, 16.73), Vector2(26.17, 16.57), Vector2(26.23, 16.01), Vector2(26.30, 16.01), Vector2(26.33, 15.97),
			Vector2(26.25, 15.84), Vector2(26.33, 15.12), Vector2(26.37, 15.08), Vector2(26.50, 14.66), Vector2(26.73, 14.46),
			Vector2(26.81, 14.09), Vector2(26.59, 14.02), Vector2(26.47, 13.86), Vector2(26.51, 13.52), Vector2(26.61, 13.41),
			Vector2(26.80, 13.40), Vector2(26.89, 12.86), Vector2(27.03, 12.66), Vector2(27.23, 12.55), Vector2(27.14, 12.29),
			Vector2(27.01, 12.41), Vector2(26.92, 12.34), Vector2(26.90, 12.04), Vector2(26.94, 12.00), Vector2(27.11, 12.11),
			Vector2(27.33, 12.06), Vector2(27.47, 11.91), Vector2(27.43, 11.74), Vector2(27.47, 11.50), Vector2(27.44, 11.35),
			Vector2(27.60, 11.38), Vector2(28.00, 11.31), Vector2(28.30, 11.13), Vector2(28.50, 10.70), Vector2(28.51, 10.52),
			Vector2(28.39, 10.38), Vector2(28.41, 10.17), Vector2(28.17, 9.90), Vector2(28.24, 9.96), Vector2(28.38, 9.95),
			Vector2(28.56, 10.08), Vector2(28.67, 10.05), Vector2(28.82, 10.12), Vector2(29.06, 9.93), Vector2(29.28, 9.55),
			Vector2(29.37, 9.25), Vector2(29.67, 8.87), Vector2(29.88, 8.33), Vector2(30.01, 8.17), Vector2(30.09, 7.70),
			Vector2(30.06, 7.54), Vector2(30.09, 7.33), Vector2(30.24, 7.04), Vector2(30.46, 6.82), Vector2(30.67, 6.73),
			Vector2(30.81, 6.60), Vector2(31.10, 6.50), Vector2(31.33, 6.50), Vector2(31.38, 6.31), Vector2(31.54, 6.18),
			Vector2(31.57, 5.87), Vector2(31.77, 5.50), Vector2(31.80, 5.11), Vector2(31.86, 5.00), Vector2(31.93, 4.37),
			Vector2(31.92, 3.84), Vector2(31.96, 3.66), Vector2(32.01, 3.66), Vector2(32.28, 3.08), Vector2(32.66, 2.50),
			Vector2(32.73, 2.03), Vector2(32.63, 1.49), Vector2(32.55, 1.38), Vector2(32.37, 1.37), Vector2(32.24, 1.30),
			Vector2(32.00, 0.99), Vector2(31.69, 0.75), Vector2(31.41, 0.77), Vector2(31.02, 0.62), Vector2(30.86, 0.68),
			Vector2(30.87, 0.58), Vector2(30.77, 0.40), Vector2(30.17, 0.11), Vector2(30.08, 0.22), Vector2(30.06, 0.04),
			Vector2(29.82, 0.00), Vector2(29.82, -0.24), Vector2(30.08, -0.33), Vector2(30.36, -0.55), Vector2(30.60, -0.82),
			Vector2(30.92, -0.76), Vector2(31.18, -0.92), Vector2(31.59, -0.63), Vector2(31.82, -1.12), Vector2(32.13, -1.16),
			Vector2(32.32, -1.72), Vector2(32.58, -1.80), Vector2(32.89, -1.63), Vector2(33.17, -1.43), Vector2(33.50, -1.31),
			Vector2(33.84, -1.52), Vector2(34.12, -1.53), Vector2(34.41, -1.39), Vector2(34.68, -1.36), Vector2(35.02, -1.16),
			Vector2(35.29, -1.41), Vector2(35.64, -1.33), Vector2(35.86, -1.73), Vector2(36.22, -1.53), Vector2(36.46, -2.01),
		],
	},
	"caribbean": {
		"name_key": "region.caribbean.name",
		"species_key": "region.caribbean.species",
		"coastal_pop": 0.80,
		"heat_sensitivity": 1.15,
		"anchor": Vector2(25.15, -4.40),
		"polygon": [
			Vector2(22.86, -8.56), Vector2(22.97, -8.40), Vector2(23.21, -8.53), Vector2(23.26, -8.50), Vector2(23.45, -8.10),
			Vector2(23.41, -7.91), Vector2(23.64, -7.29), Vector2(23.70, -7.23), Vector2(23.74, -7.09), Vector2(23.87, -7.04),
			Vector2(23.97, -7.10), Vector2(24.00, -7.38), Vector2(24.13, -7.27), Vector2(24.39, -7.21), Vector2(24.65, -7.20),
			Vector2(24.88, -7.12), Vector2(25.06, -6.87), Vector2(25.28, -6.72), Vector2(25.43, -6.34), Vector2(25.68, -6.29),
			Vector2(25.81, -5.75), Vector2(26.19, -6.02), Vector2(26.36, -5.78), Vector2(26.64, -5.86), Vector2(26.86, -5.61),
			Vector2(27.13, -5.78), Vector2(27.25, -5.28), Vector2(27.64, -4.91), Vector2(27.85, -4.79), Vector2(27.85, -4.42),
			Vector2(27.99, -4.10), Vector2(28.07, -3.75), Vector2(27.94, -3.44), Vector2(27.77, -3.16), Vector2(27.62, -2.71),
			Vector2(27.55, -2.78), Vector2(27.41, -2.80), Vector2(27.37, -2.87), Vector2(27.53, -2.95), Vector2(27.51, -3.01),
			Vector2(26.97, -2.99), Vector2(26.97, -2.90), Vector2(26.89, -2.84), Vector2(26.77, -2.87), Vector2(26.66, -3.00),
			Vector2(26.31, -2.97), Vector2(26.30, -3.04), Vector2(26.15, -3.22), Vector2(26.03, -3.22), Vector2(25.96, -3.42),
			Vector2(25.91, -3.42), Vector2(25.82, -3.30), Vector2(25.84, -3.18), Vector2(25.64, -3.08), Vector2(25.61, -3.14),
			Vector2(25.69, -3.17), Vector2(25.74, -3.39), Vector2(25.58, -3.51), Vector2(25.24, -3.16), Vector2(25.08, -3.18),
			Vector2(25.07, -3.12), Vector2(24.96, -3.12), Vector2(24.83, -2.97), Vector2(24.79, -2.65), Vector2(24.72, -2.62),
			Vector2(24.59, -2.43), Vector2(24.53, -2.44), Vector2(24.39, -2.59), Vector2(24.06, -2.72), Vector2(23.99, -2.61),
			Vector2(23.32, -3.15), Vector2(23.44, -4.20), Vector2(23.05, -4.50), Vector2(22.45, -4.41), Vector2(22.36, -4.47),
			Vector2(22.44, -4.60), Vector2(22.45, -5.09), Vector2(22.53, -5.03), Vector2(22.61, -5.46), Vector2(22.58, -5.50),
			Vector2(22.73, -5.84), Vector2(22.73, -6.00), Vector2(22.67, -6.09), Vector2(22.35, -6.07), Vector2(22.00, -5.92),
			Vector2(21.89, -5.42), Vector2(21.79, -5.31), Vector2(21.25, -5.12), Vector2(21.18, -5.22), Vector2(20.98, -5.30),
			Vector2(20.74, -5.80), Vector2(20.61, -6.31), Vector2(20.64, -6.83), Vector2(20.75, -7.31), Vector2(20.70, -7.75),
			Vector2(20.84, -8.01), Vector2(21.03, -8.14), Vector2(21.20, -8.36), Vector2(21.46, -8.44), Vector2(21.60, -8.37),
			Vector2(21.76, -8.41), Vector2(21.89, -8.25), Vector2(22.06, -8.24), Vector2(22.12, -8.29), Vector2(22.19, -8.24),
			Vector2(22.27, -8.32), Vector2(22.21, -8.58), Vector2(22.25, -8.60), Vector2(22.76, -8.63),
		],
	},
	"mediterranean": {
		"name_key": "region.mediterranean.name",
		"species_key": "region.mediterranean.species",
		"coastal_pop": 0.85,
		"heat_sensitivity": 1.05,
		"anchor": Vector2(-26.21, -10.15),
		"polygon": [
			Vector2(-23.71, -13.78), Vector2(-23.39, -13.69), Vector2(-23.36, -13.65), Vector2(-23.60, -13.45), Vector2(-23.37, -13.34),
			Vector2(-23.41, -13.18), Vector2(-23.25, -13.08), Vector2(-22.97, -13.29), Vector2(-22.75, -13.36), Vector2(-22.74, -13.40),
			Vector2(-22.58, -13.20), Vector2(-22.35, -13.08), Vector2(-21.84, -12.54), Vector2(-21.79, -12.33), Vector2(-21.82, -12.21),
			Vector2(-22.02, -12.06), Vector2(-22.17, -12.08), Vector2(-22.39, -12.03), Vector2(-23.00, -12.39), Vector2(-23.34, -12.39),
			Vector2(-23.58, -12.28), Vector2(-23.72, -11.87), Vector2(-24.09, -11.91), Vector2(-24.17, -11.66), Vector2(-24.46, -11.65),
			Vector2(-24.76, -11.10), Vector2(-24.61, -10.91), Vector2(-24.48, -10.57), Vector2(-24.26, -10.58), Vector2(-24.07, -10.41),
			Vector2(-23.89, -10.45), Vector2(-23.85, -10.58), Vector2(-23.69, -10.56), Vector2(-23.54, -10.39), Vector2(-23.21, -10.43),
			Vector2(-23.08, -10.60), Vector2(-22.91, -10.54), Vector2(-22.93, -10.49), Vector2(-22.86, -10.34), Vector2(-22.91, -10.23),
			Vector2(-22.89, -9.98), Vector2(-23.13, -9.20), Vector2(-23.30, -8.89), Vector2(-23.60, -8.98), Vector2(-23.66, -9.02),
			Vector2(-23.99, -9.04), Vector2(-24.22, -8.86), Vector2(-24.66, -9.07), Vector2(-24.91, -9.07), Vector2(-24.95, -9.16),
			Vector2(-25.27, -9.25), Vector2(-25.33, -9.38), Vector2(-25.62, -9.46), Vector2(-25.79, -9.40), Vector2(-25.99, -9.09),
			Vector2(-25.95, -8.86), Vector2(-26.11, -8.68), Vector2(-26.28, -8.81), Vector2(-26.71, -9.00), Vector2(-26.80, -9.27),
			Vector2(-27.08, -9.42), Vector2(-27.32, -9.44), Vector2(-27.60, -9.59), Vector2(-27.65, -9.74), Vector2(-27.74, -9.75),
			Vector2(-27.77, -9.87), Vector2(-27.64, -10.01), Vector2(-27.62, -10.33), Vector2(-27.69, -10.39), Vector2(-27.59, -10.77),
			Vector2(-27.64, -10.80), Vector2(-27.75, -10.72), Vector2(-27.76, -10.82), Vector2(-27.93, -10.87), Vector2(-28.26, -10.73),
			Vector2(-28.33, -10.80), Vector2(-28.57, -10.79), Vector2(-28.74, -10.67), Vector2(-28.83, -10.71), Vector2(-29.50, -10.63),
			Vector2(-29.80, -10.41), Vector2(-30.01, -10.35), Vector2(-30.19, -10.18), Vector2(-30.47, -10.25), Vector2(-30.64, -10.06),
			Vector2(-30.74, -10.18), Vector2(-30.93, -10.18), Vector2(-31.01, -9.95), Vector2(-31.01, -10.68), Vector2(-30.92, -10.57),
			Vector2(-30.77, -10.52), Vector2(-30.71, -10.64), Vector2(-30.61, -10.58), Vector2(-30.15, -10.57), Vector2(-30.01, -10.83),
			Vector2(-29.85, -10.89), Vector2(-29.81, -11.11), Vector2(-29.69, -11.26), Vector2(-29.77, -11.46), Vector2(-29.57, -11.99),
			Vector2(-29.34, -12.06), Vector2(-29.14, -12.29), Vector2(-29.12, -12.67), Vector2(-28.89, -12.77), Vector2(-28.50, -12.68),
			Vector2(-28.05, -13.09), Vector2(-27.84, -12.96), Vector2(-27.78, -12.63), Vector2(-27.31, -12.05), Vector2(-27.16, -12.03),
			Vector2(-27.09, -11.91), Vector2(-26.97, -11.85), Vector2(-26.91, -11.71), Vector2(-26.83, -11.67), Vector2(-26.71, -11.35),
			Vector2(-26.80, -10.96), Vector2(-26.64, -11.00), Vector2(-26.54, -11.28), Vector2(-26.46, -11.30), Vector2(-26.42, -11.52),
			Vector2(-26.55, -11.63), Vector2(-26.50, -11.78), Vector2(-26.38, -11.74), Vector2(-26.27, -11.58), Vector2(-26.22, -11.58),
			Vector2(-26.16, -11.75), Vector2(-26.66, -12.20), Vector2(-26.61, -12.26), Vector2(-26.68, -12.37), Vector2(-26.83, -12.37),
			Vector2(-27.03, -12.61), Vector2(-27.13, -12.89), Vector2(-27.31, -13.06), Vector2(-27.37, -13.23), Vector2(-27.35, -13.46),
			Vector2(-27.23, -13.56), Vector2(-27.14, -13.53), Vector2(-27.12, -13.25), Vector2(-27.05, -13.24), Vector2(-27.00, -13.38),
			Vector2(-26.94, -13.35), Vector2(-26.94, -13.25), Vector2(-26.72, -12.82), Vector2(-26.53, -12.72), Vector2(-26.08, -12.28),
			Vector2(-26.07, -11.75), Vector2(-25.97, -11.64), Vector2(-25.63, -10.65), Vector2(-25.46, -10.49), Vector2(-25.26, -10.49),
			Vector2(-25.34, -10.78), Vector2(-25.22, -10.82), Vector2(-25.25, -10.93), Vector2(-25.10, -10.87), Vector2(-25.11, -11.13),
			Vector2(-25.30, -11.35), Vector2(-25.23, -11.41), Vector2(-25.33, -11.58), Vector2(-25.34, -11.68), Vector2(-25.30, -11.62),
			Vector2(-25.00, -11.70), Vector2(-25.15, -11.89), Vector2(-24.97, -11.95), Vector2(-24.80, -11.88), Vector2(-24.52, -12.19),
			Vector2(-24.29, -12.20), Vector2(-24.23, -12.33), Vector2(-24.37, -12.43), Vector2(-24.41, -12.53), Vector2(-24.24, -12.90),
			Vector2(-24.19, -13.26), Vector2(-24.16, -13.24), Vector2(-24.03, -13.34), Vector2(-24.04, -13.44), Vector2(-23.83, -13.87),
			Vector2(-23.72, -13.89),
		],
	},
	"red_arabian": {
		"name_key": "region.red_arabian.name",
		"species_key": "region.red_arabian.species",
		"coastal_pop": 0.75,
		"heat_sensitivity": 1.15,
		"anchor": Vector2(-17.95, -4.46),
		"polygon": [
			Vector2(-20.25, -8.49), Vector2(-20.16, -8.53), Vector2(-19.90, -7.88), Vector2(-19.71, -7.79), Vector2(-19.50, -7.54),
			Vector2(-18.91, -7.85), Vector2(-18.86, -7.82), Vector2(-18.78, -7.24), Vector2(-17.95, -7.04), Vector2(-17.04, -7.14),
			Vector2(-16.91, -6.94), Vector2(-16.84, -6.72), Vector2(-16.70, -6.64), Vector2(-16.44, -6.31), Vector2(-16.53, -6.21),
			Vector2(-16.25, -5.83), Vector2(-16.08, -5.78), Vector2(-15.84, -5.92), Vector2(-15.68, -4.45), Vector2(-15.51, -4.06),
			Vector2(-15.43, -3.53), Vector2(-15.10, -2.48), Vector2(-15.35, -2.41), Vector2(-15.60, -2.44), Vector2(-16.09, -2.34),
			Vector2(-16.38, -2.56), Vector2(-16.70, -2.58), Vector2(-16.88, -1.99), Vector2(-17.12, -2.13), Vector2(-17.38, -2.09),
			Vector2(-17.57, -2.21), Vector2(-17.77, -2.56), Vector2(-18.11, -2.49), Vector2(-18.41, -2.29), Vector2(-18.57, -2.59),
			Vector2(-19.03, -3.09), Vector2(-19.84, -3.02), Vector2(-19.94, -3.10), Vector2(-19.90, -3.38), Vector2(-20.04, -3.38),
			Vector2(-20.13, -3.28), Vector2(-20.23, -3.25), Vector2(-20.34, -3.28), Vector2(-21.60, -3.35), Vector2(-21.74, -3.54),
			Vector2(-21.71, -3.88), Vector2(-22.18, -4.46), Vector2(-22.35, -5.05), Vector2(-22.52, -5.23), Vector2(-22.62, -5.83),
			Vector2(-22.58, -5.89), Vector2(-22.64, -6.20), Vector2(-22.90, -6.51), Vector2(-22.87, -6.75), Vector2(-23.04, -7.09),
			Vector2(-23.29, -7.83), Vector2(-23.27, -7.80), Vector2(-23.22, -7.80), Vector2(-23.14, -8.03), Vector2(-23.15, -7.92),
			Vector2(-23.04, -7.93), Vector2(-22.59, -6.82), Vector2(-22.49, -6.76), Vector2(-22.30, -6.34), Vector2(-22.29, -5.97),
			Vector2(-22.15, -5.68), Vector2(-21.94, -5.44), Vector2(-21.89, -5.21), Vector2(-21.61, -4.67), Vector2(-21.62, -4.23),
			Vector2(-21.55, -4.08), Vector2(-21.38, -4.06), Vector2(-21.31, -3.65), Vector2(-21.15, -3.66), Vector2(-21.16, -3.50),
			Vector2(-21.11, -3.48), Vector2(-20.98, -3.66), Vector2(-20.77, -3.69), Vector2(-20.55, -3.86), Vector2(-20.39, -3.86),
			Vector2(-20.21, -4.07), Vector2(-19.70, -4.32), Vector2(-19.66, -4.54), Vector2(-19.35, -4.72), Vector2(-19.23, -4.69),
			Vector2(-19.11, -4.79), Vector2(-19.11, -4.90), Vector2(-19.05, -4.96), Vector2(-18.92, -4.95), Vector2(-18.85, -5.17),
			Vector2(-18.75, -5.26), Vector2(-18.64, -5.26), Vector2(-18.65, -5.52), Vector2(-18.59, -5.70), Vector2(-18.50, -5.69),
			Vector2(-18.23, -6.36), Vector2(-18.32, -6.40), Vector2(-18.45, -6.67), Vector2(-18.71, -6.76), Vector2(-18.89, -7.04),
			Vector2(-18.87, -7.27), Vector2(-18.92, -7.29), Vector2(-19.14, -7.02), Vector2(-19.28, -7.04), Vector2(-19.41, -6.84),
			Vector2(-19.79, -6.81), Vector2(-19.85, -6.96), Vector2(-19.81, -7.30), Vector2(-19.90, -7.45), Vector2(-20.01, -7.37),
			Vector2(-20.03, -7.18), Vector2(-20.07, -7.25), Vector2(-20.09, -7.58), Vector2(-20.35, -7.87), Vector2(-20.50, -8.50),
			Vector2(-20.41, -8.49), Vector2(-20.35, -8.58),
		],
	},
	"indian": {
		"name_key": "region.indian.name",
		"species_key": "region.indian.species",
		"coastal_pop": 0.85,
		"heat_sensitivity": 1.00,
		"anchor": Vector2(-15.55, 5.60),
		"polygon": [
			Vector2(-12.24, -6.36), Vector2(-12.12, -5.94), Vector2(-11.92, -5.53), Vector2(-11.83, -5.49), Vector2(-11.84, -5.42),
			Vector2(-11.69, -5.08), Vector2(-11.65, -4.82), Vector2(-11.73, -4.44), Vector2(-11.44, -4.33), Vector2(-11.12, -4.65),
			Vector2(-11.10, -4.60), Vector2(-11.42, -3.44), Vector2(-11.64, -2.21), Vector2(-11.66, -1.78), Vector2(-11.61, -1.35),
			Vector2(-11.40, -1.03), Vector2(-10.88, -0.56), Vector2(-10.95, -0.01), Vector2(-10.71, 0.27), Vector2(-10.62, 1.23),
			Vector2(-10.29, 1.43), Vector2(-9.98, 1.42), Vector2(-9.88, 1.95), Vector2(-9.59, 2.09), Vector2(-9.41, 2.46),
			Vector2(-9.10, 2.69), Vector2(-8.74, 2.60), Vector2(-8.47, 2.62), Vector2(-8.18, 2.79), Vector2(-7.86, 2.49),
			Vector2(-7.63, 2.71), Vector2(-7.34, 2.91), Vector2(-7.03, 2.84), Vector2(-6.48, 3.10), Vector2(-6.18, 3.08),
			Vector2(-5.89, 3.83), Vector2(-5.76, 4.07), Vector2(-5.92, 4.33), Vector2(-5.93, 4.48), Vector2(-6.01, 4.43),
			Vector2(-6.09, 4.61), Vector2(-6.11, 4.54), Vector2(-6.16, 4.54), Vector2(-6.32, 4.81), Vector2(-6.33, 5.08),
			Vector2(-6.59, 5.48), Vector2(-6.77, 5.56), Vector2(-6.88, 5.55), Vector2(-6.96, 5.65), Vector2(-7.21, 5.77),
			Vector2(-7.25, 5.74), Vector2(-7.37, 5.77), Vector2(-7.78, 6.11), Vector2(-7.81, 6.07), Vector2(-7.87, 6.07),
			Vector2(-7.96, 6.31), Vector2(-7.94, 6.49), Vector2(-8.03, 6.88), Vector2(-7.92, 7.25), Vector2(-7.97, 7.19),
			Vector2(-8.03, 7.22), Vector2(-8.00, 7.34), Vector2(-8.05, 7.37), Vector2(-7.90, 7.76), Vector2(-7.88, 7.99),
			Vector2(-7.79, 8.12), Vector2(-7.71, 8.39), Vector2(-7.72, 8.56), Vector2(-7.57, 9.22), Vector2(-7.62, 9.59),
			Vector2(-7.71, 9.63), Vector2(-7.71, 9.86), Vector2(-7.39, 10.13), Vector2(-7.08, 10.15), Vector2(-6.90, 9.96),
			Vector2(-6.83, 9.97), Vector2(-6.72, 9.81), Vector2(-6.47, 9.76), Vector2(-6.30, 9.82), Vector2(-5.99, 9.78),
			Vector2(-5.88, 9.48), Vector2(-5.53, 9.26), Vector2(-5.35, 9.28), Vector2(-4.88, 9.07), Vector2(-4.56, 9.04),
			Vector2(-4.38, 9.19), Vector2(-4.24, 9.20), Vector2(-4.03, 9.36), Vector2(-4.07, 9.42), Vector2(-3.83, 9.77),
			Vector2(-3.84, 9.94), Vector2(-3.63, 10.12), Vector2(-3.54, 9.82), Vector2(-3.43, 9.73), Vector2(-3.38, 9.64),
			Vector2(-3.35, 9.71), Vector2(-3.54, 10.18), Vector2(-3.50, 10.22), Vector2(-3.29, 10.14), Vector2(-3.25, 10.04),
			Vector2(-3.22, 10.13), Vector2(-3.29, 10.31), Vector2(-3.08, 10.36), Vector2(-3.00, 10.46), Vector2(-2.92, 10.87),
			Vector2(-2.79, 11.07), Vector2(-2.47, 11.22), Vector2(-1.56, 12.74), Vector2(-1.64, 13.14), Vector2(-1.50, 13.39),
			Vector2(-1.30, 13.58), Vector2(-1.57, 14.04), Vector2(-1.57, 14.41), Vector2(-1.70, 14.62), Vector2(-1.77, 14.86),
			Vector2(-3.07, 14.44), Vector2(-3.42, 14.49), Vector2(-4.06, 14.11), Vector2(-4.42, 13.99), Vector2(-4.78, 14.08),
			Vector2(-5.12, 14.11), Vector2(-5.44, 14.06), Vector2(-5.80, 13.94), Vector2(-6.17, 14.20), Vector2(-6.49, 14.26),
			Vector2(-6.79, 14.18), Vector2(-7.11, 13.55), Vector2(-7.47, 13.47), Vector2(-8.15, 13.24), Vector2(-8.50, 13.17),
			Vector2(-9.20, 13.11), Vector2(-9.57, 13.35), Vector2(-9.89, 13.60), Vector2(-10.21, 13.42), Vector2(-10.59, 13.40),
			Vector2(-10.90, 13.84), Vector2(-11.25, 13.46), Vector2(-11.58, 13.91), Vector2(-11.92, 13.47), Vector2(-12.29, 13.78),
			Vector2(-12.63, 13.77), Vector2(-12.94, 14.02), Vector2(-13.29, 13.55), Vector2(-13.63, 13.80), Vector2(-13.97, 13.53),
			Vector2(-14.33, 13.59), Vector2(-14.66, 13.55), Vector2(-14.98, 13.45), Vector2(-15.37, 13.05), Vector2(-15.73, 13.62),
			Vector2(-16.06, 13.67), Vector2(-16.40, 14.19), Vector2(-16.70, 13.92), Vector2(-17.41, 13.94), Vector2(-17.74, 13.98),
			Vector2(-18.39, 13.79), Vector2(-18.73, 13.29), Vector2(-19.11, 13.42), Vector2(-19.44, 13.47), Vector2(-19.76, 13.35),
			Vector2(-20.12, 13.25), Vector2(-20.45, 13.31), Vector2(-20.80, 13.01), Vector2(-21.16, 13.34), Vector2(-21.85, 13.08),
			Vector2(-22.21, 13.31), Vector2(-22.53, 13.63), Vector2(-22.86, 13.59), Vector2(-23.21, 13.72), Vector2(-23.54, 13.81),
			Vector2(-23.87, 13.94), Vector2(-24.21, 13.84), Vector2(-24.55, 13.89), Vector2(-24.90, 13.79), Vector2(-25.25, 13.88),
			Vector2(-25.87, 13.98), Vector2(-25.90, 13.58), Vector2(-26.10, 13.23), Vector2(-26.16, 12.80), Vector2(-25.84, 12.62),
			Vector2(-25.70, 12.24), Vector2(-25.71, 11.72), Vector2(-25.60, 11.40), Vector2(-25.50, 10.90), Vector2(-25.83, 10.64),
			Vector2(-25.80, 10.22), Vector2(-25.84, 10.00), Vector2(-25.77, 9.93), Vector2(-25.42, 9.77), Vector2(-25.23, 9.75),
			Vector2(-25.01, 9.81), Vector2(-24.93, 9.76), Vector2(-24.78, 9.82), Vector2(-24.76, 9.71), Vector2(-24.67, 9.70),
			Vector2(-24.31, 9.42), Vector2(-23.54, 8.18), Vector2(-23.39, 7.40), Vector2(-23.45, 7.37), Vector2(-23.47, 7.29),
			Vector2(-23.00, 6.93), Vector2(-22.87, 6.67), Vector2(-22.93, 6.62), Vector2(-22.90, 6.49), Vector2(-23.06, 5.75),
			Vector2(-23.04, 5.56), Vector2(-22.55, 4.94), Vector2(-22.16, 4.70), Vector2(-22.02, 4.51), Vector2(-21.89, 4.10),
			Vector2(-21.95, 2.98), Vector2(-22.20, 2.34), Vector2(-22.15, 1.87), Vector2(-22.27, 1.77), Vector2(-22.28, 1.64),
			Vector2(-22.19, 1.31), Vector2(-22.12, 1.22), Vector2(-22.00, 0.74), Vector2(-21.93, 0.72), Vector2(-21.88, 0.60),
			Vector2(-21.75, 0.50), Vector2(-21.45, -0.06), Vector2(-20.79, -0.77), Vector2(-20.39, -1.46), Vector2(-20.01, -2.54),
			Vector2(-19.96, -2.97), Vector2(-19.88, -2.90), Vector2(-19.08, -2.97), Vector2(-18.66, -2.53), Vector2(-18.45, -2.13),
			Vector2(-18.07, -2.39), Vector2(-17.83, -2.44), Vector2(-17.66, -2.13), Vector2(-17.40, -1.97), Vector2(-17.14, -2.02),
			Vector2(-16.82, -1.82), Vector2(-16.62, -2.46), Vector2(-16.42, -2.45), Vector2(-16.12, -2.22), Vector2(-15.60, -2.33),
			Vector2(-15.33, -2.29), Vector2(-15.08, -2.38), Vector2(-15.03, -2.37), Vector2(-14.87, -2.13), Vector2(-14.70, -2.45),
			Vector2(-14.50, -2.54), Vector2(-14.57, -2.65), Vector2(-14.50, -2.82), Vector2(-14.39, -2.83), Vector2(-14.39, -3.34),
			Vector2(-14.31, -3.62), Vector2(-14.36, -4.22), Vector2(-14.31, -4.40), Vector2(-13.94, -4.60), Vector2(-13.94, -4.73),
			Vector2(-13.76, -4.91), Vector2(-13.40, -5.42), Vector2(-13.12, -5.62), Vector2(-13.01, -5.81), Vector2(-13.02, -6.00),
			Vector2(-12.66, -6.06), Vector2(-12.64, -6.14), Vector2(-12.52, -6.09), Vector2(-12.50, -6.13), Vector2(-12.41, -6.07),
			Vector2(-12.33, -6.28), Vector2(-12.34, -6.37),
		],
	},
	"coral_triangle": {
		"name_key": "region.coral_triangle.name",
		"species_key": "region.coral_triangle.species",
		"coastal_pop": 0.90,
		"heat_sensitivity": 1.30,
		"anchor": Vector2(-5.28, 1.52),
		"polygon": [
			Vector2(-6.02, -5.58), Vector2(-5.77, -5.26), Vector2(-5.44, -5.33), Vector2(-5.16, -5.20), Vector2(-4.85, -5.34),
			Vector2(-4.65, -5.04), Vector2(-4.45, -4.49), Vector2(-4.14, -4.51), Vector2(-3.92, -4.27), Vector2(-3.57, -4.27),
			Vector2(-3.28, -4.22), Vector2(-3.08, -3.94), Vector2(-2.90, -3.60), Vector2(-2.81, -2.96), Vector2(-2.40, -3.08),
			Vector2(-2.19, -2.80), Vector2(-1.84, -2.82), Vector2(-1.67, -2.49), Vector2(-1.20, -2.03), Vector2(-1.05, -1.60),
			Vector2(-0.50, -1.26), Vector2(-0.05, -0.80), Vector2(0.11, -0.11), Vector2(0.25, 0.21), Vector2(0.25, 0.60),
			Vector2(0.30, 0.96), Vector2(0.21, 1.24), Vector2(0.23, 1.52), Vector2(0.01, 1.72), Vector2(-0.07, 2.11),
			Vector2(-0.32, 2.29), Vector2(-0.34, 2.84), Vector2(-0.55, 3.04), Vector2(-1.13, 2.53), Vector2(-1.38, 2.92),
			Vector2(-1.62, 2.70), Vector2(-2.16, 2.90), Vector2(-2.42, 2.92), Vector2(-2.51, 3.05), Vector2(-2.60, 3.45),
			Vector2(-2.57, 3.54), Vector2(-2.60, 3.59), Vector2(-2.59, 4.19), Vector2(-2.75, 4.83), Vector2(-2.84, 4.90),
			Vector2(-2.99, 4.82), Vector2(-3.02, 4.73), Vector2(-3.19, 4.66), Vector2(-3.70, 4.16), Vector2(-3.72, 4.10),
			Vector2(-3.59, 3.82), Vector2(-3.61, 3.74), Vector2(-3.56, 3.74), Vector2(-3.43, 3.43), Vector2(-3.54, 3.22),
			Vector2(-3.61, 3.30), Vector2(-3.68, 3.27), Vector2(-3.78, 3.35), Vector2(-3.90, 3.27), Vector2(-3.96, 3.30),
			Vector2(-4.35, 3.05), Vector2(-4.49, 3.10), Vector2(-4.49, 3.15), Vector2(-4.35, 3.24), Vector2(-4.35, 3.34),
			Vector2(-4.47, 3.38), Vector2(-4.58, 3.33), Vector2(-4.71, 3.46), Vector2(-4.80, 3.64), Vector2(-4.78, 3.70),
			Vector2(-4.85, 3.77), Vector2(-4.95, 4.01), Vector2(-4.92, 4.12), Vector2(-5.09, 4.10), Vector2(-5.35, 3.79),
			Vector2(-5.58, 3.89), Vector2(-5.58, 3.93), Vector2(-5.67, 3.90), Vector2(-5.67, 4.01), Vector2(-5.94, 3.43),
			Vector2(-6.11, 2.97), Vector2(-6.46, 2.99), Vector2(-7.02, 2.72), Vector2(-7.31, 2.79), Vector2(-7.56, 2.62),
			Vector2(-7.86, 2.34), Vector2(-8.19, 2.66), Vector2(-8.44, 2.52), Vector2(-8.75, 2.49), Vector2(-9.08, 2.57),
			Vector2(-9.32, 2.39), Vector2(-9.51, 2.00), Vector2(-9.78, 1.88), Vector2(-9.89, 1.31), Vector2(-10.26, 1.32),
			Vector2(-10.51, 1.16), Vector2(-10.60, 0.23), Vector2(-10.83, -0.04), Vector2(-10.76, -0.61), Vector2(-11.32, -1.10),
			Vector2(-11.50, -1.39), Vector2(-11.55, -1.79), Vector2(-11.53, -2.20), Vector2(-11.31, -3.41), Vector2(-11.05, -4.36),
			Vector2(-11.03, -4.12), Vector2(-10.89, -3.64), Vector2(-10.90, -3.33), Vector2(-10.84, -3.18), Vector2(-10.90, -2.97),
			Vector2(-10.92, -2.12), Vector2(-10.85, -2.12), Vector2(-10.83, -2.19), Vector2(-10.58, -1.78), Vector2(-10.56, -1.46),
			Vector2(-10.33, -0.74), Vector2(-9.89, -0.30), Vector2(-9.70, -0.33), Vector2(-9.85, -0.78), Vector2(-9.87, -1.35),
			Vector2(-10.22, -1.90), Vector2(-10.34, -1.93), Vector2(-10.43, -2.08), Vector2(-10.55, -2.59), Vector2(-10.67, -2.60),
			Vector2(-10.68, -2.76), Vector2(-10.52, -3.41), Vector2(-10.50, -3.69), Vector2(-10.42, -3.69), Vector2(-10.45, -3.47),
			Vector2(-10.25, -3.47), Vector2(-10.09, -3.36), Vector2(-9.92, -2.92), Vector2(-9.75, -2.87), Vector2(-9.63, -2.74),
			Vector2(-9.68, -2.56), Vector2(-9.60, -2.34), Vector2(-9.55, -2.34), Vector2(-9.14, -2.85), Vector2(-8.75, -3.22),
			Vector2(-8.73, -3.73), Vector2(-8.82, -4.27), Vector2(-8.94, -4.50), Vector2(-9.12, -4.68), Vector2(-9.38, -5.23),
			Vector2(-9.01, -5.26), Vector2(-8.80, -5.35), Vector2(-8.62, -5.40), Vector2(-8.41, -5.30), Vector2(-8.15, -5.24),
			Vector2(-7.95, -5.49), Vector2(-7.74, -5.51), Vector2(-7.58, -5.77), Vector2(-7.37, -5.58), Vector2(-6.91, -5.64),
			Vector2(-6.71, -5.77), Vector2(-6.53, -5.83),
		],
	},
	"east_asian": {
		"name_key": "region.east_asian.name",
		"species_key": "region.east_asian.species",
		"coastal_pop": 1.05,
		"heat_sensitivity": 0.95,
		"anchor": Vector2(-3.94, -11.04),
		"polygon": [
			Vector2(0.95, -19.14), Vector2(1.00, -18.72), Vector2(0.63, -18.20), Vector2(0.31, -18.11), Vector2(0.30, -17.90),
			Vector2(0.14, -17.68), Vector2(0.04, -17.11), Vector2(0.31, -15.44), Vector2(0.09, -15.20), Vector2(0.01, -14.58),
			Vector2(-0.18, -14.20), Vector2(-0.32, -13.74), Vector2(-0.66, -13.64), Vector2(-0.84, -13.23), Vector2(-1.17, -13.07),
			Vector2(-1.33, -12.60), Vector2(-1.43, -12.13), Vector2(-1.68, -11.84), Vector2(-1.83, -11.39), Vector2(-1.80, -10.80),
			Vector2(-2.19, -10.72), Vector2(-2.23, -10.09), Vector2(-2.46, -9.84), Vector2(-2.62, -9.44), Vector2(-2.94, -9.34),
			Vector2(-3.05, -8.86), Vector2(-3.46, -9.00), Vector2(-3.72, -8.72), Vector2(-3.99, -8.51), Vector2(-4.38, -7.80),
			Vector2(-4.46, -7.27), Vector2(-4.77, -7.17), Vector2(-4.91, -6.70), Vector2(-5.14, -6.48), Vector2(-5.44, -6.42),
			Vector2(-6.76, -5.87), Vector2(-6.95, -5.74), Vector2(-7.34, -5.70), Vector2(-7.61, -5.94), Vector2(-7.80, -5.61),
			Vector2(-8.01, -5.60), Vector2(-8.20, -5.36), Vector2(-8.37, -5.40), Vector2(-8.61, -5.52), Vector2(-8.84, -5.46),
			Vector2(-9.02, -5.38), Vector2(-9.33, -5.62), Vector2(-9.24, -5.77), Vector2(-8.91, -6.05), Vector2(-8.72, -5.99),
			Vector2(-8.75, -5.89), Vector2(-8.69, -5.63), Vector2(-8.52, -5.67), Vector2(-8.45, -5.98), Vector2(-8.00, -6.17),
			Vector2(-7.91, -6.28), Vector2(-7.84, -6.19), Vector2(-7.71, -6.33), Vector2(-7.49, -6.37), Vector2(-6.95, -6.90),
			Vector2(-6.47, -7.95), Vector2(-6.36, -7.98), Vector2(-6.28, -8.52), Vector2(-6.40, -8.61), Vector2(-6.43, -8.73),
			Vector2(-6.32, -8.82), Vector2(-6.31, -9.07), Vector2(-6.44, -9.32), Vector2(-6.65, -9.91), Vector2(-6.83, -10.07),
			Vector2(-6.75, -10.26), Vector2(-6.57, -10.41), Vector2(-6.48, -10.58), Vector2(-6.19, -10.67), Vector2(-6.24, -10.90),
			Vector2(-6.37, -10.91), Vector2(-6.56, -11.05), Vector2(-6.79, -10.82), Vector2(-6.89, -10.88), Vector2(-6.90, -11.03),
			Vector2(-7.06, -11.09), Vector2(-7.14, -11.27), Vector2(-7.08, -11.38), Vector2(-6.89, -11.40), Vector2(-6.76, -11.62),
			Vector2(-6.42, -11.93), Vector2(-6.35, -11.82), Vector2(-6.50, -11.61), Vector2(-6.46, -11.49), Vector2(-6.57, -11.33),
			Vector2(-6.53, -11.28), Vector2(-6.29, -11.38), Vector2(-6.15, -11.54), Vector2(-5.90, -11.62), Vector2(-5.74, -11.52),
			Vector2(-5.76, -11.26), Vector2(-5.87, -11.07), Vector2(-5.71, -10.87), Vector2(-5.62, -10.97), Vector2(-5.56, -10.93),
			Vector2(-5.46, -10.70), Vector2(-5.60, -10.66), Vector2(-5.50, -10.30), Vector2(-5.51, -9.85), Vector2(-5.28, -9.88),
			Vector2(-5.13, -10.01), Vector2(-4.94, -10.08), Vector2(-4.86, -10.28), Vector2(-4.86, -10.66), Vector2(-5.09, -11.25),
			Vector2(-5.26, -11.44), Vector2(-5.23, -11.58), Vector2(-4.82, -11.95), Vector2(-4.82, -12.20), Vector2(-4.70, -12.38),
			Vector2(-4.62, -12.36), Vector2(-4.58, -12.51), Vector2(-4.37, -12.71), Vector2(-4.26, -12.57), Vector2(-4.11, -12.57),
			Vector2(-3.84, -12.78), Vector2(-3.18, -13.78), Vector2(-3.12, -14.02), Vector2(-2.83, -14.54), Vector2(-2.73, -15.55),
			Vector2(-2.58, -15.92), Vector2(-2.58, -16.25), Vector2(-2.88, -16.70), Vector2(-3.13, -16.72), Vector2(-3.24, -16.54),
			Vector2(-3.39, -16.61), Vector2(-3.48, -16.86), Vector2(-3.74, -16.89), Vector2(-2.44, -18.53), Vector2(-1.83, -18.65),
			Vector2(-1.23, -18.58), Vector2(-0.99, -18.78), Vector2(-0.74, -18.73), Vector2(-0.76, -18.41), Vector2(0.08, -18.58),
			Vector2(-0.10, -18.86), Vector2(0.30, -19.44), Vector2(0.84, -19.52),
		],
	},
	"north_pacific": {
		"name_key": "region.north_pacific.name",
		"species_key": "region.north_pacific.species",
		"coastal_pop": 0.70,
		"heat_sensitivity": 0.90,
		"anchor": Vector2(8.26, -9.16),
		"polygon": [
			Vector2(6.52, -21.07), Vector2(6.77, -20.91), Vector2(7.02, -20.89), Vector2(7.31, -20.74), Vector2(7.39, -20.93),
			Vector2(7.69, -20.82), Vector2(7.95, -20.87), Vector2(8.12, -20.77), Vector2(8.20, -20.88), Vector2(8.37, -20.94),
			Vector2(8.30, -20.83), Vector2(8.42, -20.74), Vector2(8.45, -20.57), Vector2(8.34, -20.47), Vector2(8.19, -20.52),
			Vector2(8.04, -20.30), Vector2(7.93, -20.36), Vector2(7.73, -20.32), Vector2(7.66, -20.09), Vector2(7.50, -19.85),
			Vector2(7.41, -19.58), Vector2(7.57, -19.40), Vector2(7.57, -19.15), Vector2(7.90, -18.84), Vector2(8.15, -18.90),
			Vector2(8.24, -18.80), Vector2(8.22, -18.38), Vector2(8.39, -18.38), Vector2(8.55, -18.51), Vector2(8.61, -18.34),
			Vector2(8.67, -18.34), Vector2(8.70, -18.42), Vector2(8.82, -18.25), Vector2(8.93, -18.40), Vector2(8.98, -18.34),
			Vector2(9.13, -18.42), Vector2(9.04, -17.99), Vector2(8.60, -17.55), Vector2(8.51, -17.40), Vector2(8.27, -17.35),
			Vector2(7.64, -16.81), Vector2(7.70, -16.69), Vector2(8.07, -16.81), Vector2(8.59, -17.18), Vector2(8.73, -17.15),
			Vector2(8.97, -17.33), Vector2(9.03, -17.51), Vector2(9.33, -17.71), Vector2(9.38, -17.89), Vector2(9.78, -18.17),
			Vector2(9.98, -18.49), Vector2(9.84, -18.69), Vector2(10.09, -18.96), Vector2(10.25, -19.25), Vector2(10.16, -18.85),
			Vector2(10.20, -18.55), Vector2(10.46, -18.67), Vector2(10.63, -18.80), Vector2(10.98, -18.92), Vector2(10.94, -19.22),
			Vector2(11.10, -19.28), Vector2(11.32, -19.12), Vector2(11.71, -18.92), Vector2(11.98, -18.95), Vector2(12.49, -18.74),
			Vector2(12.88, -18.32), Vector2(13.12, -18.19), Vector2(13.59, -18.15), Vector2(13.68, -17.80), Vector2(13.93, -17.48),
			Vector2(13.98, -17.14), Vector2(14.26, -16.87), Vector2(14.26, -16.69), Vector2(14.49, -16.40), Vector2(14.53, -16.10),
			Vector2(14.77, -15.94), Vector2(14.75, -15.73), Vector2(14.86, -15.38), Vector2(15.22, -15.23), Vector2(15.25, -15.19),
			Vector2(15.49, -14.55), Vector2(15.41, -14.58), Vector2(15.38, -14.46), Vector2(15.53, -13.53), Vector2(15.48, -12.92),
			Vector2(15.41, -12.60), Vector2(15.47, -12.34), Vector2(15.44, -11.78), Vector2(15.54, -11.60), Vector2(15.56, -11.33),
			Vector2(15.80, -10.95), Vector2(15.95, -10.43), Vector2(16.14, -10.13), Vector2(16.16, -9.94), Vector2(16.23, -9.87),
			Vector2(16.41, -9.84), Vector2(16.48, -9.76), Vector2(16.57, -9.75), Vector2(16.60, -9.66), Vector2(16.68, -9.63),
			Vector2(16.80, -9.46), Vector2(17.14, -8.39), Vector2(17.40, -8.11), Vector2(17.39, -7.99), Vector2(17.34, -7.92),
			Vector2(17.26, -7.94), Vector2(17.23, -7.89), Vector2(17.56, -7.47), Vector2(17.58, -7.51), Vector2(17.76, -7.34),
			Vector2(17.78, -6.96), Vector2(18.14, -6.58), Vector2(18.21, -6.35), Vector2(18.40, -6.52), Vector2(18.24, -6.88),
			Vector2(18.14, -6.89), Vector2(17.97, -7.57), Vector2(17.84, -7.72), Vector2(17.38, -8.61), Vector2(17.33, -8.97),
			Vector2(17.34, -9.03), Vector2(17.42, -8.97), Vector2(17.49, -8.98), Vector2(17.60, -8.88), Vector2(17.59, -8.79),
			Vector2(17.77, -8.21), Vector2(17.99, -7.90), Vector2(18.09, -7.87), Vector2(18.12, -7.68), Vector2(18.34, -7.47),
			Vector2(18.31, -7.29), Vector2(18.52, -7.08), Vector2(18.96, -6.39), Vector2(19.11, -6.01), Vector2(19.08, -5.79),
			Vector2(19.01, -5.75), Vector2(19.17, -5.39), Vector2(19.38, -5.21), Vector2(19.46, -5.08), Vector2(19.77, -4.98),
			Vector2(19.98, -4.76), Vector2(20.82, -4.32), Vector2(21.18, -4.48), Vector2(21.31, -4.41), Vector2(21.74, -3.90),
			Vector2(21.94, -3.83), Vector2(22.10, -3.72), Vector2(22.50, -3.61), Vector2(22.85, -3.08), Vector2(22.81, -3.01),
			Vector2(22.87, -2.96), Vector2(22.85, -2.80), Vector2(23.00, -2.61), Vector2(23.05, -2.62), Vector2(23.07, -2.67),
			Vector2(23.26, -2.49), Vector2(23.25, -2.38), Vector2(23.44, -2.19), Vector2(23.49, -2.21), Vector2(23.49, -2.25),
			Vector2(23.64, -2.22), Vector2(23.68, -2.09), Vector2(23.74, -2.08), Vector2(23.81, -1.95), Vector2(24.06, -2.07),
			Vector2(23.96, -2.24), Vector2(24.10, -2.44), Vector2(24.16, -2.45), Vector2(24.30, -2.30), Vector2(24.25, -2.23),
			Vector2(24.43, -1.86), Vector2(23.30, -1.91), Vector2(22.96, -1.83), Vector2(22.28, -1.73), Vector2(21.94, -1.78),
			Vector2(21.61, -1.74), Vector2(21.26, -1.83), Vector2(20.91, -1.75), Vector2(20.57, -1.74), Vector2(19.90, -1.62),
			Vector2(19.58, -1.48), Vector2(19.21, -1.63), Vector2(18.91, -1.34), Vector2(18.54, -1.59), Vector2(18.20, -1.38),
			Vector2(17.87, -1.39), Vector2(17.53, -1.37), Vector2(17.18, -1.46), Vector2(16.82, -1.43), Vector2(16.47, -1.35),
			Vector2(15.83, -0.89), Vector2(15.50, -0.82), Vector2(15.18, -0.87), Vector2(14.86, -1.00), Vector2(14.53, -1.25),
			Vector2(14.17, -1.22), Vector2(13.83, -1.34), Vector2(13.47, -1.27), Vector2(13.12, -1.25), Vector2(12.78, -1.02),
			Vector2(12.48, -1.40), Vector2(12.12, -1.33), Vector2(11.81, -1.56), Vector2(11.46, -1.53), Vector2(11.14, -1.43),
			Vector2(10.81, -1.45), Vector2(10.42, -1.64), Vector2(10.11, -1.43), Vector2(9.71, -1.77), Vector2(9.39, -1.28),
			Vector2(9.09, -1.13), Vector2(8.41, -1.09), Vector2(8.08, -1.03), Vector2(7.72, -1.13), Vector2(7.43, -0.92),
			Vector2(7.13, -1.23), Vector2(6.74, -0.84), Vector2(6.44, -1.07), Vector2(5.37, -0.86), Vector2(5.05, -1.08),
			Vector2(4.69, -0.93), Vector2(4.39, -1.20), Vector2(4.05, -1.25), Vector2(3.73, -1.52), Vector2(3.39, -1.48),
			Vector2(3.02, -1.63), Vector2(2.69, -1.42), Vector2(2.34, -1.40), Vector2(2.02, -1.19), Vector2(1.69, -1.22),
			Vector2(1.34, -1.16), Vector2(1.00, -1.14), Vector2(0.02, -0.89), Vector2(-0.43, -1.35), Vector2(-0.96, -1.67),
			Vector2(-1.11, -2.09), Vector2(-1.58, -2.56), Vector2(-1.78, -2.94), Vector2(-2.14, -2.91), Vector2(-2.36, -3.20),
			Vector2(-2.72, -3.10), Vector2(-2.80, -3.64), Vector2(-2.99, -4.00), Vector2(-3.22, -4.32), Vector2(-3.56, -4.38),
			Vector2(-3.87, -4.38), Vector2(-4.09, -4.63), Vector2(-4.37, -4.61), Vector2(-4.55, -5.09), Vector2(-4.81, -5.48),
			Vector2(-5.16, -5.32), Vector2(-5.43, -5.45), Vector2(-5.73, -5.38), Vector2(-5.95, -5.67), Vector2(-6.40, -5.89),
			Vector2(-5.41, -6.32), Vector2(-5.09, -6.38), Vector2(-4.81, -6.64), Vector2(-4.68, -7.09), Vector2(-4.36, -7.18),
			Vector2(-4.28, -7.77), Vector2(-3.90, -8.44), Vector2(-3.65, -8.64), Vector2(-3.43, -8.87), Vector2(-2.97, -8.72),
			Vector2(-2.85, -9.25), Vector2(-2.54, -9.35), Vector2(-2.37, -9.78), Vector2(-2.12, -10.04), Vector2(-2.09, -10.63),
			Vector2(-1.68, -10.71), Vector2(-1.72, -11.38), Vector2(-1.59, -11.78), Vector2(-1.33, -12.08), Vector2(-1.23, -12.57),
			Vector2(-1.08, -12.99), Vector2(-0.75, -13.15), Vector2(-0.58, -13.55), Vector2(-0.23, -13.66), Vector2(-0.08, -14.16),
			Vector2(0.12, -14.54), Vector2(0.20, -15.15), Vector2(0.45, -15.42), Vector2(0.58, -15.70), Vector2(0.66, -15.80),
			Vector2(0.67, -15.89), Vector2(0.89, -16.22), Vector2(1.00, -16.26), Vector2(1.03, -16.45), Vector2(1.21, -16.77),
			Vector2(1.42, -16.89), Vector2(1.34, -17.07), Vector2(1.43, -17.37), Vector2(1.59, -17.38), Vector2(1.61, -17.96),
			Vector2(1.87, -18.82), Vector2(1.91, -18.81), Vector2(2.07, -18.96), Vector2(2.16, -18.81), Vector2(2.66, -19.15),
			Vector2(2.96, -18.84), Vector2(3.04, -19.08), Vector2(3.61, -19.61), Vector2(3.78, -19.66), Vector2(4.30, -19.98),
			Vector2(4.67, -19.88), Vector2(4.74, -20.03), Vector2(4.72, -20.24), Vector2(4.63, -20.36), Vector2(4.52, -20.72),
			Vector2(4.40, -20.87), Vector2(4.56, -20.86), Vector2(4.71, -20.98), Vector2(4.89, -20.69), Vector2(4.96, -20.70),
			Vector2(5.14, -21.21), Vector2(5.37, -20.69), Vector2(5.44, -20.69), Vector2(5.59, -20.98), Vector2(5.77, -20.88),
			Vector2(5.92, -20.71), Vector2(6.18, -20.69), Vector2(6.31, -20.83), Vector2(6.32, -21.24), Vector2(6.41, -21.25),
		],
	},
	"south_pacific": {
		"name_key": "region.south_pacific.name",
		"species_key": "region.south_pacific.species",
		"coastal_pop": 0.45,
		"heat_sensitivity": 1.10,
		"anchor": Vector2(10.94, 6.18),
		"polygon": [
			Vector2(24.45, -1.75), Vector2(24.47, -1.63), Vector2(24.43, -1.56), Vector2(24.48, -1.29), Vector2(24.44, -1.12),
			Vector2(24.50, -1.05), Vector2(24.37, -0.79), Vector2(24.26, -0.76), Vector2(24.23, -0.52), Vector2(24.14, -0.50),
			Vector2(24.17, -0.40), Vector2(23.94, -0.23), Vector2(23.96, -0.10), Vector2(23.86, 0.22), Vector2(23.78, 0.27),
			Vector2(23.81, 0.53), Vector2(23.76, 0.63), Vector2(23.94, 0.81), Vector2(23.99, 0.72), Vector2(23.91, 0.92),
			Vector2(23.75, 1.10), Vector2(23.69, 1.31), Vector2(23.78, 1.57), Vector2(23.71, 1.71), Vector2(24.02, 2.01),
			Vector2(24.68, 3.76), Vector2(24.65, 3.85), Vector2(24.73, 4.10), Vector2(24.88, 4.28), Vector2(25.60, 4.87),
			Vector2(25.62, 4.99), Vector2(25.78, 5.12), Vector2(25.86, 6.00), Vector2(25.71, 7.83), Vector2(25.59, 8.20),
			Vector2(25.62, 8.58), Vector2(25.56, 8.83), Vector2(25.60, 9.29), Vector2(25.28, 10.72), Vector2(25.19, 10.74),
			Vector2(25.26, 11.43), Vector2(25.17, 11.65), Vector2(25.05, 12.78), Vector2(25.24, 12.86), Vector2(25.30, 12.45),
			Vector2(25.36, 12.49), Vector2(25.27, 13.11), Vector2(25.05, 12.99), Vector2(24.98, 13.60), Vector2(24.78, 13.94),
			Vector2(25.06, 14.04), Vector2(24.88, 14.27), Vector2(24.80, 14.63), Vector2(24.83, 15.25), Vector2(24.92, 15.49),
			Vector2(24.87, 15.70), Vector2(24.93, 15.95), Vector2(25.41, 16.44), Vector2(25.64, 16.57), Vector2(25.77, 16.56),
			Vector2(25.80, 16.19), Vector2(26.03, 15.99), Vector2(26.07, 15.99), Vector2(26.06, 16.61), Vector2(26.21, 16.79),
			Vector2(26.29, 17.08), Vector2(26.53, 17.55), Vector2(26.63, 17.82), Vector2(26.77, 18.01), Vector2(26.81, 18.25),
			Vector2(24.91, 17.27), Vector2(24.60, 16.93), Vector2(24.25, 16.86), Vector2(23.93, 16.55), Vector2(23.58, 16.50),
			Vector2(23.25, 16.33), Vector2(22.91, 16.24), Vector2(22.60, 15.97), Vector2(21.90, 15.64), Vector2(21.56, 15.66),
			Vector2(20.88, 15.35), Vector2(20.53, 15.40), Vector2(20.23, 15.27), Vector2(19.90, 14.70), Vector2(19.54, 14.91),
			Vector2(19.22, 14.30), Vector2(18.81, 14.92), Vector2(18.51, 14.74), Vector2(18.16, 14.70), Vector2(17.82, 14.52),
			Vector2(17.46, 14.59), Vector2(17.10, 14.54), Vector2(16.74, 14.95), Vector2(16.43, 14.85), Vector2(15.72, 14.87),
			Vector2(15.41, 15.02), Vector2(15.07, 14.43), Vector2(14.70, 14.84), Vector2(14.36, 14.57), Vector2(14.03, 14.91),
			Vector2(13.71, 14.40), Vector2(13.01, 14.38), Vector2(12.66, 14.23), Vector2(12.28, 14.37), Vector2(11.96, 14.76),
			Vector2(11.63, 14.36), Vector2(11.28, 14.65), Vector2(10.96, 14.36), Vector2(10.59, 14.30), Vector2(10.23, 14.35),
			Vector2(9.93, 14.54), Vector2(9.59, 14.32), Vector2(9.24, 14.32), Vector2(8.87, 14.01), Vector2(8.54, 14.19),
			Vector2(8.15, 13.80), Vector2(7.82, 14.34), Vector2(7.48, 14.23), Vector2(7.17, 14.53), Vector2(6.80, 14.14),
			Vector2(6.45, 14.46), Vector2(5.76, 14.60), Vector2(5.11, 15.16), Vector2(4.78, 15.11), Vector2(4.44, 15.15),
			Vector2(4.07, 15.11), Vector2(3.74, 15.45), Vector2(3.41, 15.43), Vector2(3.08, 15.55), Vector2(2.75, 15.32),
			Vector2(2.40, 15.34), Vector2(2.07, 15.07), Vector2(1.69, 15.10), Vector2(1.35, 15.21), Vector2(0.68, 15.19),
			Vector2(-0.35, 15.11), Vector2(-0.69, 15.00), Vector2(-1.04, 15.00), Vector2(-1.66, 14.88), Vector2(-1.60, 14.67),
			Vector2(-1.46, 14.44), Vector2(-1.46, 14.08), Vector2(-1.17, 13.56), Vector2(-1.41, 13.32), Vector2(-1.52, 13.12),
			Vector2(-1.45, 12.72), Vector2(-1.58, 12.49), Vector2(-1.58, 11.33), Vector2(-1.27, 11.02), Vector2(-1.05, 11.00),
			Vector2(-0.92, 10.87), Vector2(-0.91, 10.54), Vector2(-0.59, 9.50), Vector2(-0.45, 9.35), Vector2(-0.36, 9.06),
			Vector2(-0.23, 7.97), Vector2(-0.33, 7.72), Vector2(-0.37, 7.13), Vector2(-0.75, 6.60), Vector2(-0.78, 6.27),
			Vector2(-0.83, 6.25), Vector2(-0.86, 6.28), Vector2(-0.94, 6.16), Vector2(-1.00, 6.21), Vector2(-1.06, 5.95),
			Vector2(-1.17, 5.79), Vector2(-1.13, 5.71), Vector2(-1.62, 5.28), Vector2(-1.68, 5.11), Vector2(-1.66, 4.96),
			Vector2(-1.71, 4.70), Vector2(-1.76, 4.66), Vector2(-1.81, 4.16), Vector2(-1.99, 3.88), Vector2(-2.10, 3.98),
			Vector2(-2.24, 3.29), Vector2(-2.29, 3.25), Vector2(-2.34, 3.04), Vector2(-2.13, 3.01), Vector2(-1.65, 2.83),
			Vector2(-1.35, 3.09), Vector2(-1.11, 2.70), Vector2(-0.54, 3.19), Vector2(-0.23, 2.89), Vector2(-0.21, 2.35),
			Vector2(0.03, 2.17), Vector2(0.11, 1.77), Vector2(0.35, 1.56), Vector2(0.32, 1.25), Vector2(0.41, 0.97),
			Vector2(0.36, 0.59), Vector2(0.36, 0.19), Vector2(0.22, -0.14), Vector2(0.07, -0.79), Vector2(1.02, -1.03),
			Vector2(1.36, -1.05), Vector2(1.69, -1.11), Vector2(2.05, -1.08), Vector2(2.38, -1.29), Vector2(2.72, -1.31),
			Vector2(3.03, -1.51), Vector2(3.38, -1.37), Vector2(3.70, -1.41), Vector2(4.00, -1.15), Vector2(4.34, -1.09),
			Vector2(4.67, -0.81), Vector2(5.04, -0.96), Vector2(5.35, -0.74), Vector2(6.41, -0.95), Vector2(6.75, -0.69),
			Vector2(7.13, -1.08), Vector2(7.42, -0.77), Vector2(7.74, -1.01), Vector2(8.07, -0.92), Vector2(8.76, -1.00),
			Vector2(9.12, -1.02), Vector2(9.47, -1.20), Vector2(9.74, -1.61), Vector2(10.10, -1.29), Vector2(10.43, -1.52),
			Vector2(10.78, -1.35), Vector2(11.15, -1.32), Vector2(11.48, -1.42), Vector2(11.78, -1.45), Vector2(12.09, -1.21),
			Vector2(12.44, -1.28), Vector2(12.75, -0.87), Vector2(13.15, -1.14), Vector2(13.49, -1.16), Vector2(13.83, -1.22),
			Vector2(14.16, -1.10), Vector2(14.49, -1.13), Vector2(14.80, -0.90), Vector2(15.15, -0.76), Vector2(15.50, -0.71),
			Vector2(15.88, -0.79), Vector2(16.52, -1.24), Vector2(16.84, -1.32), Vector2(17.17, -1.35), Vector2(17.52, -1.25),
			Vector2(17.87, -1.28), Vector2(18.23, -1.27), Vector2(18.54, -1.46), Vector2(18.92, -1.20), Vector2(19.24, -1.50),
			Vector2(19.59, -1.36), Vector2(19.93, -1.52), Vector2(20.59, -1.63), Vector2(20.93, -1.64), Vector2(21.26, -1.72),
			Vector2(21.60, -1.63), Vector2(21.94, -1.67), Vector2(22.29, -1.61), Vector2(22.98, -1.72), Vector2(23.31, -1.80),
		],
	},
	"arctic": {
		"name_key": "region.arctic.name",
		"species_key": "region.arctic.species",
		"coastal_pop": 0.25,
		"heat_sensitivity": 1.35,
		"anchor": Vector2(1.92, -25.26),
		"polygon": [
			Vector2(26.24, -29.08), Vector2(26.77, -28.86), Vector2(26.71, -28.68), Vector2(25.27, -28.09), Vector2(25.25, -27.81),
			Vector2(25.71, -27.54), Vector2(26.22, -27.45), Vector2(25.58, -27.24), Vector2(26.19, -26.63), Vector2(27.19, -26.70),
			Vector2(27.59, -26.66), Vector2(28.07, -26.35), Vector2(28.07, -26.11), Vector2(28.32, -25.90), Vector2(28.81, -24.78),
			Vector2(28.59, -24.29), Vector2(28.79, -24.12), Vector2(28.98, -24.19), Vector2(29.32, -23.86), Vector2(29.11, -23.92),
			Vector2(28.89, -23.92), Vector2(28.81, -23.61), Vector2(28.82, -23.25), Vector2(29.10, -23.06), Vector2(29.29, -23.15),
			Vector2(29.53, -23.33), Vector2(29.51, -23.06), Vector2(29.45, -22.88), Vector2(29.16, -22.70), Vector2(28.96, -22.10),
			Vector2(29.09, -21.94), Vector2(29.02, -21.60), Vector2(29.28, -21.18), Vector2(29.31, -20.78), Vector2(29.41, -20.48),
			Vector2(29.66, -20.08), Vector2(29.36, -19.62), Vector2(29.12, -19.77), Vector2(28.83, -19.74), Vector2(28.60, -20.03),
			Vector2(28.34, -20.60), Vector2(28.02, -20.43), Vector2(27.74, -20.45), Vector2(27.14, -20.37), Vector2(26.07, -18.95),
			Vector2(26.04, -19.44), Vector2(25.69, -19.47), Vector2(25.63, -19.62), Vector2(25.18, -20.04), Vector2(25.01, -19.92),
			Vector2(24.49, -20.07), Vector2(24.32, -19.96), Vector2(24.47, -18.91), Vector2(24.23, -18.47), Vector2(24.48, -18.15),
			Vector2(24.61, -17.82), Vector2(24.62, -17.65), Vector2(23.60, -17.03), Vector2(22.94, -17.21), Vector2(22.85, -17.28),
			Vector2(22.62, -17.38), Vector2(22.49, -17.57), Vector2(22.28, -17.72), Vector2(21.91, -17.90), Vector2(21.67, -17.83),
			Vector2(21.49, -18.49), Vector2(21.22, -18.56), Vector2(21.23, -18.99), Vector2(21.31, -19.32), Vector2(21.51, -19.79),
			Vector2(21.73, -20.12), Vector2(21.97, -20.18), Vector2(21.98, -20.48), Vector2(22.12, -20.64), Vector2(22.39, -20.67),
			Vector2(22.63, -20.99), Vector2(22.91, -21.76), Vector2(23.08, -21.64), Vector2(23.38, -21.71), Vector2(23.77, -22.06),
			Vector2(23.80, -22.32), Vector2(23.67, -22.56), Vector2(23.81, -22.80), Vector2(23.79, -23.07), Vector2(23.52, -23.34),
			Vector2(22.90, -23.46), Vector2(22.89, -22.88), Vector2(22.75, -22.48), Vector2(22.59, -22.20), Vector2(22.44, -22.45),
			Vector2(22.50, -22.80), Vector2(22.23, -23.17), Vector2(22.02, -22.87), Vector2(22.01, -23.25), Vector2(21.69, -23.34),
			Vector2(21.84, -23.56), Vector2(21.56, -24.15), Vector2(21.35, -24.38), Vector2(21.06, -24.48), Vector2(20.81, -24.07),
			Vector2(20.80, -23.49), Vector2(21.03, -23.28), Vector2(21.23, -23.00), Vector2(21.15, -22.57), Vector2(21.00, -22.58),
			Vector2(20.95, -22.43), Vector2(20.94, -22.63), Vector2(20.61, -22.81), Vector2(20.40, -22.71), Vector2(20.42, -22.43),
			Vector2(20.18, -22.44), Vector2(19.89, -22.37), Vector2(19.55, -22.58), Vector2(19.35, -22.55), Vector2(19.16, -22.79),
			Vector2(18.99, -22.92), Vector2(18.57, -22.85), Vector2(18.42, -22.65), Vector2(18.61, -22.44), Vector2(18.45, -22.27),
			Vector2(18.26, -22.54), Vector2(18.08, -22.44), Vector2(17.57, -22.39), Vector2(17.32, -22.47), Vector2(17.55, -22.69),
			Vector2(17.24, -22.97), Vector2(17.04, -22.94), Vector2(16.35, -23.20), Vector2(16.05, -23.41), Vector2(15.78, -23.43),
			Vector2(15.70, -23.28), Vector2(15.54, -23.22), Vector2(15.51, -23.57), Vector2(15.46, -23.59), Vector2(15.21, -23.28),
			Vector2(14.92, -23.68), Vector2(14.73, -23.77), Vector2(14.67, -23.49), Vector2(14.58, -23.42), Vector2(14.46, -23.61),
			Vector2(14.11, -23.48), Vector2(13.83, -23.26), Vector2(13.54, -23.32), Vector2(13.29, -23.16), Vector2(13.13, -22.97),
			Vector2(12.97, -23.01), Vector2(12.67, -23.25), Vector2(11.79, -23.58), Vector2(11.54, -23.50), Vector2(11.40, -23.57),
			Vector2(11.03, -23.61), Vector2(10.61, -23.77), Vector2(10.42, -23.72), Vector2(10.17, -23.79), Vector2(10.19, -23.92),
			Vector2(9.79, -23.95), Vector2(9.73, -23.88), Vector2(9.62, -24.07), Vector2(9.29, -24.20), Vector2(8.99, -23.92),
			Vector2(8.81, -23.95), Vector2(8.44, -23.73), Vector2(8.25, -23.66), Vector2(8.04, -23.42), Vector2(7.99, -23.18),
			Vector2(7.77, -22.98), Vector2(7.42, -22.96), Vector2(7.29, -22.65), Vector2(7.58, -22.49), Vector2(7.90, -22.05),
			Vector2(8.13, -21.87), Vector2(8.25, -21.66), Vector2(7.96, -21.64), Vector2(7.99, -21.87), Vector2(7.77, -21.87),
			Vector2(7.02, -21.42), Vector2(7.30, -21.13), Vector2(7.33, -21.06), Vector2(7.25, -20.89), Vector2(7.05, -21.00),
			Vector2(6.81, -21.02), Vector2(6.60, -21.15), Vector2(6.53, -21.26), Vector2(6.58, -21.27), Vector2(6.84, -21.53),
			Vector2(6.42, -22.07), Vector2(5.84, -22.15), Vector2(4.81, -23.07), Vector2(4.76, -23.04), Vector2(4.55, -23.20),
			Vector2(3.99, -23.45), Vector2(3.58, -23.42), Vector2(2.95, -23.56), Vector2(2.84, -23.29), Vector2(2.99, -22.99),
			Vector2(2.81, -22.88), Vector2(2.48, -23.30), Vector2(2.10, -23.25), Vector2(1.74, -23.34), Vector2(1.39, -23.33),
			Vector2(1.14, -23.23), Vector2(0.94, -23.35), Vector2(0.97, -23.70), Vector2(0.79, -23.94), Vector2(0.39, -24.02),
			Vector2(-0.38, -23.93), Vector2(-0.86, -24.30), Vector2(-1.03, -24.62), Vector2(-2.80, -24.96), Vector2(-3.09, -24.70),
			Vector2(-2.96, -24.26), Vector2(-3.23, -24.32), Vector2(-3.37, -24.19), Vector2(-3.73, -24.34), Vector2(-4.05, -24.21),
			Vector2(-4.39, -24.45), Vector2(-4.57, -23.92), Vector2(-4.82, -24.09), Vector2(-5.05, -24.47), Vector2(-4.94, -24.67),
			Vector2(-5.03, -25.04), Vector2(-5.37, -25.34), Vector2(-5.69, -25.33), Vector2(-6.13, -25.44), Vector2(-6.15, -25.02),
			Vector2(-6.88, -25.10), Vector2(-6.92, -25.35), Vector2(-7.57, -25.44), Vector2(-7.91, -25.34), Vector2(-7.94, -25.29),
			Vector2(-8.04, -25.58), Vector2(-8.23, -25.46), Vector2(-8.69, -25.65), Vector2(-8.58, -25.76), Vector2(-7.85, -26.24),
			Vector2(-7.81, -26.56), Vector2(-7.97, -26.79), Vector2(-8.42, -27.08), Vector2(-9.00, -27.09), Vector2(-9.14, -26.98),
			Vector2(-9.19, -27.23), Vector2(-9.53, -27.30), Vector2(-9.32, -27.43), Vector2(-9.72, -27.67), Vector2(-10.21, -27.41),
			Vector2(-10.40, -27.15), Vector2(-10.44, -26.92), Vector2(-10.78, -26.93), Vector2(-11.20, -26.64), Vector2(-11.34, -26.76),
			Vector2(-11.89, -26.70), Vector2(-11.95, -26.55), Vector2(-12.45, -26.47), Vector2(-12.81, -26.20), Vector2(-13.04, -26.18),
			Vector2(-13.30, -25.78), Vector2(-13.15, -25.53), Vector2(-13.51, -25.47), Vector2(-13.98, -25.49), Vector2(-14.34, -25.37),
			Vector2(-14.32, -24.77), Vector2(-14.22, -24.50), Vector2(-14.46, -24.68), Vector2(-14.88, -24.65), Vector2(-15.22, -24.44),
			Vector2(-15.19, -24.63), Vector2(-15.30, -24.96), Vector2(-15.48, -24.95), Vector2(-15.42, -24.55), Vector2(-15.77, -24.20),
			Vector2(-15.52, -23.77), Vector2(-15.67, -23.28), Vector2(-15.61, -22.98), Vector2(-15.42, -22.94), Vector2(-15.50, -22.65),
			Vector2(-15.40, -22.39), Vector2(-15.56, -22.18), Vector2(-15.61, -21.96), Vector2(-15.81, -21.84), Vector2(-15.87, -21.69),
			Vector2(-16.01, -21.73), Vector2(-15.66, -22.36), Vector2(-15.58, -22.70), Vector2(-15.79, -23.00), Vector2(-15.74, -23.66),
			Vector2(-15.81, -24.03), Vector2(-15.92, -24.18), Vector2(-15.74, -24.58), Vector2(-15.78, -24.91), Vector2(-16.34, -25.06),
			Vector2(-16.50, -24.94), Vector2(-16.64, -24.46), Vector2(-16.99, -23.99), Vector2(-16.89, -23.43), Vector2(-16.96, -23.17),
			Vector2(-16.72, -23.12), Vector2(-16.71, -23.04), Vector2(-16.53, -22.79), Vector2(-16.62, -22.60), Vector2(-17.55, -23.28),
			Vector2(-18.15, -23.44), Vector2(-18.28, -23.23), Vector2(-18.08, -22.95), Vector2(-18.25, -22.70), Vector2(-18.46, -22.97),
			Vector2(-18.77, -22.76), Vector2(-19.13, -22.75), Vector2(-19.27, -22.58), Vector2(-19.42, -22.62), Vector2(-19.23, -22.91),
			Vector2(-19.46, -22.95), Vector2(-20.56, -22.29), Vector2(-20.60, -22.00), Vector2(-20.85, -21.92), Vector2(-20.97, -22.05),
			Vector2(-20.97, -22.26), Vector2(-20.72, -22.32), Vector2(-20.85, -22.65), Vector2(-21.43, -22.82), Vector2(-21.47, -22.78),
			Vector2(-21.32, -22.47), Vector2(-21.41, -22.19), Vector2(-21.25, -21.91), Vector2(-21.34, -21.67), Vector2(-21.48, -21.80),
			Vector2(-21.69, -21.82), Vector2(-22.18, -21.35), Vector2(-22.05, -21.02), Vector2(-22.16, -20.95), Vector2(-22.63, -21.23),
			Vector2(-22.80, -21.01), Vector2(-22.67, -20.80), Vector2(-22.68, -20.68), Vector2(-23.01, -20.87), Vector2(-23.04, -21.54),
			Vector2(-23.32, -21.84), Vector2(-23.25, -21.87), Vector2(-22.39, -21.52), Vector2(-22.06, -21.66), Vector2(-21.82, -21.92),
			Vector2(-21.84, -22.25), Vector2(-21.99, -22.49), Vector2(-22.73, -23.05), Vector2(-23.26, -23.16), Vector2(-23.59, -23.47),
			Vector2(-23.78, -23.31), Vector2(-23.94, -23.55), Vector2(-23.71, -23.67), Vector2(-23.71, -23.71), Vector2(-24.34, -24.10),
			Vector2(-24.70, -24.00), Vector2(-25.07, -24.02), Vector2(-25.36, -23.61), Vector2(-25.67, -23.63), Vector2(-26.10, -23.41),
			Vector2(-26.96, -22.43), Vector2(-27.77, -20.90), Vector2(-28.15, -20.46), Vector2(-28.65, -20.09), Vector2(-28.73, -19.96),
			Vector2(-29.05, -19.97), Vector2(-29.33, -20.06), Vector2(-29.59, -20.03), Vector2(-29.90, -20.34), Vector2(-30.22, -19.78),
			Vector2(-30.44, -19.53), Vector2(-30.67, -20.12), Vector2(-30.97, -20.45), Vector2(-31.25, -20.34), Vector2(-31.52, -20.70),
			Vector2(-31.87, -20.36), Vector2(-32.11, -20.20), Vector2(-32.33, -20.54), Vector2(-32.59, -21.05), Vector2(-32.91, -21.08),
			Vector2(-33.19, -20.96), Vector2(-33.43, -21.13), Vector2(-33.72, -21.46), Vector2(-34.00, -21.29), Vector2(-34.25, -21.65),
			Vector2(-34.56, -21.62), Vector2(-34.56, -29.29), Vector2(26.39, -29.29),
		],
	},
	"southern": {
		"name_key": "region.southern.name",
		"species_key": "region.southern.species",
		"coastal_pop": 0.15,
		"heat_sensitivity": 1.15,
		"anchor": Vector2(1.92, 19.59),
		"polygon": [
			Vector2(-20.48, 13.42), Vector2(-20.12, 13.36), Vector2(-19.80, 13.45), Vector2(-19.45, 13.58), Vector2(-19.09, 13.53),
			Vector2(-18.78, 13.42), Vector2(-18.46, 13.88), Vector2(-17.75, 14.09), Vector2(-17.40, 14.05), Vector2(-16.74, 14.03),
			Vector2(-16.37, 14.36), Vector2(-16.00, 13.77), Vector2(-15.66, 13.72), Vector2(-15.35, 13.22), Vector2(-15.04, 13.55),
			Vector2(-14.68, 13.65), Vector2(-14.32, 13.70), Vector2(-14.00, 13.65), Vector2(-13.64, 13.93), Vector2(-13.31, 13.70),
			Vector2(-12.96, 14.18), Vector2(-12.59, 13.88), Vector2(-12.25, 13.89), Vector2(-11.94, 13.63), Vector2(-11.58, 14.10),
			Vector2(-11.24, 13.63), Vector2(-10.89, 14.02), Vector2(-10.54, 13.51), Vector2(-10.24, 13.53), Vector2(-9.89, 13.74),
			Vector2(-9.51, 13.44), Vector2(-9.17, 13.22), Vector2(-8.51, 13.28), Vector2(-8.18, 13.35), Vector2(-7.50, 13.58),
			Vector2(-7.19, 13.65), Vector2(-6.87, 14.28), Vector2(-6.49, 14.37), Vector2(-6.12, 14.30), Vector2(-5.78, 14.06),
			Vector2(-5.47, 14.16), Vector2(-5.12, 14.23), Vector2(-4.76, 14.19), Vector2(-4.42, 14.11), Vector2(-4.11, 14.21),
			Vector2(-3.44, 14.61), Vector2(-3.08, 14.55), Vector2(-2.42, 14.74), Vector2(-1.74, 14.98), Vector2(-1.05, 15.11),
			Vector2(-0.71, 15.11), Vector2(-0.37, 15.22), Vector2(1.01, 15.32), Vector2(1.37, 15.32), Vector2(1.72, 15.21),
			Vector2(2.03, 15.18), Vector2(2.37, 15.45), Vector2(2.71, 15.44), Vector2(3.06, 15.68), Vector2(3.42, 15.54),
			Vector2(3.78, 15.57), Vector2(4.11, 15.23), Vector2(4.44, 15.26), Vector2(4.78, 15.22), Vector2(5.14, 15.27),
			Vector2(5.81, 14.70), Vector2(6.49, 14.56), Vector2(6.80, 14.30), Vector2(7.16, 14.68), Vector2(7.51, 14.35),
			Vector2(7.87, 14.47), Vector2(8.17, 13.98), Vector2(8.52, 14.33), Vector2(8.86, 14.14), Vector2(9.20, 14.43),
			Vector2(9.55, 14.43), Vector2(9.93, 14.67), Vector2(10.27, 14.45), Vector2(10.59, 14.41), Vector2(10.91, 14.47),
			Vector2(11.27, 14.79), Vector2(11.61, 14.51), Vector2(11.96, 14.93), Vector2(12.34, 14.46), Vector2(12.65, 14.35),
			Vector2(12.98, 14.49), Vector2(13.65, 14.51), Vector2(14.01, 15.08), Vector2(14.37, 14.72), Vector2(14.71, 14.99),
			Vector2(15.05, 14.62), Vector2(15.37, 15.16), Vector2(15.75, 14.98), Vector2(16.41, 14.96), Vector2(16.77, 15.08),
			Vector2(17.14, 14.66), Vector2(17.46, 14.70), Vector2(17.81, 14.63), Vector2(18.13, 14.80), Vector2(18.47, 14.84),
			Vector2(18.84, 15.07), Vector2(19.21, 14.51), Vector2(19.50, 15.07), Vector2(19.86, 14.86), Vector2(20.15, 15.36),
			Vector2(20.52, 15.52), Vector2(20.87, 15.46), Vector2(21.53, 15.78), Vector2(21.88, 15.75), Vector2(22.53, 16.07),
			Vector2(22.86, 16.34), Vector2(23.21, 16.44), Vector2(23.54, 16.61), Vector2(23.88, 16.65), Vector2(24.20, 16.97),
			Vector2(24.54, 17.03), Vector2(24.85, 17.36), Vector2(26.89, 18.41), Vector2(27.21, 18.10), Vector2(27.56, 17.98),
			Vector2(27.84, 17.52), Vector2(28.06, 16.94), Vector2(28.43, 17.11), Vector2(28.77, 16.78), Vector2(29.01, 16.29),
			Vector2(29.38, 16.71), Vector2(29.75, 16.66), Vector2(30.09, 16.51), Vector2(30.37, 16.27), Vector2(30.75, 16.74),
			Vector2(30.82, 16.73), Vector2(31.08, 15.93), Vector2(31.35, 15.43), Vector2(31.64, 15.20), Vector2(31.97, 15.13),
			Vector2(32.27, 14.85), Vector2(32.61, 14.85), Vector2(32.92, 14.74), Vector2(33.31, 14.91), Vector2(33.61, 14.57),
			Vector2(33.97, 14.64), Vector2(34.28, 14.27), Vector2(34.56, 14.11), Vector2(34.56, 26.75), Vector2(34.52, 26.76),
			Vector2(33.79, 26.99), Vector2(33.60, 27.24), Vector2(33.62, 28.06), Vector2(27.94, 28.06), Vector2(27.76, 20.80),
			Vector2(4.79, 28.06), Vector2(2.81, 28.06), Vector2(2.78, 25.36), Vector2(3.13, 24.53), Vector2(3.15, 24.31),
			Vector2(3.00, 24.14), Vector2(2.37, 23.84), Vector2(1.49, 23.79), Vector2(1.28, 23.72), Vector2(1.14, 23.55),
			Vector2(0.93, 23.43), Vector2(0.83, 23.24), Vector2(0.37, 23.12), Vector2(-0.15, 22.70), Vector2(-0.28, 22.89),
			Vector2(-0.47, 22.88), Vector2(-1.58, 22.42), Vector2(-1.69, 22.30), Vector2(-1.65, 22.12), Vector2(-1.81, 21.95),
			Vector2(-2.04, 21.91), Vector2(-3.36, 21.97), Vector2(-3.50, 21.89), Vector2(-3.67, 21.35), Vector2(-3.82, 21.20),
			Vector2(-3.87, 21.22), Vector2(-3.93, 21.62), Vector2(-4.66, 21.72), Vector2(-5.03, 21.87), Vector2(-5.38, 21.78),
			Vector2(-5.73, 21.86), Vector2(-6.10, 21.75), Vector2(-6.29, 21.78), Vector2(-6.57, 22.07), Vector2(-6.75, 22.11),
			Vector2(-6.97, 22.07), Vector2(-7.34, 21.83), Vector2(-7.54, 21.85), Vector2(-7.77, 21.57), Vector2(-7.95, 21.46),
			Vector2(-8.10, 21.57), Vector2(-8.33, 21.58), Vector2(-8.61, 21.85), Vector2(-9.02, 21.97), Vector2(-9.35, 21.96),
			Vector2(-9.72, 21.52), Vector2(-10.03, 21.32), Vector2(-10.62, 22.09), Vector2(-10.81, 22.04), Vector2(-11.36, 22.17),
			Vector2(-11.50, 22.07), Vector2(-11.68, 22.04), Vector2(-11.80, 22.08), Vector2(-12.17, 22.04), Vector2(-12.36, 22.09),
			Vector2(-12.67, 21.98), Vector2(-12.85, 21.62), Vector2(-12.90, 21.62), Vector2(-13.00, 21.95), Vector2(-13.11, 22.06),
			Vector2(-13.31, 22.03), Vector2(-13.68, 22.13), Vector2(-13.88, 22.08), Vector2(-14.04, 22.17), Vector2(-14.25, 22.41),
			Vector2(-14.60, 22.62), Vector2(-14.74, 22.81), Vector2(-14.88, 23.17), Vector2(-15.61, 23.37), Vector2(-15.77, 23.80),
			Vector2(-16.15, 24.49), Vector2(-16.35, 24.57), Vector2(-16.55, 24.52), Vector2(-16.66, 24.39), Vector2(-16.49, 24.01),
			Vector2(-16.45, 23.76), Vector2(-16.68, 23.77), Vector2(-16.70, 23.63), Vector2(-16.37, 23.33), Vector2(-16.34, 22.96),
			Vector2(-16.50, 22.43), Vector2(-16.71, 22.43), Vector2(-17.47, 22.17), Vector2(-17.79, 22.46), Vector2(-17.95, 22.43),
			Vector2(-18.23, 22.18), Vector2(-18.46, 22.12), Vector2(-18.73, 21.86), Vector2(-18.75, 21.66), Vector2(-18.92, 21.51),
			Vector2(-19.48, 21.48), Vector2(-20.01, 21.78), Vector2(-20.06, 21.95), Vector2(-20.18, 22.04), Vector2(-20.37, 22.03),
			Vector2(-20.66, 22.32), Vector2(-20.84, 22.27), Vector2(-22.11, 23.00), Vector2(-22.17, 23.21), Vector2(-22.33, 23.31),
			Vector2(-22.61, 23.02), Vector2(-22.81, 23.06), Vector2(-22.95, 22.95), Vector2(-23.03, 22.78), Vector2(-23.28, 22.69),
			Vector2(-23.50, 23.14), Vector2(-23.64, 23.26), Vector2(-23.83, 23.31), Vector2(-24.18, 23.53), Vector2(-24.57, 23.66),
			Vector2(-25.23, 23.68), Vector2(-25.42, 23.76), Vector2(-25.62, 23.46), Vector2(-26.06, 23.37), Vector2(-26.72, 23.44),
			Vector2(-26.85, 23.59), Vector2(-26.90, 23.44), Vector2(-27.19, 23.41), Vector2(-27.41, 23.56), Vector2(-27.49, 23.75),
			Vector2(-27.66, 23.83), Vector2(-27.91, 23.42), Vector2(-28.12, 23.49), Vector2(-28.28, 23.35), Vector2(-28.42, 23.56),
			Vector2(-29.42, 23.99), Vector2(-29.78, 24.23), Vector2(-29.86, 24.04), Vector2(-30.10, 24.01), Vector2(-30.59, 24.16),
			Vector2(-30.79, 24.13), Vector2(-30.84, 23.95), Vector2(-31.10, 23.88), Vector2(-31.22, 24.12), Vector2(-31.22, 24.28),
			Vector2(-31.39, 24.26), Vector2(-31.49, 24.09), Vector2(-31.75, 24.06), Vector2(-31.91, 24.22), Vector2(-32.15, 24.65),
			Vector2(-32.76, 25.04), Vector2(-32.89, 25.22), Vector2(-32.97, 25.48), Vector2(-32.77, 25.61), Vector2(-32.81, 25.78),
			Vector2(-33.14, 26.12), Vector2(-34.08, 26.66), Vector2(-34.56, 26.75), Vector2(-34.56, 14.10), Vector2(-34.55, 14.10),
			Vector2(-34.22, 13.95), Vector2(-33.88, 13.93), Vector2(-33.58, 13.72), Vector2(-33.24, 14.00), Vector2(-32.90, 13.87),
			Vector2(-32.53, 14.08), Vector2(-32.20, 13.56), Vector2(-31.88, 13.28), Vector2(-31.59, 13.21), Vector2(-31.28, 13.58),
			Vector2(-30.92, 13.71), Vector2(-30.57, 13.64), Vector2(-30.27, 13.66), Vector2(-29.95, 14.01), Vector2(-29.60, 14.17),
			Vector2(-29.23, 14.13), Vector2(-28.87, 13.63), Vector2(-28.55, 13.49), Vector2(-28.25, 13.31), Vector2(-27.96, 13.88),
			Vector2(-27.61, 14.02), Vector2(-27.27, 14.22), Vector2(-26.91, 14.12), Vector2(-26.58, 14.09), Vector2(-26.25, 14.02),
			Vector2(-25.92, 14.10), Vector2(-25.23, 13.98), Vector2(-24.90, 13.90), Vector2(-24.56, 14.00), Vector2(-24.22, 13.96),
			Vector2(-23.86, 14.06), Vector2(-23.51, 13.92), Vector2(-23.17, 13.83), Vector2(-22.84, 13.71), Vector2(-22.49, 13.74),
			Vector2(-22.14, 13.40), Vector2(-21.84, 13.20), Vector2(-21.14, 13.46), Vector2(-20.80, 13.16),
		],
	},
}

## Global ocean currents and major shipping lanes (Gulf Stream, Kuroshio, Antarctic
## Circumpolar Current, Gibraltar, Suez, Panama, Malacca, Cape Agulhas, etc.).
const ROUTES := [
	{"a": "caribbean", "b": "north_atlantic", "kind": "current", "weight": 0.85},
	{"a": "north_atlantic", "b": "arctic", "kind": "current", "weight": 0.75},
	{"a": "north_atlantic", "b": "south_atlantic", "kind": "current", "weight": 0.70},
	{"a": "mediterranean", "b": "north_atlantic", "kind": "shipping", "weight": 0.80},
	{"a": "caribbean", "b": "south_atlantic", "kind": "shipping", "weight": 0.65},
	{"a": "caribbean", "b": "north_pacific", "kind": "shipping", "weight": 0.80},
	{"a": "caribbean", "b": "south_pacific", "kind": "shipping", "weight": 0.75},
	{"a": "north_pacific", "b": "arctic", "kind": "current", "weight": 0.70},
	{"a": "east_asian", "b": "north_pacific", "kind": "current", "weight": 0.90},
	{"a": "coral_triangle", "b": "east_asian", "kind": "shipping", "weight": 0.85},
	{"a": "coral_triangle", "b": "north_pacific", "kind": "current", "weight": 0.75},
	{"a": "coral_triangle", "b": "south_pacific", "kind": "current", "weight": 0.80},
	{"a": "north_pacific", "b": "south_pacific", "kind": "current", "weight": 0.70},
	{"a": "indian", "b": "coral_triangle", "kind": "shipping", "weight": 0.90},
	{"a": "red_arabian", "b": "indian", "kind": "current", "weight": 0.85},
	{"a": "mediterranean", "b": "red_arabian", "kind": "shipping", "weight": 0.90},
	{"a": "south_atlantic", "b": "indian", "kind": "current", "weight": 0.75},
	{"a": "indian", "b": "southern", "kind": "current", "weight": 0.75},
	{"a": "south_pacific", "b": "southern", "kind": "current", "weight": 0.80},
	{"a": "south_atlantic", "b": "southern", "kind": "current", "weight": 0.80},
]

var id: String = ""
var name_key: String = ""
var species_key: String = ""
var polygon: PackedVector2Array = PackedVector2Array()
var anchor: Vector2 = Vector2.ZERO
var coastal_pop: float = 0.0
var heat_sensitivity: float = 1.0

var pollution: float = 0.0
var coral_health: float = 0.0
var seagrass: float = 0.0
var fish_stock: float = 0.0
var awareness: float = 0.0
var protection: float = 0.0


func _init(region_id: String) -> void:
	id = region_id
	var def: Dictionary = DEFS[region_id]
	name_key = def["name_key"]
	species_key = str(def.get("species_key", "region." + region_id + ".species"))
	coastal_pop = float(def["coastal_pop"])
	heat_sensitivity = float(B.REGION_HEAT_SENSITIVITY.get(region_id, def.get("heat_sensitivity", 1.0)))
	anchor = def["anchor"]
	polygon = polygon_of(region_id)
	reset()


func reset() -> void:
	var start: Dictionary = B.REGION_START[id]
	pollution = start["pollution"]
	coral_health = start["coral_health"]
	seagrass = start["seagrass"]
	fish_stock = start["fish_stock"]
	awareness = start["awareness"]
	protection = start["protection"]


func clamp_all() -> void:
	pollution = clampf(pollution, 0.0, 100.0)
	coral_health = clampf(coral_health, 0.0, 100.0)
	seagrass = clampf(seagrass, 0.0, 100.0)
	fish_stock = clampf(fish_stock, 0.0, 100.0)
	awareness = clampf(awareness, 0.0, 100.0)
	protection = clampf(protection, 0.0, 100.0)


func crisis_level() -> float:
	var c: float = pollution * B.CRISIS_W_POLLUTION \
		+ (100.0 - coral_health) * B.CRISIS_W_CORAL \
		+ (100.0 - seagrass) * B.CRISIS_W_SEAGRASS \
		+ (100.0 - fish_stock) * B.CRISIS_W_FISH \
		- protection * 0.18 \
		- awareness * 0.14
	return clampf(c, 0.0, 100.0)


func health() -> float:
	return 100.0 - crisis_level()


func status() -> String:
	var c: float = crisis_level()
	if c >= B.STATUS_COLLAPSED:
		return "collapsed"
	if c >= B.STATUS_CRITICAL:
		return "critical"
	if c >= B.STATUS_STRESSED:
		return "stressed"
	return "healthy"


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name_key": name_key,
		"species_key": species_key,
		"pollution": pollution,
		"coral_health": coral_health,
		"seagrass": seagrass,
		"fish_stock": fish_stock,
		"awareness": awareness,
		"protection": protection,
		"coastal_pop": coastal_pop,
		"heat_sensitivity": heat_sensitivity,
		"crisis": crisis_level(),
		"health": health(),
		"status": status(),
	}


static func polygon_of(region_id: String) -> PackedVector2Array:
	var def: Dictionary = DEFS[region_id]
	var pts: Array = def["polygon"]
	var poly := PackedVector2Array()
	for p in pts:
		poly.append(p)
	return poly


static func anchor_of(region_id: String) -> Vector2:
	var def: Dictionary = DEFS[region_id]
	return def["anchor"]


static func name_key_of(region_id: String) -> String:
	var def: Dictionary = DEFS[region_id]
	return def["name_key"]


static func species_key_of(region_id: String) -> String:
	var def: Dictionary = DEFS[region_id]
	return str(def.get("species_key", "region." + region_id + ".species"))


static func heat_sensitivity_of(region_id: String) -> float:
	var def: Dictionary = DEFS[region_id]
	return float(B.REGION_HEAT_SENSITIVITY.get(region_id, def.get("heat_sensitivity", 1.0)))


static func neighbors_of(region_id: String) -> Array:
	var result: Array = []
	for r in ROUTES:
		var route: Dictionary = r
		var a: String = route["a"]
		var b: String = route["b"]
		if a == region_id:
			result.append({"id": b, "kind": route["kind"], "weight": route["weight"]})
		elif b == region_id:
			result.append({"id": a, "kind": route["kind"], "weight": route["weight"]})
	return result


## Shortest route path (array of region ids including from_id and to_id) via BFS.
static func shortest_path(from_id: String, to_id: String) -> Array:
	if from_id == to_id:
		return [from_id]
	if not DEFS.has(from_id) or not DEFS.has(to_id):
		return []
	var queue: Array = [[from_id]]
	var visited: Dictionary = {from_id: true}
	while not queue.is_empty():
		var path: Array = queue.pop_front()
		var cur: String = str(path[path.size() - 1])
		for nb in neighbors_of(cur):
			var nxt: String = str(nb["id"])
			if nxt == to_id:
				var full: Array = path.duplicate()
				full.append(nxt)
				return full
			if not visited.has(nxt):
				visited[nxt] = true
				var next_path: Array = path.duplicate()
				next_path.append(nxt)
				queue.append(next_path)
	return [from_id, to_id]


static func route_distance(from_id: String, to_id: String) -> int:
	var p: Array = shortest_path(from_id, to_id)
	return maxi(p.size() - 1, 1)


static func region_at(point: Vector2) -> String:
	var wx: float = wrapf(point.x + HALF_W, 0.0, WORLD_W) - HALF_W
	for shift in [0.0, WORLD_W, -WORLD_W]:
		var tp := Vector2(wx + float(shift), point.y)
		for rid in IDS:
			var region_id: String = rid
			if Geometry2D.is_point_in_polygon(tp, polygon_of(region_id)):
				return region_id
	return ""


static func centroid(poly: PackedVector2Array) -> Vector2:
	if poly.is_empty():
		return Vector2.ZERO
	var sum := Vector2.ZERO
	for p in poly:
		sum += p
	return sum / float(poly.size())
