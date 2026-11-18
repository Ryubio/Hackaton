extends Node
## Dev tool: runs the real game (main.tscn) and saves single screenshots at given frames,
## instead of --write-movie dumping every frame. main.gd still reads its own user args.
## Run: godot --path . --fixed-fps 30 res://tools/shot.tscn -- --autostart --shot=120:shots/a.png --shot=300:shots/b.png

var _shots: Array = []   # [[frame: int, path: String], ...] sorted by frame
var _frame: int = 0
var _pan_req := Vector3.ZERO
var _pan_done := false
var _select_req := ""
var _page_req := -1
var _tree_req := ""
var _speed_req := -1
var _layer_req := -1
var _fleet_req := ""
var _fleet_target_req := false
var _combo_req := ""
var _summit_req := -1
var _ui_done := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			var spec: String = arg.trim_prefix("--shot=")
			var sep: int = spec.find(":")
			if sep > 0:
				_shots.append([spec.substr(0, sep).to_int(), spec.substr(sep + 1)])
		elif arg.begins_with("--pan="):
			var spec: String = arg.trim_prefix("--pan=")
			var sep: int = spec.find(":")
			if sep > 0:
				_pan_req = Vector3(spec.substr(0, sep).to_float(), 0.0, spec.substr(sep + 1).to_float())
		elif arg.begins_with("--select="):
			_select_req = arg.trim_prefix("--select=")
		elif arg.begins_with("--page="):
			_page_req = arg.trim_prefix("--page=").to_int()
		elif arg.begins_with("--tree="):
			_tree_req = arg.trim_prefix("--tree=")
		elif arg.begins_with("--speed="):
			_speed_req = arg.trim_prefix("--speed=").to_int()
		elif arg.begins_with("--layer="):
			_layer_req = arg.trim_prefix("--layer=").to_int()
		elif arg.begins_with("--fleet="):
			_fleet_req = arg.trim_prefix("--fleet=")
		elif arg == "--fleet-target":
			_fleet_target_req = true
		elif arg.begins_with("--combo="):
			_combo_req = arg.trim_prefix("--combo=")
		elif arg == "--summit":
			_summit_req = 60
		elif arg.begins_with("--summit="):
			_summit_req = arg.trim_prefix("--summit=").to_int()
	_shots.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	add_child(load("res://main.tscn").instantiate())


func _process(_delta: float) -> void:
	_frame += 1
	if not _ui_done and _frame >= 140:
		_ui_done = true
		if _speed_req >= 0:
			GameState.set_speed(_speed_req)
		if _layer_req >= 0:
			EventBus.map_layer_changed.emit(_layer_req)
		if _fleet_req != "":
			GameState.dispatch_fleet(_fleet_req)
		elif _fleet_target_req:
			EventBus.fleet_targeting_changed.emit(true)
		if _select_req != "":
			EventBus.region_selected.emit(_select_req)
		if _combo_req != "":
			var parts: PackedStringArray = _combo_req.split(":")
			var c_reg: String = parts[0]
			var c_cnt: int = int(parts[1]) if parts.size() > 1 else 3
			EventBus.region_selected.emit(c_reg)
			for ci in range(mini(c_cnt, Balance.ACTION_ORDER.size())):
				GameState.perform_action(str(Balance.ACTION_ORDER[ci]), c_reg)
		if _page_req >= 0:
			for n in get_tree().root.find_children("*", "Control", true, false):
				if n.has_method("_set_region_page"):
					n.call("_set_region_page", _page_req)
					break
		if _tree_req != "":
			for n in get_tree().root.find_children("*", "Control", true, false):
				if n.has_method("open") and n.has_method("_switch_branch"):
					n.call("open")
					if _tree_req != "default":
						n.call("_switch_branch", _tree_req)
					break
		if _summit_req >= 0:
			GameState.debug_force_summit(_summit_req)
	if not _pan_done and _pan_req != Vector3.ZERO and _frame >= 150:
		_pan_done = true
		for n in get_tree().root.find_children("*", "Node3D", true, false):
			if "_user_pan" in n:
				if "_has_pan_goal" in n:
					n.set("_has_pan_goal", false)
				if "_did_select_pan" in n:
					n.set("_did_select_pan", false)
				n.set("_user_pan", _pan_req)
				break
	while not _shots.is_empty() and _frame >= int(_shots[0][0]):
		var shot: Array = _shots.pop_front()
		var p_str: String = str(shot[1])
		var path: String = p_str if p_str.begins_with("/") else ProjectSettings.globalize_path("res://" + p_str)
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var img: Image = get_viewport().get_texture().get_image()
		img.save_png(path)
		print("SHOT ", _frame, " -> ", path)
	if _shots.is_empty():
		get_tree().quit()
