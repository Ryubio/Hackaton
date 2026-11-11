extends Node
## Main: composition root. Renders an immediate Frame-1 Animated Loading Screen on mobile,
## builds the 3D map, bubble FX, HUD, policy tree, event card and menus in async stages,
## routes the game flow (menu -> playing -> pause -> game over) and owns global hotkeys.

const MapBuilder := preload("res://scripts/map_builder.gd")
const UIHud := preload("res://scripts/ui_hud.gd")
const UIMenu := preload("res://scripts/ui_menu.gd")
const UITree := preload("res://scripts/ui_tree.gd")
const UIEventCard := preload("res://scripts/ui_event_card.gd")
const FX := preload("res://scripts/fx.gd")
const UITheme := preload("res://scripts/ui_theme.gd")
const Icons := preload("res://scripts/icons.gd")

## Q / W / E trigger the field operations on the selected region (Balance.ACTION_ORDER).
const ACTION_KEYS := {KEY_Q: 0, KEY_W: 1, KEY_E: 2}

var map: MapBuilder
var fx: FX
var hud: UIHud
var tree_ui: UITree
var event_card: UIEventCard
var menu: UIMenu

# Animated Boot Loading Screen
var _loading_layer: CanvasLayer = null
var _loading_root: Control = null
var _loading_bar: ProgressBar = null
var _loading_status: Label = null
var _loading_pct: Label = null
var _loading_logo: Icons = null
var _boot_done: bool = false


func _ready() -> void:
	get_tree().quit_on_go_back = false
	_build_loading_screen()
	var is_headless: bool = DisplayServer.get_name() == "headless"
	if is_headless:
		_boot_sync()
	else:
		_boot_async()


func _build_loading_screen() -> void:
	_loading_layer = _add_layer("LoadingLayer", 20)
	_loading_root = Control.new()
	_loading_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_loading_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_loading_root.theme = UITheme.build_theme()
	_loading_root.draw.connect(_draw_loading_bg)
	_loading_layer.add_child(_loading_root)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loading_root.add_child(center)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	col.custom_minimum_size = Vector2(560.0, 0.0)
	center.add_child(col)

	_loading_logo = Icons.new()
	_loading_logo.setup("aquastasis_logo", UITheme.HEALTHY, 132.0)
	_loading_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_loading_logo)

	var title := Label.new()
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", UITheme.TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = I18n.t("game.title")
	col.add_child(title)

	var sub := Label.new()
	sub.theme_type_variation = &"HeaderLabel"
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", UITheme.AMBER)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.text = I18n.t("game.emblem_subtitle")
	col.add_child(sub)

	_loading_bar = ProgressBar.new()
	_loading_bar.custom_minimum_size = Vector2(520.0, 22.0)
	_loading_bar.min_value = 0.0
	_loading_bar.max_value = 100.0
	_loading_bar.value = 5.0
	_loading_bar.show_percentage = false
	var pb_bg := UITheme.panel_box(UITheme.LINE, UITheme.with_alpha(UITheme.DEEP, 0.92), 1, Color(0, 0, 0, 0), 0, 8)
	var pb_fill := UITheme.panel_box(UITheme.HEALTHY, UITheme.with_alpha(UITheme.HEALTHY, 0.85), 0, UITheme.with_alpha(UITheme.HEALTHY, 0.35), 8, 8)
	_loading_bar.add_theme_stylebox_override("background", pb_bg)
	_loading_bar.add_theme_stylebox_override("fill", pb_fill)
	col.add_child(_loading_bar)

	var status_row := HBoxContainer.new()
	status_row.add_theme_constant_override("separation", 12)
	col.add_child(status_row)

	_loading_status = Label.new()
	_loading_status.theme_type_variation = &"BodyLabel"
	_loading_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_loading_status.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	_loading_status.text = I18n.t("ui.loading.step1")
	status_row.add_child(_loading_status)

	_loading_pct = Label.new()
	_loading_pct.theme_type_variation = &"ValueLabel"
	_loading_pct.add_theme_color_override("font_color", UITheme.HEALTHY)
	_loading_pct.text = "0%"
	status_row.add_child(_loading_pct)


func _draw_loading_bg() -> void:
	if _loading_root == null:
		return
	var s: Vector2 = _loading_root.size
	var top_c := Color(0.03, 0.09, 0.16, 1.0)
	var bot_c := UITheme.BG
	_loading_root.draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0.0), s, Vector2(0.0, s.y)]),
		PackedColorArray([top_c, top_c, bot_c, bot_c])
	)


func _set_loading_progress(pct: float, status_key: String) -> void:
	if _loading_bar != null:
		_loading_bar.value = pct
	if _loading_pct != null:
		_loading_pct.text = "%d%%" % roundi(pct)
	if _loading_status != null:
		_loading_status.text = I18n.t(status_key)


func _boot_sync() -> void:
	_set_loading_progress(20.0, "ui.loading.step1")
	map = MapBuilder.new()
	map.name = "Map"
	add_child(map)
	_set_loading_progress(50.0, "ui.loading.step2")
	_init_ui_layers()
	_set_loading_progress(100.0, "ui.loading.step4")
	_finish_boot()


func _boot_async() -> void:
	# Frame 1: Loading screen is rendered immediately (0% -> 20%)
	_set_loading_progress(20.0, "ui.loading.step1")
	await get_tree().process_frame

	# Step 2 (50%): Build procedural 3D map base & region meshes across frames
	_set_loading_progress(35.0, "ui.loading.step2")
	map = MapBuilder.new()
	map.name = "Map"
	map.async_build = true
	add_child(map)
	map.build_step_1_base()
	await get_tree().process_frame

	_set_loading_progress(55.0, "ui.loading.step2")
	map.build_step_2_regions()
	await get_tree().process_frame

	_set_loading_progress(70.0, "ui.loading.step2")
	map.build_step_3_finish()
	await get_tree().process_frame

	# Step 3 (85%): Initialize simplified shaders & pooled UI layers
	_set_loading_progress(85.0, "ui.loading.step3")
	_init_ui_layers()
	await get_tree().process_frame

	# Step 4 (100%): Fade out loading screen into Main Menu
	_set_loading_progress(100.0, "ui.loading.step4")
	_finish_boot()


func _init_ui_layers() -> void:
	fx = FX.new()
	fx.name = "FX"
	fx.map = map
	_add_layer("FXLayer", 1).add_child(fx)

	hud = UIHud.new()
	hud.name = "HUD"
	hud.map = map
	_add_layer("HUDLayer", 2).add_child(hud)

	tree_ui = UITree.new()
	tree_ui.name = "PolicyTree"
	_add_layer("TreeLayer", 3).add_child(tree_ui)

	event_card = UIEventCard.new()
	event_card.name = "EventCard"
	_add_layer("EventLayer", 4).add_child(event_card)

	menu = UIMenu.new()
	menu.name = "Menu"
	_add_layer("MenuLayer", 5).add_child(menu)

	menu.start_requested.connect(_start_game)
	menu.continue_requested.connect(_continue_game)
	menu.resume_requested.connect(_resume)
	menu.restart_requested.connect(_start_game)
	menu.main_menu_requested.connect(_to_main_menu)
	menu.quit_requested.connect(_quit)
	EventBus.game_over.connect(_on_game_over)
	EventBus.tree_toggle_requested.connect(_toggle_tree)
	EventBus.event_triggered.connect(_on_event_triggered)
	EventBus.pause_menu_requested.connect(_handle_escape)


func _finish_boot() -> void:
	_boot_done = true
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.has("--autostart"):
		_start_game()
		for arg in args:
			if arg.begins_with("--speed="):
				GameState.set_speed(clampi(arg.trim_prefix("--speed=").to_int(), 0, 3))
			elif arg.begins_with("--select="):
				EventBus.region_selected.emit(arg.trim_prefix("--select="))
			elif arg.begins_with("--event="):
				GameState.debug_force_event(arg.trim_prefix("--event="))
		if args.has("--tree"):
			tree_ui.open()
			for arg in args:
				if arg.begins_with("--tree-branch="):
					tree_ui._switch_branch(arg.trim_prefix("--tree-branch="))
		if args.has("--help-modal"):
			hud._show_manual()
		if args.has("--step5"):
			hud._set_directive_step(5)
		if args.has("--basin"):
			hud._left_panel.visible = true
			hud._left_panel.mouse_filter = Control.MOUSE_FILTER_STOP
			hud._on_hud_resized()
	else:
		_to_main_menu()
		if args.has("--achievements"):
			menu._open_achievements_modal()
		if args.has("--settings"):
			menu._open_settings_modal()

	if _loading_root != null:
		if DisplayServer.get_name() == "headless":
			_loading_layer.visible = false
		else:
			var tw := create_tween()
			tw.tween_property(_loading_root, "modulate:a", 0.0, 0.35)
			tw.tween_callback(func() -> void:
				if is_instance_valid(_loading_layer):
					_loading_layer.queue_free()
					_loading_layer = null
			)


func _add_layer(layer_name: String, index: int) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.name = layer_name
	layer.layer = index
	add_child(layer)
	return layer


func _start_game() -> void:
	_close_modals()
	_clear_selection()
	menu.hide_all()
	map.set_menu_mode(false)
	hud.show_hud()
	GameState.new_game()
	GameState.set_speed(0)


func _continue_game() -> void:
	_close_modals()
	_clear_selection()
	menu.hide_all()
	map.set_menu_mode(false)
	hud.show_hud()
	if GameState.load_saved_game():
		if hud != null:
			hud._dismiss_directives()
		GameState.set_speed(1)
	else:
		GameState.new_game()
		GameState.set_speed(0)


func _to_main_menu() -> void:
	if GameState.running:
		GameState.save_game()
	_close_modals()
	GameState.stop_game()
	_clear_selection()
	hud.hide_hud()
	map.set_menu_mode(true)
	menu.show_main()


## Tree, event card and bubbles never survive a game boundary.
func _close_modals() -> void:
	tree_ui.close()
	event_card.close_now()
	fx.clear_all()


## Drops a region selection left over from the last game (map, HUD and GameState all
## follow region_selected), so menus and the next game start with nothing selected.
func _clear_selection() -> void:
	if GameState.selected_region != "":
		EventBus.region_selected.emit("")


func _open_pause() -> void:
	GameState.set_menu_paused(true)
	menu.show_pause()


func _resume() -> void:
	menu.hide_all()
	GameState.set_menu_paused(false)


func _quit() -> void:
	get_tree().quit()


func _on_game_over(won: bool, reason: String, stats: Dictionary) -> void:
	_close_modals()
	_clear_selection()
	hud.hide_hud()
	map.set_menu_mode(true)
	menu.show_end(won, reason, stats)


func _toggle_tree() -> void:
	if GameState.running and not menu.is_open() and not event_card.is_open():
		tree_ui.toggle()


func _on_event_triggered(_event_id: String) -> void:
	if tree_ui.is_open():
		tree_ui.close()


## True while nothing modal covers the game (menus, event card, policy tree).
func _gameplay_input() -> bool:
	return _boot_done and GameState.running and not menu.is_open() and not event_card.is_open() and not tree_ui.is_open()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _boot_done:
		_handle_escape()


func _handle_escape() -> void:
	if not _boot_done or not GameState.running or event_card.is_open():
		return
	if hud != null and hud.is_manual_open():
		hud.close_manual()
	elif tree_ui.is_open():
		tree_ui.close()
	elif menu.is_pause_open():
		_resume()
	elif not menu.is_open():
		_open_pause()


func _unhandled_input(event: InputEvent) -> void:
	if not _boot_done:
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var code: int = key.keycode if key.keycode != 0 else key.physical_keycode
	match code:
		KEY_ESCAPE:
			_handle_escape()
		KEY_T:
			_toggle_tree()
		KEY_H:
			if _gameplay_input():
				EventBus.tutorial_requested.emit()
		KEY_SPACE:
			if _gameplay_input():
				if hud != null and hud.is_directive_active() and hud.directive_step() == 5:
					GameState.set_speed(1)
					hud.complete_directives()
				else:
					GameState.toggle_pause()
		KEY_1, KEY_KP_1:
			if _gameplay_input():
				GameState.set_speed(1)
				if hud != null and hud.is_directive_active() and hud.directive_step() == 5:
					hud.complete_directives()
		KEY_2, KEY_KP_2:
			if _gameplay_input():
				GameState.set_speed(2)
				if hud != null and hud.is_directive_active() and hud.directive_step() == 5:
					hud.complete_directives()
		KEY_3, KEY_KP_3, KEY_4, KEY_KP_4:
			if _gameplay_input():
				GameState.set_speed(3)
				if hud != null and hud.is_directive_active() and hud.directive_step() == 5:
					hud.complete_directives()
		KEY_Q, KEY_W, KEY_E:
			if _gameplay_input() and GameState.selected_region != "":
				var action_id: String = Balance.ACTION_ORDER[int(ACTION_KEYS[code])]
				GameState.perform_action(action_id, GameState.selected_region)
		_:
			return
	get_viewport().set_input_as_handled()
