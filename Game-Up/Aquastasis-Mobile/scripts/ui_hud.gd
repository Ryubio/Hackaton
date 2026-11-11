extends Control
## UIHud: in-game HUD built in code - news ticker strip, top bar (year, timeline, speed,
## resources with net income per year), BASIN STATUS panel (bars, temperature gauge, live
## trend chart, crisis resistances, evolution pressure), REGION panel (status, six stats,
## FIELD OPERATIONS with Q/W/E hints, POLICY TREE button), toast feed and a themed hover tip.
## Driven only by EventBus.

const UITheme := preload("res://scripts/ui_theme.gd")
const Icons := preload("res://scripts/icons.gd")
const Charts := preload("res://scripts/charts.gd")
const NewsTicker := preload("res://scripts/news_ticker.gd")
const TechTree := preload("res://scripts/tech_tree.gd")

const TICKER_H := 38.0
const TOP_H := 66.0
const MARGIN := 12.0
const LEFT_W := 346.0
const RIGHT_W := 660.0
const PANEL_Y := 76.0
const TOAST_W := 340.0
const TOAST_AREA_H := 200.0
const MAX_TOASTS := 3
const TOAST_LIFE := 6.0

const RES_BLOCK_W := 116.0
const RES_ORDER := ["budget", "political", "science"]
const RES_KEYS := {"budget": "hud.budget", "political": "hud.political", "science": "hud.science"}
## Snapshot keys of the net income per tick (before spending) of each resource.
const RATE_KEYS := {"budget": "budget_rate", "political": "political_rate", "science": "science_rate"}
## Field operation hotkeys in Balance.ACTION_ORDER order (main.gd maps Q / W / E the same way).
const ACTION_HOTKEYS := ["Q", "W", "E"]
const HISTORY_EVERY := 10           # local chart samples if GameState.get_history() is empty
const NEG_INCOME_WARN_TICKS := 5    # budget income negative this long -> warning toast
const NEG_INCOME_REARM_TICKS := 60  # ... and positive this long before it may warn again
const MAX_RESIST_COUNTERS := 2
const MAX_RESIST_ROWS := 3
const RES_COLORS := {
	"budget": Color(0.9098, 0.6392, 0.2392),
	"political": Color(0.95, 0.50, 0.36),
	"science": Color(0.42, 0.78, 1.0),
}
const AWARE_COLOR := Color(0.42, 0.78, 1.0)
const SPEED_ICONS := ["pause", "play", "fast", "faster"]
const SPEED_TEXT := ["", "1x", "2x", "4x"]
const SPEED_KEYS := ["hud.speed.pause", "hud.speed.x1", "hud.speed.x2", "hud.speed.x4"]
## Region stat rows: [data key, i18n key, icon, bar mode] (decluttered to core ecosystem vitals)
const STAT_ROWS := [
	["coral_health", "hud.region.coral", "coral", "health"],
	["seagrass", "hud.region.seagrass", "seagrass", "health"],
	["fish_stock", "hud.region.fish", "fish", "health"],
	["protection", "hud.region.protection", "protection", "protect"],
	["awareness", "hud.region.awareness", "awareness", "aware"],
]

var _tr_labels: Array = []          # [[Label, key], ...] re-rendered on language_changed
var _snap: Dictionary = {}
var _selected: String = ""
var _region: Dictionary = {}
var _region_status: String = ""
var _is_shown: bool = false
var _anim: Tween = null
var _time: float = 0.0

# Layout roots
var _ticker_strip: Control
var _top_bar: PanelContainer
var _left_panel: PanelContainer
var _right_panel: PanelContainer
var _toast_box: VBoxContainer
var _tip_panel: PanelContainer
var _tip_title: Label
var _tip_body: RichTextLabel
var _tip_meta: Label
var _tip_owner: Control = null
var _tip_tween: Tween = null
var _tip_side: String = "left"

# Top bar
var _pulse: Charts
var _year_label: Label
var _years_left_label: Label
var _tick_bar: ProgressBar
var _tick_bar_fill: StyleBoxFlat
var _timeline: Charts
var _speed_buttons: Array = []
var _speed_icons: Array = []
var _speed_labels: Array = []
var _paused_chip: PanelContainer
var _chip_on: bool = false          # chip keeps its layout slot; only its alpha changes
var _res_labels: Dictionary = {}    # key -> value Label
var _res_shown: Dictionary = {}
var _res_target: Dictionary = {}

# Basin panel
var _sea_bar: Charts
var _crisis_bar: Charts
var _aware_bar: Charts
var _gauge: Charts
var _live_dot: Icons
var _left_body: VBoxContainer
var _left_toggle_btn: Button
var _left_collapsed: bool = false

# Region panel
var _right_bracket_color: Color = UITheme.TEXT_DIM
var _hint_box: HBoxContainer
var _hint_icon: Icons
var _details: VBoxContainer
var _region_name: Label
var _region_species_badge: PanelContainer
var _region_species_icon: Icons
var _region_species_label: Label
var _region_trait_box: PanelContainer
var _region_trait_label: Label
var _region_trend_badge: PanelContainer
var _region_trend_icon: Icons
var _region_trend_label: Label
var _badge: PanelContainer
var _badge_label: Label
var _region_crisis_bar: Charts
var _stat_bars: Dictionary = {}     # data key -> Charts
var _coastal_value: Label
var _action_rows: Array = []        # Dictionary per action

# Toasts: Dictionary {root, label, key, args}
var _toasts: Array = []
var _toast_avail: float = TOAST_AREA_H   # height of the toast feed area

# Phase 2: news ticker, net income, live chart, resistances, evolution pressure, policy tree
var _ticker: NewsTicker
var _res_icons: Dictionary = {}     # key -> Icons
var _rate_labels: Dictionary = {}   # key -> Label ("+75/yr")
var _rate_values: Dictionary = {}   # key -> net income per year (float), missing = unknown
var _budget_negative: bool = false
var _neg_ticks: int = 0
var _pos_ticks: int = 0
var _neg_warned: bool = false
var _chart: Charts
var _local_hist: Array = []         # [[tick, sea_health, crisis], ...] fallback samples
var _resist_icon: Icons
var _resist_title: Label
var _resist_badge: PanelContainer
var _resist_count: Label
var _resist_list: VBoxContainer
var _resist_none: Label
var _resist_more: Label             # "Also active: N" past MAX_RESIST_ROWS
var _resist_ids: Array = []         # evolution ids currently listed
var _resist_flash: float = 0.0
var _pressure_box: PanelContainer
var _pressure_icon: Icons
var _pressure_label: Label
var _pressure_bar: Charts
var _pressure_branch: String = ""
var _tree_btn: Button
var _tree_icon: Icons
var _tree_status: Label
var _tree_open: bool = false
var _adoptable: int = 0

# Visual Juice & Screen Vignette
var _vignette: Control
var _vignette_alpha: float = 0.0
var _vignette_color: Color = UITheme.CRISIS
var _vignette_tween: Tween = null
var _floating_layer: Control

# 3D Map injection for dynamic region targeting
var map: Node = null

# Interactive Mission Directives HUD (unobtrusive, hands-on guided tutorial)
var _directive_box: PanelContainer
var _directive_step_label: Label
var _directive_body_label: RichTextLabel
var _directive_pips: Array = []
var _directive_action_btn: Button
var _directive_skip_btn: Button
var _directive_step: int = 1
var _directive_active: bool = false
var _directive_pulse_time: float = 0.0
var _directive_overlay: Control

# Tactical Field Manual & 3-Step Visual Mobile Tutorial
var _help_modal: Control
var _help_backdrop: Control
var _tut_slide: int = 0
var _tut_title_l: Label
var _tut_body_l: Label
var _tut_canvas: Control
var _tut_pips: Array = []
var _tut_prev_btn: Button
var _tut_next_btn: Button
var _tut_start_btn: Button

# Flagship Biodiversity & Barometer (Top bar)
var _bio_chip: PanelContainer
var _turtle_count: Label
var _seal_count: Label
var _defcon_badge: PanelContainer
var _defcon_label: Label
var _defcon_level: int = 5
var _antalya_hq_chip: PanelContainer
var _antalya_hq_label: Label
var _diff_badge: PanelContainer
var _diff_badge_label: Label
var _audio_btn: Button
var _audio_icon: Icons
var _help_btn: Button
var _help_icon: Icons
var _pause_menu_btn: Button
var _pause_menu_icon: Icons

# COP31 Summit Modal
var _summit_modal: Control
var _summit_badge_panel: PanelContainer
var _summit_badge_label: Label
var _summit_title_label: Label
var _summit_desc_text: RichTextLabel
var _summit_opt_a_title: Label
var _summit_opt_a_desc: Label
var _summit_opt_a_btn: Button
var _summit_opt_b_title: Label
var _summit_opt_b_desc: Label
var _summit_opt_b_btn: Button
var _current_summit_data: Dictionary = {}

# Mobile Long-Press Tooltip Support & 3-Zone Mobile HUD Controls
var _hold_ctrl: Control = null
var _hold_time: float = 0.0
var _hold_cb: Callable = Callable()
var _hold_triggered: bool = false
var _sea_temp_pill: PanelContainer = null
var _sea_pill_label: Label = null
var _temp_pill_label: Label = null
var _bottom_right_bar: HBoxContainer = null
var _region_close_btn: Button = null
var _region_hc_label: Label = null



func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = UITheme.build_theme()
	_build_vignette()
	_build_floating_layer()
	_build_ticker_strip()
	_build_top_bar()
	_build_left_panel()
	_build_right_panel()
	_build_toasts()
	_build_directives()
	_build_manual_modal()
	_build_summit_modal()
	_build_tip()
	resized.connect(_on_hud_resized)
	visible = false

	EventBus.game_started.connect(_on_game_started)
	EventBus.tick_done.connect(_on_tick_done)
	EventBus.region_changed.connect(_on_region_changed)
	EventBus.resources_changed.connect(_on_resources_changed)
	EventBus.region_selected.connect(_on_region_selected)
	EventBus.speed_changed.connect(_on_speed_changed)
	EventBus.paused_changed.connect(_on_paused_changed)
	EventBus.toast.connect(_on_toast)
	EventBus.action_performed.connect(_on_action_performed)
	EventBus.language_changed.connect(_on_language_changed)
	EventBus.evolution_happened.connect(_on_evolution_happened)
	EventBus.evolution_cured.connect(_on_evolution_cured)
	EventBus.node_adopted.connect(_on_node_adopted)
	EventBus.tree_toggled.connect(_on_tree_toggled)
	EventBus.spread_happened.connect(_on_spread_happened)
	EventBus.bubble_collected.connect(_on_bubble_collected)
	EventBus.summit_triggered.connect(_on_summit_triggered)
	EventBus.tutorial_requested.connect(_show_manual)

	_select_region(GameState.selected_region)
	_on_speed_changed(GameState.speed_index)
	_refresh_resistances(false)
	_update_tree_status()


# --- Small builders ------------------------------------------------------------------

func _label(variation: String, key: String = "") -> Label:
	var l := Label.new()
	l.theme_type_variation = StringName(variation)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if key != "":
		_tr(l, key)
	return l


func _tr(l: Label, key: String) -> void:
	_tr_labels.append([l, key])
	l.text = I18n.t(key)


func _icon(id: String, col: Color, px: float) -> Icons:
	var ic: Icons = Icons.new()
	ic.setup(id, col, px)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return ic


func _spacer() -> Control:
	var s := Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


func _hbox(sep: int = 8) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_constant_override("separation", sep)
	return b


func _vbox(sep: int = 6) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_constant_override("separation", sep)
	return b


func _vline(h: float) -> ColorRect:
	var r := ColorRect.new()
	r.color = UITheme.LINE
	r.custom_minimum_size = Vector2(1.0, h)
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _panel(variation: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = StringName(variation)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	return p


func _sep() -> HSeparator:
	var s := HSeparator.new()
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## Trims overlong single-line text with an ellipsis. No clip_text: clipping to the line box
## cuts the marks above capitals (Turkish İ/Ö/Ü/Ğ, Russian Ё), which changes the letter.
func _ellipsis(l: Label) -> void:
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _wire_button(btn: BaseButton) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_entered.connect(_on_btn_hover.bind(btn, true))
	btn.mouse_exited.connect(_on_btn_hover.bind(btn, false))
	btn.button_down.connect(_on_btn_down.bind(btn))


func _on_btn_hover(btn: BaseButton, on: bool) -> void:
	UITheme.hover_fx(btn, on)


func _on_btn_down(btn: BaseButton) -> void:
	if not btn.disabled:
		UITheme.press_fx(btn)


# --- Ticker strip (compact bottom-left news headline bar) ---------------------------------

func _build_ticker_strip() -> void:
	_ticker_strip = Control.new()
	_ticker_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ticker_strip.position = Vector2(MARGIN, 720.0 - MARGIN - TICKER_H)
	_ticker_strip.size = Vector2(440.0, TICKER_H)
	_ticker_strip.clip_contents = true
	_ticker_strip.draw.connect(_draw_ticker_strip)
	add_child(_ticker_strip)
	_ticker = NewsTicker.new()
	_ticker.name = "NewsTicker"
	_ticker_strip.add_child(_ticker)


func _draw_ticker_strip() -> void:
	var w: float = _ticker_strip.size.x
	var h: float = _ticker_strip.size.y
	var sb := UITheme.panel_box(UITheme.LINE_AMBER, UITheme.with_alpha(UITheme.DEEP, 0.92), 1, Color(0, 0, 0, 0), 0, 8)
	_ticker_strip.draw_style_box(sb, Rect2(0.0, 0.0, w, h))


# --- Top bar (Slim & High-Contrast Mobile 4-Pill Top Bar) --------------------------------

func _build_top_bar() -> void:
	_top_bar = _panel("TopBar")
	_top_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_top_bar.offset_top = 0.0
	_top_bar.offset_bottom = TOP_H
	add_child(_top_bar)
	var row := _hbox(6)
	_top_bar.add_child(row)

	# Hidden compatibility nodes (updated by _on_tick_done)
	_pulse = Charts.new()
	_pulse.setup_pulse(Vector2(44.0, 28.0))
	_pulse.visible = false
	row.add_child(_pulse)
	_timeline = Charts.new()
	_timeline.setup_timeline(28.0)
	_timeline.visible = false
	row.add_child(_timeline)

	# Pills 1, 2, 3: 💰 Budget (+income), 🏛️ Support, 🔬 Science
	for k in RES_ORDER:
		var key: String = k
		var col: Color = RES_COLORS[key]
		var pill := PanelContainer.new()
		pill.theme_type_variation = &"BadgePanel"
		var psb := UITheme.panel_box(UITheme.with_alpha(col, 0.55), UITheme.with_alpha(UITheme.DEEP, 0.90), 1, Color(0, 0, 0, 0), 0, 8)
		psb.content_margin_left = 10.0
		psb.content_margin_right = 10.0
		psb.content_margin_top = 4.0
		psb.content_margin_bottom = 4.0
		pill.add_theme_stylebox_override("panel", psb)
		pill.custom_minimum_size = Vector2(RES_BLOCK_W, 52.0)
		pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pill.mouse_filter = Control.MOUSE_FILTER_STOP
		pill.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pill.mouse_entered.connect(_on_res_hover.bind(pill, key))
		pill.mouse_exited.connect(_hide_tip.bind(pill))
		pill.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_on_res_hover(pill, key)
		)
		row.add_child(pill)

		var block := _hbox(6)
		pill.add_child(block)
		var res_icon := _icon(key, col, 24.0)
		block.add_child(res_icon)
		_res_icons[key] = res_icon
		var col_box := _vbox(0)
		col_box.alignment = BoxContainer.ALIGNMENT_CENTER
		col_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		block.add_child(col_box)
		var val_row := _hbox(4)
		col_box.add_child(val_row)
		var v := _label("ValueLabel")
		v.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.25))
		v.add_theme_font_size_override("font_size", 22)
		v.text = "0"
		val_row.add_child(v)
		var rate := _label("SmallLabel")
		rate.add_theme_font_override("font", UITheme.mono_bold_font())
		rate.add_theme_font_size_override("font_size", 15)
		rate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rate.visible = false
		val_row.add_child(rate)
		_rate_labels[key] = rate
		var n := _label("DimLabel", RES_KEYS[key])
		n.add_theme_font_size_override("font_size", 14)
		_ellipsis(n)
		col_box.add_child(n)
		_res_labels[key] = v
		_res_shown[key] = 0.0
		_res_target[key] = 0.0

	# Pill 4: 🌡️ Sea Health % & Temp (°C) (tap to toggle Basin Status drawer!)
	_sea_temp_pill = PanelContainer.new()
	_sea_temp_pill.theme_type_variation = &"BadgePanel"
	var st_sb := UITheme.panel_box(UITheme.with_alpha(UITheme.HEALTHY, 0.65), UITheme.with_alpha(UITheme.DEEP, 0.92), 1, Color(0, 0, 0, 0), 0, 8)
	st_sb.content_margin_left = 12.0
	st_sb.content_margin_right = 12.0
	st_sb.content_margin_top = 4.0
	st_sb.content_margin_bottom = 4.0
	_sea_temp_pill.add_theme_stylebox_override("panel", st_sb)
	_sea_temp_pill.custom_minimum_size = Vector2(188.0, 52.0)
	_sea_temp_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sea_temp_pill.mouse_filter = Control.MOUSE_FILTER_STOP
	_sea_temp_pill.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_sea_temp_pill.gui_input.connect(_on_sea_temp_pill_input)
	row.add_child(_sea_temp_pill)
	var st_row := _hbox(8)
	st_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_sea_temp_pill.add_child(st_row)
	st_row.add_child(_icon("sea_health", UITheme.HEALTHY, 22.0))
	_sea_pill_label = _label("ValueLabel")
	_sea_pill_label.add_theme_font_size_override("font_size", 22)
	_sea_pill_label.add_theme_color_override("font_color", UITheme.HEALTHY)
	_sea_pill_label.text = "62%"
	st_row.add_child(_sea_pill_label)
	st_row.add_child(_vline(22.0))
	st_row.add_child(_icon("temperature", UITheme.WARNING, 20.0))
	_temp_pill_label = _label("ValueLabel")
	_temp_pill_label.add_theme_font_size_override("font_size", 20)
	_temp_pill_label.add_theme_color_override("font_color", UITheme.WARNING)
	_temp_pill_label.text = "+1.50°C"
	st_row.add_child(_temp_pill_label)

	row.add_child(_spacer())

	# Year/Month block
	var year_box := _vbox(2)
	year_box.custom_minimum_size = Vector2(108.0, 0.0)
	year_box.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(year_box)
	_year_label = _label("BigValueLabel")
	_year_label.add_theme_font_size_override("font_size", 20)
	_ellipsis(_year_label)
	year_box.add_child(_year_label)
	_tick_bar = ProgressBar.new()
	_tick_bar.custom_minimum_size = Vector2(100.0, 5.0)
	_tick_bar.min_value = 0.0
	_tick_bar.max_value = 1.0
	_tick_bar.step = 0.0
	_tick_bar.value = 0.0
	_tick_bar.show_percentage = false
	_tick_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tb_bg: StyleBoxFlat = UITheme.panel_box(UITheme.LINE_DIM, UITheme.with_alpha(UITheme.DEEP, 0.9), 1, Color(0, 0, 0, 0), 0, 2)
	tb_bg.content_margin_left = 0.0
	tb_bg.content_margin_right = 0.0
	tb_bg.content_margin_top = 0.0
	tb_bg.content_margin_bottom = 0.0
	_tick_bar_fill = UITheme.panel_box(UITheme.HEALTHY, UITheme.with_alpha(UITheme.HEALTHY, 0.85), 0, UITheme.with_alpha(UITheme.HEALTHY, 0.35), 4, 2)
	_tick_bar_fill.content_margin_left = 0.0
	_tick_bar_fill.content_margin_right = 0.0
	_tick_bar_fill.content_margin_top = 0.0
	_tick_bar_fill.content_margin_bottom = 0.0
	_tick_bar.add_theme_stylebox_override("background", tb_bg)
	_tick_bar.add_theme_stylebox_override("fill", _tick_bar_fill)
	year_box.add_child(_tick_bar)
	_years_left_label = _label("DimLabel")
	_years_left_label.add_theme_font_size_override("font_size", 14)
	_ellipsis(_years_left_label)
	year_box.add_child(_years_left_label)

	# Speed controls (56x56 px touch hitboxes!)
	var speed_row := _hbox(6)
	row.add_child(speed_row)
	for i in 4:
		var btn := Button.new()
		btn.theme_type_variation = &"SpeedButton"
		btn.toggle_mode = true
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.custom_minimum_size = Vector2(50.0, 52.0)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_wire_button(btn)
		btn.mouse_entered.connect(_on_speed_hover.bind(btn, i))
		btn.mouse_exited.connect(_hide_tip.bind(btn))
		btn.pressed.connect(_on_speed_pressed.bind(i))
		var inner := _hbox(3)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		btn.add_child(inner)
		var px: float = 20.0 if i == 0 else 16.0
		var ic: Icons = _icon(SPEED_ICONS[i], UITheme.TEXT, px)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(ic)
		_speed_icons.append(ic)
		var txt: String = SPEED_TEXT[i]
		var spd_label: Label = null
		if txt != "":
			var l := _label("SmallLabel")
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			l.text = txt
			l.add_theme_font_override("font", UITheme.mono_bold_font())
			l.add_theme_font_size_override("font_size", 18)
			l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			inner.add_child(l)
			spd_label = l
		_speed_labels.append(spd_label)
		speed_row.add_child(btn)
		_speed_buttons.append(btn)
	_paused_chip = PanelContainer.new()
	_paused_chip.visible = false
	speed_row.add_child(_paused_chip)

	# Hidden secondary badges (kept in tree so existing update functions stay valid)
	_bio_chip = PanelContainer.new()
	_bio_chip.visible = false
	_turtle_count = _label("SmallLabel")
	_seal_count = _label("SmallLabel")
	_bio_chip.add_child(_turtle_count)
	_bio_chip.add_child(_seal_count)
	row.add_child(_bio_chip)

	_defcon_badge = PanelContainer.new()
	_defcon_badge.visible = false
	_defcon_label = _label("BadgeLabel")
	_defcon_badge.add_child(_defcon_label)
	row.add_child(_defcon_badge)

	_antalya_hq_chip = PanelContainer.new()
	_antalya_hq_chip.visible = false
	_antalya_hq_label = _label("BadgeLabel")
	_antalya_hq_chip.add_child(_antalya_hq_label)
	row.add_child(_antalya_hq_chip)

	_diff_badge = PanelContainer.new()
	_diff_badge.visible = false
	_diff_badge_label = _label("BadgeLabel")
	_diff_badge.add_child(_diff_badge_label)
	row.add_child(_diff_badge)

	_audio_btn = Button.new()
	_audio_btn.visible = false
	_audio_icon = _icon("sound_on", UITheme.TEXT, 20.0)
	_audio_btn.add_child(_audio_icon)
	row.add_child(_audio_btn)

	# Dedicated Mobile "☰ MENÜ" Button (106x52 px)
	_pause_menu_btn = Button.new()
	_pause_menu_btn.theme_type_variation = &"ActionButton"
	_pause_menu_btn.custom_minimum_size = Vector2(106.0, 52.0)
	_pause_menu_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pause_menu_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_menu_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var menu_lbl := _label("HeaderLabel", "hud.btn.menu")
	menu_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu_lbl.add_theme_font_size_override("font_size", 20)
	menu_lbl.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.25))
	_pause_menu_btn.add_child(menu_lbl)
	_pause_menu_btn.pressed.connect(_on_pause_menu_pressed)
	row.add_child(_pause_menu_btn)


func _on_sea_temp_pill_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	AudioSynth.play_click()
	GameState.vibrate_light()
	if _left_panel != null:
		var will_open: bool = not _left_panel.visible
		if will_open and _selected != "":
			EventBus.region_selected.emit("")
		_left_panel.visible = will_open
		_left_panel.mouse_filter = Control.MOUSE_FILTER_STOP if _left_panel.visible else Control.MOUSE_FILTER_IGNORE
		_on_hud_resized()


# --- Basin status (left) ----------------------------------------------------------------

func _build_left_panel() -> void:
	_left_panel = _panel("HudPanel")
	_left_panel.position = Vector2(MARGIN, PANEL_Y)
	_left_panel.custom_minimum_size = Vector2(LEFT_W, 0.0)
	_left_panel.size = Vector2(LEFT_W, 0.0)
	_left_panel.z_index = 26
	_left_panel.visible = false
	_left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_panel.draw.connect(_on_left_panel_draw)
	add_child(_left_panel)
	var root_col := _vbox(8)
	_left_panel.add_child(root_col)

	var head := _hbox(8)
	root_col.add_child(head)
	head.add_child(_icon("sea_health", UITheme.AMBER, 20.0))
	var title := _label("HeaderLabel", "hud.global_title")
	_ellipsis(title)
	head.add_child(title)
	_live_dot = _icon("target", UITheme.HEALTHY, 12.0)
	head.add_child(_live_dot)
	_left_toggle_btn = Button.new()
	_left_toggle_btn.theme_type_variation = &"SpeedButton"
	_left_toggle_btn.custom_minimum_size = Vector2(56.0, 56.0)
	_left_toggle_btn.text = "✕"
	_left_toggle_btn.add_theme_font_size_override("font_size", 22)
	_left_toggle_btn.pressed.connect(_on_toggle_left_panel)
	head.add_child(_left_toggle_btn)

	# Basin drawer is opened from the Sea Health pill; it scrolls with one finger.
	var left_scroll := ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(LEFT_W - 28.0, 470.0)
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_scroll.follow_focus = true
	left_scroll.gui_input.connect(_on_scroll_touch_drag.bind(left_scroll))
	root_col.add_child(left_scroll)
	_left_body = _vbox(8)
	_left_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_body.mouse_filter = Control.MOUSE_FILTER_PASS
	_left_body.gui_input.connect(_on_scroll_touch_drag.bind(left_scroll))
	left_scroll.add_child(_left_body)
	var col := _left_body
	col.add_child(_sep())

	_sea_bar = _stat_block(col, "sea_health", "hud.sea_health", "health", UITheme.HEALTHY, 12.0)
	_sea_bar.markers = [60.0]
	_crisis_bar = _stat_block(col, "crisis", "hud.crisis", "inverse", UITheme.CRISIS, 12.0)
	_aware_bar = _stat_block(col, "awareness", "hud.awareness", "fixed", AWARE_COLOR, 12.0)
	col.add_child(_sep())

	var th := _hbox(8)
	col.add_child(th)
	th.add_child(_icon("temperature", UITheme.WARNING, 16.0))
	var tl := _label("SmallLabel", "hud.temperature")
	_ellipsis(tl)
	th.add_child(tl)
	var inset := _panel("InsetPanel")
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(inset)
	_gauge = Charts.new()
	_gauge.setup_gauge(Vector2(260.0, 105.0))
	inset.add_child(_gauge)
	_gauge.set_value(1.5, true)

	var limits_box := _hbox(6)
	col.add_child(limits_box)
	limits_box.add_child(_icon("warning", UITheme.CRISIS, 13.0))
	var ll := _label("DimLabel", "hud.temp_limit")
	ll.add_theme_color_override("font_color", UITheme.with_alpha(UITheme.CRISIS, 0.85))
	_ellipsis(ll)
	limits_box.add_child(ll)

	limits_box.add_child(_vline(12.0))

	limits_box.add_child(_icon("target", UITheme.AMBER, 13.0))
	var gl := _label("DimLabel", "hud.goal")
	gl.add_theme_color_override("font_color", UITheme.AMBER.lerp(UITheme.TEXT, 0.25))
	_ellipsis(gl)
	limits_box.add_child(gl)
	col.add_child(_sep())
	_build_chart_section(col)
	col.add_child(_sep())
	_build_resist_section(col)


## LIVE TREND: legend (wraps for long languages) and the Sea Health vs Crisis line chart.
func _build_chart_section(col: VBoxContainer) -> void:
	var head := _hbox(8)
	col.add_child(head)
	head.add_child(_icon("clock", UITheme.AMBER, 16.0))
	var title := _label("HeaderLabel", "hud.chart.title")
	_ellipsis(title)
	head.add_child(title)
	var legend := HFlowContainer.new()
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legend.add_theme_constant_override("h_separation", 14)
	legend.add_theme_constant_override("v_separation", 2)
	col.add_child(legend)
	_legend_item(legend, UITheme.HEALTHY, false, "hud.chart.health")
	_legend_item(legend, UITheme.CRISIS, false, "hud.chart.crisis")
	_legend_item(legend, UITheme.AMBER, true, "hud.chart.goal")
	var inset := _panel("InsetPanel")
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.add_theme_stylebox_override("panel", _inset_box(6.0, 6.0))
	col.add_child(inset)
	_chart = Charts.new()
	_chart.setup_line(Vector2(260.0, 104.0))
	_chart.total_ticks = Balance.TOTAL_TICKS
	_chart.start_year = Balance.START_YEAR
	_chart.end_year = Balance.END_YEAR
	_chart.goal_value = Balance.WIN_SEA_HEALTH
	inset.add_child(_chart)


func _inset_box(h: float, v: float) -> StyleBoxFlat:
	var sb := UITheme.panel_box(UITheme.LINE_DIM, UITheme.with_alpha(UITheme.DEEP, 0.75), 1, Color(0, 0, 0, 0), 0, 6)
	sb.content_margin_left = h
	sb.content_margin_right = h
	sb.content_margin_top = v
	sb.content_margin_bottom = v
	return sb


func _legend_item(parent: Control, col: Color, dashed: bool, key: String) -> void:
	var item := _hbox(5)
	parent.add_child(item)
	var sw := Control.new()
	sw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sw.custom_minimum_size = Vector2(16.0, 10.0)
	sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sw.draw.connect(_draw_swatch.bind(sw, col, dashed))
	item.add_child(sw)
	var l := _label("DimLabel", key)
	l.add_theme_font_size_override("font_size", 11)
	item.add_child(l)


func _draw_swatch(sw: Control, col: Color, dashed: bool) -> void:
	var y: float = roundf(sw.size.y * 0.5)
	if dashed:
		UITheme.dashed_line(sw, Vector2(0.0, y), Vector2(sw.size.x, y), col, 1.5, 4.0, 3.0)
		return
	sw.draw_line(Vector2(0.0, y), Vector2(sw.size.x, y), UITheme.with_alpha(col, 0.25), 5.0, true)
	sw.draw_line(Vector2(0.0, y), Vector2(sw.size.x, y), col, 2.0, true)


## CRISIS RESISTANCES: active evolutions with their counter policies, plus the pressure
## warning that appears before a one-sided strategy provokes a new one.
func _build_resist_section(col: VBoxContainer) -> void:
	var head := _hbox(8)
	col.add_child(head)
	_resist_icon = _icon(_icon_or("evolution", "crisis"), UITheme.TERRACOTTA.lerp(UITheme.CRISIS, 0.4), 16.0)
	head.add_child(_resist_icon)
	_resist_title = _label("HeaderLabel", "hud.resist.title")
	_ellipsis(_resist_title)
	head.add_child(_resist_title)
	_resist_badge = PanelContainer.new()
	_resist_badge.theme_type_variation = &"BadgePanel"
	_resist_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resist_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_resist_count = _label("BadgeLabel")
	_resist_count.text = "0"
	_resist_badge.add_child(_resist_count)
	head.add_child(_resist_badge)

	_resist_list = _vbox(6)
	col.add_child(_resist_list)
	_resist_none = _label("DimLabel", "hud.resist.none")
	_resist_none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resist_none.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resist_none.custom_minimum_size = Vector2(220.0, 0.0)
	_resist_list.add_child(_resist_none)

	_resist_more = _label("DimLabel")
	_resist_more.visible = false
	_resist_list.add_child(_resist_more)

	_pressure_box = PanelContainer.new()
	_pressure_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_pressure_box.add_theme_stylebox_override("panel", UITheme.stripe_box(UITheme.WARNING, 0.75))
	_pressure_box.visible = false
	_pressure_box.mouse_entered.connect(_on_pressure_hover)
	_pressure_box.mouse_exited.connect(_hide_tip.bind(_pressure_box))
	col.add_child(_pressure_box)
	var pcol := _vbox(5)
	_pressure_box.add_child(pcol)
	var prow := _hbox(8)
	pcol.add_child(prow)
	_pressure_icon = _icon("warning", UITheme.WARNING, 16.0)
	prow.add_child(_pressure_icon)
	_pressure_label = _label("SmallLabel")
	_pressure_label.add_theme_color_override("font_color", UITheme.WARNING.lerp(Color.WHITE, 0.3))
	_pressure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pressure_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pressure_label.custom_minimum_size = Vector2(200.0, 0.0)
	prow.add_child(_pressure_label)
	_pressure_bar = Charts.new()
	_pressure_bar.setup_bar("fixed", UITheme.WARNING, 8.0)
	pcol.add_child(_pressure_bar)
	_pressure_bar.set_value(0.0, true)


func _on_pressure_hover() -> void:
	_show_tip(_pressure_box, _pressure_label.text, I18n.t("hud.pressure.hint"), "", "right_of")


## Icon + name + tick-up value, then a segmented bar. Returns the bar.
func _stat_block(parent: Control, icon_id: String, key: String, bar_mode: String, tint: Color, bar_h: float) -> Charts:
	var box := _vbox(4)
	parent.add_child(box)
	var row := _hbox(8)
	box.add_child(row)
	row.add_child(_icon(icon_id, tint, 18.0))
	var name_l := _label("SmallLabel", key)
	_ellipsis(name_l)
	row.add_child(name_l)
	var val := _label("ValueLabel")
	val.add_theme_font_size_override("font_size", 18)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.custom_minimum_size = Vector2(58.0, 0.0)
	row.add_child(val)
	var bar: Charts = Charts.new()
	bar.setup_bar(bar_mode, tint, bar_h)
	bar.value_label = val
	bar.value_format = "pct"
	box.add_child(bar)
	bar.set_value(0.0, true)
	return bar


func _on_toggle_left_panel() -> void:
	# Mobile: the ✕ simply closes the Basin drawer so the map is unobstructed again.
	_left_panel.visible = false
	_left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hide_tip_now()
	_on_hud_resized()
	AudioSynth.play_click()
	GameState.vibrate_light()


## One-finger drag scrolling for ScrollContainers whose children would otherwise eat the drag.
func _on_scroll_touch_drag(event: InputEvent, sc: ScrollContainer) -> void:
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device != InputEvent.DEVICE_ID_EMULATION and (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			sc.scroll_vertical -= int(mm.relative.y)


func _on_left_panel_draw() -> void:
	UITheme.draw_brackets(_left_panel, Rect2(Vector2(-4.0, -4.0), _left_panel.size + Vector2(8.0, 8.0)), UITheme.AMBER, 16.0, 2.0)


# --- Region panel (right) ------------------------------------------------------------------

func _build_right_panel() -> void:
	# Mobile Region Card: a compact bottom-left sheet that only exists while a region is tapped.
	_right_panel = _panel("HudPanel")
	_right_panel.custom_minimum_size = Vector2(RIGHT_W, 0.0)
	_right_panel.size = Vector2(RIGHT_W, 0.0)
	_right_panel.position = Vector2(MARGIN, 720.0 - MARGIN - 272.0)
	_right_panel.visible = false
	_right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_panel.z_index = 4
	_right_panel.draw.connect(_on_right_panel_draw)
	add_child(_right_panel)
	var col := _vbox(8)
	_right_panel.add_child(col)

	# Header: region name + status badge + big close button.
	var head := _hbox(10)
	col.add_child(head)
	head.add_child(_icon("crosshair", UITheme.AMBER, 24.0))
	_region_name = _label("RegionLabel")
	_region_name.add_theme_font_size_override("font_size", 24)
	_ellipsis(_region_name)
	head.add_child(_region_name)
	_badge = PanelContainer.new()
	_badge.theme_type_variation = &"BadgePanel"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_badge_label = _label("BadgeLabel")
	_badge_label.add_theme_font_size_override("font_size", 18)
	_badge.add_child(_badge_label)
	head.add_child(_badge)
	_region_close_btn = Button.new()
	_region_close_btn.theme_type_variation = &"SpeedButton"
	_region_close_btn.custom_minimum_size = Vector2(56.0, 56.0)
	_region_close_btn.text = "✕"
	_region_close_btn.add_theme_font_size_override("font_size", 22)
	_region_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_region_close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_wire_button(_region_close_btn)
	_region_close_btn.pressed.connect(_on_region_close_pressed)
	head.add_child(_region_close_btn)

	# Legacy "select a region" hint: kept alive but never shown on mobile (the card hides).
	_hint_box = _hbox(0)
	_hint_box.visible = false
	col.add_child(_hint_box)
	_hint_icon = _icon("crosshair", UITheme.HEALTHY, 1.0)
	_hint_box.add_child(_hint_icon)

	_details = _vbox(8)
	col.add_child(_details)

	# ONE combined Sea Health / Crisis bar.
	var hc_row := _hbox(8)
	_details.add_child(hc_row)
	hc_row.add_child(_icon("sea_health", UITheme.HEALTHY, 22.0))
	_region_hc_label = _label("BodyLabel")
	_region_hc_label.add_theme_font_size_override("font_size", 19)
	_ellipsis(_region_hc_label)
	hc_row.add_child(_region_hc_label)
	_region_crisis_bar = Charts.new()
	_region_crisis_bar.setup_bar("inverse", UITheme.CRISIS, 16.0)
	_details.add_child(_region_crisis_bar)
	_region_crisis_bar.set_value(0.0, true)

	# ONE key problem tag ("Ana Sorun: ...").
	_region_trait_box = PanelContainer.new()
	_region_trait_box.theme_type_variation = &"BadgePanel"
	_region_trait_box.add_theme_stylebox_override("panel", UITheme.badge_box(UITheme.WARNING))
	_region_trait_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_region_trait_box.visible = false
	_details.add_child(_region_trait_box)
	var trait_row := _hbox(8)
	_region_trait_box.add_child(trait_row)
	trait_row.add_child(_icon("alert", UITheme.WARNING, 20.0))
	_region_trait_label = _label("BadgeLabel")
	_region_trait_label.add_theme_font_size_override("font_size", 19)
	_region_trait_label.add_theme_color_override("font_color", UITheme.WARNING.lerp(Color.WHITE, 0.25))
	_ellipsis(_region_trait_label)
	trait_row.add_child(_region_trait_label)

	# Secondary details stay alive (signals update them) but are hidden for a clean card.
	var extra := _vbox(0)
	extra.visible = false
	_details.add_child(extra)
	_region_species_badge = PanelContainer.new()
	extra.add_child(_region_species_badge)
	var sp_row := _hbox(6)
	_region_species_badge.add_child(sp_row)
	_region_species_icon = _icon("turtle", UITheme.HEALTHY, 14.0)
	sp_row.add_child(_region_species_icon)
	_region_species_label = _label("BadgeLabel")
	sp_row.add_child(_region_species_label)
	_coastal_value = _label("SmallLabel")
	extra.add_child(_coastal_value)
	_region_trend_badge = PanelContainer.new()
	extra.add_child(_region_trend_badge)
	var trend_inner := _hbox(4)
	_region_trend_badge.add_child(trend_inner)
	_region_trend_icon = _icon("trend_down", UITheme.HEALTHY, 13.0)
	trend_inner.add_child(_region_trend_icon)
	_region_trend_label = _label("BadgeLabel")
	trend_inner.add_child(_region_trend_label)

	# Big action buttons side by side (icon, name, status, cost - no keyboard hints).
	var actions := _hbox(10)
	_details.add_child(actions)
	for a in Balance.ACTION_ORDER:
		_build_action_row(actions, str(a))

	_build_tree_button()


func _on_region_close_pressed() -> void:
	_hide_tip_now()
	AudioSynth.play_click()
	GameState.vibrate_light()
	EventBus.region_selected.emit("")


## Bottom-right corner: [?] Guide button + big glowing POLICY TREE primary button.
func _build_tree_button() -> void:
	_bottom_right_bar = _hbox(10)
	_bottom_right_bar.z_index = 3
	add_child(_bottom_right_bar)

	_help_btn = Button.new()
	_help_btn.theme_type_variation = &"SpeedButton"
	_help_btn.custom_minimum_size = Vector2(64.0, 64.0)
	_help_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_help_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_help_icon = _icon("help", UITheme.TEXT, 30.0)
	_help_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_icon.set_anchors_preset(Control.PRESET_CENTER)
	_help_icon.offset_left = -15.0
	_help_icon.offset_top = -15.0
	_help_icon.offset_right = 15.0
	_help_icon.offset_bottom = 15.0
	_help_btn.add_child(_help_icon)
	_wire_button(_help_btn)
	_help_btn.pressed.connect(_show_manual)
	_bottom_right_bar.add_child(_help_btn)

	_tree_btn = Button.new()
	_tree_btn.theme_type_variation = &"PrimaryButton"
	_tree_btn.toggle_mode = true
	_tree_btn.custom_minimum_size = Vector2(280.0, 64.0)
	_tree_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_tree_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_wire_button(_tree_btn)
	_tree_btn.pressed.connect(_on_tree_pressed)
	_bottom_right_bar.add_child(_tree_btn)
	var row := _hbox(12)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 14.0
	row.offset_right = -14.0
	row.offset_top = 4.0
	row.offset_bottom = -4.0
	_tree_btn.add_child(row)
	_tree_icon = _icon(_icon_or("tree", "globe"), UITheme.AMBER, 36.0)
	row.add_child(_tree_icon)
	var mid := _vbox(0)
	mid.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(mid)
	var title := _label("HeaderLabel", "hud.tree.button")
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.3))
	_ellipsis(title)
	mid.add_child(title)
	_tree_status = _label("DimLabel")
	_tree_status.add_theme_font_size_override("font_size", 16)
	_ellipsis(_tree_status)
	mid.add_child(_tree_status)


## Keyboard hint chip ("Q", "T") drawn like a small key.
func _keycap(key_text: String, accent: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", UITheme.keycap_box(accent))
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var l := _label("SmallLabel")
	l.text = key_text
	l.add_theme_font_override("font", UITheme.mono_bold_font())
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.35))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(10.0, 0.0)
	p.add_child(l)
	return p


## preferred if icons.gd draws it already, else a known icon (new ids land in Phase 2).
func _icon_or(preferred: String, fallback: String) -> String:
	return preferred if Icons.IDS.has(preferred) else fallback


func _stat_tint(data_key: String) -> Color:
	match data_key:
		"pollution":
			return UITheme.TERRACOTTA.lightened(0.15)
		"coral_health":
			return Color(1.0, 0.56, 0.58)
		"seagrass":
			return UITheme.HEALTHY
		"fish_stock":
			return Color(0.55, 0.82, 0.95)
		"awareness":
			return AWARE_COLOR
		"protection":
			return Color(0.18, 0.85, 0.72)
	return UITheme.TEXT


func _small_stat(parent: Control, icon_id: String, key: String, bar_mode: String, tint: Color) -> Charts:
	var box := _vbox(3)
	parent.add_child(box)
	var row := _hbox(8)
	box.add_child(row)
	row.add_child(_icon(icon_id, tint, 16.0))
	var name_l := _label("SmallLabel", key)
	_ellipsis(name_l)
	row.add_child(name_l)
	var val := _label("SmallLabel")
	val.add_theme_font_override("font", UITheme.mono_bold_font())
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.custom_minimum_size = Vector2(46.0, 0.0)
	row.add_child(val)
	var bar: Charts = Charts.new()
	bar.setup_bar(bar_mode, tint, 8.0)
	bar.value_label = val
	box.add_child(bar)
	bar.set_value(0.0, true)
	return bar


func _build_action_row(parent: Control, action_id: String) -> void:
	var def: Dictionary = Balance.ACTIONS[action_id]
	var btn := Button.new()
	btn.theme_type_variation = &"ActionButton"
	btn.custom_minimum_size = Vector2(196.0, 84.0)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.clip_contents = true
	_wire_button(btn)
	btn.mouse_entered.connect(_on_action_hover.bind(btn, action_id))
	btn.mouse_exited.connect(_hide_tip.bind(btn))
	_wire_long_press(btn, _on_action_hover.bind(btn, action_id))
	btn.pressed.connect(_on_action_pressed.bind(action_id))
	parent.add_child(btn)

	var inner := _vbox(2)
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 10.0
	inner.offset_right = -10.0
	inner.offset_top = 6.0
	inner.offset_bottom = -9.0
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(inner)
	var top := _hbox(8)
	inner.add_child(top)
	var ic := _icon(str(def.get("icon", action_id)), UITheme.HEALTHY, 28.0)
	top.add_child(ic)
	var name_l := _label("SmallLabel")
	name_l.add_theme_font_override("font", UITheme.mono_bold_font())
	name_l.add_theme_font_size_override("font_size", 18)
	_ellipsis(name_l)
	top.add_child(name_l)
	var bottom := _hbox(6)
	inner.add_child(bottom)
	var status_l := _label("DimLabel")
	status_l.add_theme_font_size_override("font_size", 15)
	_ellipsis(status_l)
	bottom.add_child(status_l)
	var cost_labels: Dictionary = {}
	var cost: Dictionary = def.get("cost", {})
	for ck in RES_ORDER:
		var res_key: String = ck
		if not cost.has(res_key):
			continue
		var cl := _label("SmallLabel")
		cl.add_theme_font_override("font", UITheme.mono_bold_font())
		cl.add_theme_font_size_override("font_size", 17)
		cl.text = str(roundi(float(cost[res_key])))
		cl.add_theme_color_override("font_color", RES_COLORS[res_key])
		bottom.add_child(cl)
		bottom.add_child(_icon(res_key, RES_COLORS[res_key], 16.0))
		cost_labels[res_key] = cl

	var cd_bg := ColorRect.new()
	cd_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_bg.color = UITheme.with_alpha(UITheme.DEEP, 0.8)
	cd_bg.anchor_left = 0.0
	cd_bg.anchor_right = 1.0
	cd_bg.anchor_top = 1.0
	cd_bg.anchor_bottom = 1.0
	cd_bg.offset_left = 10.0
	cd_bg.offset_right = -10.0
	cd_bg.offset_top = -7.0
	cd_bg.offset_bottom = -3.0
	btn.add_child(cd_bg)
	var cd_fill := ColorRect.new()
	cd_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_fill.color = UITheme.AMBER
	cd_fill.anchor_left = 0.0
	cd_fill.anchor_top = 0.0
	cd_fill.anchor_bottom = 1.0
	cd_fill.anchor_right = 0.0
	cd_bg.add_child(cd_fill)

	_action_rows.append({
		"id": action_id,
		"button": btn,
		"icon": ic,
		"name": name_l,
		"status": status_l,
		"cost": cost_labels,
		"cd": cd_fill,
		"keycap": null,
		"hotkey": "",
		"name_key": str(def.get("name_key", "")),
		"desc_key": str(def.get("desc_key", "")),
	})
	name_l.text = I18n.t(str(def.get("name_key", "")))


func _on_right_panel_draw() -> void:
	var c: Color = _right_bracket_color
	if _region_status == "critical" or _region_status == "collapsed":
		c = UITheme.with_alpha(c, 0.55 + 0.45 * (0.5 + 0.5 * sin(_time * 6.0)))
	UITheme.draw_brackets(_right_panel, Rect2(Vector2(-4.0, -4.0), _right_panel.size + Vector2(8.0, 8.0)), c, 16.0, 2.0)


# --- Toasts and tip ---------------------------------------------------------------------------

func _build_toasts() -> void:
	_toast_box = _vbox(8)
	_toast_box.alignment = BoxContainer.ALIGNMENT_END
	_toast_box.position = Vector2(1280.0 - MARGIN - TOAST_W, 720.0 - MARGIN - 76.0 - TOAST_AREA_H)
	_toast_box.size = Vector2(TOAST_W, TOAST_AREA_H)
	add_child(_toast_box)


func _safe_insets() -> Vector2:
	var s: Vector4 = UITheme.safe_insets(get_viewport())
	return Vector2(s.x, s.z)


## Mobile: the toast feed sits on the right, just above the POLICY TREE button.
func _layout_toasts() -> void:
	var vs: Vector2 = get_viewport_rect().size
	var safe: Vector4 = UITheme.safe_insets(get_viewport())
	var pad_r: float = MARGIN + safe.z
	var pad_b: float = MARGIN + safe.w
	_toast_avail = TOAST_AREA_H
	var box_h: float = maxf(_toast_avail, _toast_box.get_combined_minimum_size().y)
	var bottom_y: float = vs.y - pad_b - 82.0
	_toast_box.size = Vector2(TOAST_W, box_h)
	_toast_box.position = Vector2(vs.x - pad_r - TOAST_W, bottom_y - box_h)


## The taller BASIN STATUS panel leaves less room: drop the oldest toast while the feed
## would overflow the screen bottom (one per frame; the freed node leaves next frame).
func _guard_toasts() -> void:
	if _toasts.size() <= 1:
		return
	if _toast_box.get_combined_minimum_size().y <= _toast_avail + 1.0:
		return
	var oldest: Dictionary = _toasts[0]
	var root: Control = oldest["root"]
	_drop_toast(root)
	if is_instance_valid(root) and root.get_parent() == _toast_box:
		_toast_box.remove_child(root)
	_layout_toasts()


# --- Visual Juice: screen vignette & floating feedback ------------------------------------

func _build_vignette() -> void:
	_vignette = Control.new()
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.draw.connect(_draw_vignette)
	add_child(_vignette)


func _draw_vignette() -> void:
	if _vignette_alpha <= 0.005:
		return
	var vp: Vector2 = get_viewport_rect().size
	var w: float = vp.x
	var h: float = vp.y
	var d: float = 200.0
	var col := Color(_vignette_color.r, _vignette_color.g, _vignette_color.b, _vignette_alpha)
	var trans := Color(_vignette_color.r, _vignette_color.g, _vignette_color.b, 0.0)

	_vignette.draw_polygon(
		PackedVector2Array([Vector2(0.0, 0.0), Vector2(w, 0.0), Vector2(w, d), Vector2(0.0, d)]),
		PackedColorArray([col, col, trans, trans])
	)
	_vignette.draw_polygon(
		PackedVector2Array([Vector2(0.0, h), Vector2(w, h), Vector2(w, h - d), Vector2(0.0, h - d)]),
		PackedColorArray([col, col, trans, trans])
	)
	_vignette.draw_polygon(
		PackedVector2Array([Vector2(0.0, 0.0), Vector2(d, 0.0), Vector2(d, h), Vector2(0.0, h)]),
		PackedColorArray([col, trans, trans, col])
	)
	_vignette.draw_polygon(
		PackedVector2Array([Vector2(w, 0.0), Vector2(w - d, 0.0), Vector2(w - d, h), Vector2(w, h)]),
		PackedColorArray([col, trans, trans, col])
	)


func _flash_vignette(col: Color, peak: float = 0.45, duration: float = 1.0) -> void:
	if _vignette == null:
		return
	_vignette_color = col
	_vignette_alpha = peak
	_vignette.queue_redraw()
	if _vignette_tween != null and _vignette_tween.is_valid():
		_vignette_tween.kill()
	_vignette_tween = create_tween()
	_vignette_tween.set_trans(Tween.TRANS_QUAD)
	_vignette_tween.set_ease(Tween.EASE_OUT)
	_vignette_tween.tween_property(self, "_vignette_alpha", 0.0, duration)


func _build_floating_layer() -> void:
	_floating_layer = Control.new()
	_floating_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_floating_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floating_layer.z_index = 8
	add_child(_floating_layer)


func _spawn_floating_text(text: String, col: Color, global_pos: Vector2, rise: float = 36.0, duration: float = 1.1) -> void:
	if not is_instance_valid(_floating_layer):
		return
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", UITheme.mono_bold_font())
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.global_position = global_pos
	_floating_layer.add_child(l)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "global_position:y", global_pos.y - rise, duration)
	tw.tween_property(l, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(l.queue_free)


# --- 60-Second Onboarding Briefing --------------------------------------------------------

# --- Interactive Mission Directives HUD (5 Hands-On Guided Steps) -------------------------

func _build_directives() -> void:
	var vs: Vector2 = get_viewport_rect().size
	var dw: float = minf(vs.x - 32.0, 680.0)
	_directive_box = PanelContainer.new()
	_directive_box.theme_type_variation = &"HudPanel"
	_directive_box.custom_minimum_size = Vector2(dw, 0.0)
	_directive_box.position = Vector2((vs.x - dw) * 0.5, TOP_H + 8.0)
	_directive_box.mouse_filter = Control.MOUSE_FILTER_PASS
	_directive_box.visible = false
	_directive_box.z_index = 22
	var sb: StyleBoxFlat = UITheme.panel_box(UITheme.AMBER, UITheme.with_alpha(UITheme.BG_PANEL, 0.96), 2, UITheme.with_alpha(UITheme.AMBER, 0.25), 16, 12)
	sb.content_margin_left = 18.0
	sb.content_margin_right = 18.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	_directive_box.add_theme_stylebox_override("panel", sb)
	add_child(_directive_box)

	var dcol := _vbox(6)
	_directive_box.add_child(dcol)

	var dhead := _hbox(10)
	dcol.add_child(dhead)

	var dicon := _icon("crosshair", UITheme.AMBER, 22.0)
	dhead.add_child(dicon)

	_directive_step_label = _label("HeaderLabel")
	_directive_step_label.add_theme_font_size_override("font_size", 17)
	_directive_step_label.add_theme_color_override("font_color", UITheme.AMBER)
	dhead.add_child(_directive_step_label)

	var pips_row := _hbox(6)
	dhead.add_child(pips_row)
	_directive_pips.clear()
	for i in 5:
		var pip := _label("SmallLabel")
		pip.text = "○"
		pip.add_theme_font_override("font", UITheme.mono_bold_font())
		pip.add_theme_font_size_override("font_size", 18)
		pip.add_theme_color_override("font_color", UITheme.TEXT_DIM)
		pips_row.add_child(pip)
		_directive_pips.append(pip)

	dhead.add_child(_spacer())

	_directive_action_btn = Button.new()
	_directive_action_btn.theme_type_variation = &"PrimaryButton"
	_directive_action_btn.text = I18n.t("directive.btn.start")
	_directive_action_btn.custom_minimum_size = Vector2(130.0, 44.0)
	_directive_action_btn.add_theme_font_size_override("font_size", 16)
	_directive_action_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_directive_action_btn.visible = false
	_directive_action_btn.pressed.connect(_on_directive_action_pressed)
	dhead.add_child(_directive_action_btn)

	_directive_skip_btn = Button.new()
	_directive_skip_btn.theme_type_variation = &"ChipButton"
	_directive_skip_btn.text = I18n.t("directive.skip")
	_directive_skip_btn.custom_minimum_size = Vector2(100.0, 44.0)
	_directive_skip_btn.add_theme_font_size_override("font_size", 16)
	_directive_skip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_directive_skip_btn.pressed.connect(_dismiss_directives)
	dhead.add_child(_directive_skip_btn)

	_directive_body_label = RichTextLabel.new()
	_directive_body_label.bbcode_enabled = true
	_directive_body_label.fit_content = true
	_directive_body_label.custom_minimum_size = Vector2(dw - 36.0, 0.0)
	_directive_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_directive_body_label.add_theme_font_override("normal_font", UITheme.body_font())
	_directive_body_label.add_theme_font_override("bold_font", UITheme.mono_bold_font())
	_directive_body_label.add_theme_font_size_override("normal_font_size", 17)
	_directive_body_label.add_theme_font_size_override("bold_font_size", 17)
	_directive_body_label.add_theme_color_override("default_color", UITheme.TEXT)
	dcol.add_child(_directive_body_label)

	# Overlay for drawing pulsing highlight boxes & pointers directly over targets
	_directive_overlay = Control.new()
	_directive_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_directive_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_directive_overlay.z_index = 20
	_directive_overlay.draw.connect(_on_directive_overlay_draw)
	add_child(_directive_overlay)


func _start_directives() -> void:
	_directive_active = true
	_directive_step = 1
	_directive_pulse_time = 0.0
	if _directive_box != null:
		_directive_box.visible = true
		_directive_box.modulate.a = 1.0
	_update_directive_ui()


func _set_directive_step(step: int) -> void:
	if not _directive_active:
		return
	_directive_step = step
	_directive_pulse_time = 0.0
	_update_directive_ui()
	_flash_vignette(UITheme.HEALTHY, 0.25, 0.6)
	if _directive_overlay != null:
		_directive_overlay.queue_redraw()
	if step == 5 and GameState.speed_index >= 1 and not GameState.is_paused():
		_complete_directives()


func _update_directive_ui() -> void:
	if _directive_step_label == null or _directive_body_label == null:
		return
	_directive_step_label.text = I18n.t("directive.title") + " · " + I18n.t("directive.step_fmt", {"cur": str(_directive_step), "total": "5"})
	for i in range(_directive_pips.size()):
		var pip: Label = _directive_pips[i]
		if i + 1 < _directive_step:
			pip.text = "✓"
			pip.add_theme_color_override("font_color", UITheme.HEALTHY)
		elif i + 1 == _directive_step:
			pip.text = "◉"
			pip.add_theme_color_override("font_color", UITheme.AMBER)
		else:
			pip.text = "○"
			pip.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	if _directive_action_btn != null:
		_directive_action_btn.visible = _directive_step == 5
	var key: String = "directive.step%d" % clampi(_directive_step, 1, 5)
	_directive_body_label.text = I18n.t(key)


func _on_directive_action_pressed() -> void:
	GameState.set_speed(1)
	_complete_directives()


func is_directive_active() -> bool:
	return _directive_active


func directive_step() -> int:
	return _directive_step


func complete_directives() -> void:
	if _directive_active:
		_complete_directives()


func _dismiss_directives() -> void:
	if not _directive_active:
		return
	_directive_active = false
	if _directive_box != null:
		var tw := create_tween()
		tw.tween_property(_directive_box, "modulate:a", 0.0, 0.3)
		tw.tween_callback(func() -> void:
			if _directive_box != null:
				_directive_box.visible = false
		)
	if _directive_overlay != null:
		_directive_overlay.queue_redraw()


func _complete_directives() -> void:
	_directive_active = false
	if GameState.speed_index == 0:
		GameState.set_speed(1)
	AudioSynth.play_policy_adopt()
	_flash_vignette(UITheme.HEALTHY, 0.45, 1.2)
	for pip in _directive_pips:
		pip.text = "✓"
		pip.add_theme_color_override("font_color", UITheme.HEALTHY)
	_directive_step_label.text = I18n.t("directive.title")
	_directive_body_label.text = "[color=#4ade80]" + I18n.t("directive.done") + "[/color]"
	if _directive_overlay != null:
		_directive_overlay.queue_redraw()
	var tw := create_tween()
	tw.tween_interval(3.5)
	tw.tween_property(_directive_box, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func() -> void:
		if _directive_box != null:
			_directive_box.visible = false
	)


func _on_directive_overlay_draw() -> void:
	if not _directive_active or _directive_step < 1 or _directive_step > 5:
		return
	var pulse: float = 0.5 + 0.5 * sin(_directive_pulse_time * 6.0)
	var col: Color = UITheme.HEALTHY if _directive_step in [1, 2, 3] else UITheme.AMBER
	var c := UITheme.with_alpha(col, 0.4 + 0.55 * pulse)

	var target_rect: Rect2 = Rect2()
	match _directive_step:
		1:
			if map != null and map.has_method("region_screen_pos"):
				var pt: Vector2 = map.region_screen_pos("antalya")
				target_rect = Rect2(pt - Vector2(60.0, 40.0), Vector2(120.0, 80.0))
		2:
			if _action_rows.size() > 0 and is_instance_valid(_action_rows[0].get("button")):
				var btn: Button = _action_rows[0]["button"]
				target_rect = btn.get_global_rect()
		3:
			var bubbles: Array = GameState.active_bubbles()
			if not bubbles.is_empty() and map != null and map.has_method("region_screen_pos"):
				var b_reg: String = str(bubbles[0].get("region", "antalya"))
				var pt: Vector2 = map.region_screen_pos(b_reg) + Vector2(30.0, -25.0)
				target_rect = Rect2(pt - Vector2(32.0, 32.0), Vector2(64.0, 64.0))
			elif map != null and map.has_method("region_screen_pos"):
				var pt: Vector2 = map.region_screen_pos("antalya") + Vector2(30.0, -25.0)
				target_rect = Rect2(pt - Vector2(32.0, 32.0), Vector2(64.0, 64.0))
		4:
			if is_instance_valid(_tree_btn):
				target_rect = _tree_btn.get_global_rect()
		5:
			if _speed_buttons.size() > 1 and is_instance_valid(_speed_buttons[1]):
				var spd_btn: Button = _speed_buttons[1]
				target_rect = spd_btn.get_global_rect()

	if target_rect.size != Vector2.ZERO:
		var pad: float = 6.0 + 3.0 * pulse
		var r: Rect2 = target_rect.grow(pad)
		_directive_overlay.draw_rect(r, UITheme.with_alpha(col, 0.08 * pulse))
		_directive_overlay.draw_rect(r, c, false, 2.0)
		var blen: float = 14.0
		_directive_overlay.draw_line(r.position, r.position + Vector2(blen, 0), c, 2.5)
		_directive_overlay.draw_line(r.position, r.position + Vector2(0, blen), c, 2.5)
		_directive_overlay.draw_line(Vector2(r.end.x, r.position.y), Vector2(r.end.x - blen, r.position.y), c, 2.5)
		_directive_overlay.draw_line(Vector2(r.end.x, r.position.y), Vector2(r.end.x, r.position.y + blen), c, 2.5)
		_directive_overlay.draw_line(r.end, r.end - Vector2(blen, 0), c, 2.5)
		_directive_overlay.draw_line(r.end, r.end - Vector2(0, blen), c, 2.5)
		_directive_overlay.draw_line(Vector2(r.position.x, r.end.y), Vector2(r.position.x + blen, r.end.y), c, 2.5)
		_directive_overlay.draw_line(Vector2(r.position.x, r.end.y), Vector2(r.position.x, r.end.y - blen), c, 2.5)


# --- 3-Step Visual Mobile Tutorial Carousel (Pillar 5) --------------------------------------

func _build_manual_modal() -> void:
	_help_modal = Control.new()
	_help_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_help_modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_modal.visible = false
	_help_modal.z_index = 35
	add_child(_help_modal)

	_help_backdrop = Control.new()
	_help_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_help_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_help_backdrop.draw.connect(func() -> void:
		_help_backdrop.draw_rect(_help_backdrop.get_rect(), Color(0.012, 0.022, 0.045, 0.92))
	)
	_help_backdrop.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_close_manual()
	)
	_help_modal.add_child(_help_backdrop)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(960.0, 560.0)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb: StyleBoxFlat = UITheme.panel_box(UITheme.LINE_AMBER, UITheme.with_alpha(UITheme.BG_PANEL, 0.98), 2, UITheme.with_alpha(UITheme.AMBER, 0.25), 24, 16)
	sb.content_margin_left = 32.0
	sb.content_margin_right = 32.0
	sb.content_margin_top = 20.0
	sb.content_margin_bottom = 20.0
	card.add_theme_stylebox_override("panel", sb)
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -480.0
	card.offset_top = -280.0
	card.offset_right = 480.0
	card.offset_bottom = 280.0
	_help_modal.add_child(card)

	var col := _vbox(10)
	card.add_child(col)

	# Top bar: Title + Close button
	var top := _hbox(12)
	col.add_child(top)
	top.add_child(_icon("help", UITheme.AMBER, 26.0))
	var modal_title := _label("HeaderLabel", "tut3.title")
	modal_title.add_theme_font_size_override("font_size", 24)
	modal_title.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.3))
	top.add_child(modal_title)
	top.add_child(_spacer())

	var close_btn := Button.new()
	close_btn.theme_type_variation = &"SpeedButton"
	close_btn.custom_minimum_size = Vector2(56.0, 56.0)
	close_btn.text = "✕"
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.pressed.connect(_close_manual)
	top.add_child(close_btn)

	col.add_child(_sep())

	# Slide Title
	_tut_title_l = _label("HeaderLabel")
	_tut_title_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tut_title_l.add_theme_font_override("font", UITheme.mono_bold_font())
	_tut_title_l.add_theme_font_size_override("font_size", 24)
	_tut_title_l.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.25))
	col.add_child(_tut_title_l)

	# Big Visual Illustration Canvas
	_tut_canvas = Control.new()
	_tut_canvas.custom_minimum_size = Vector2(890.0, 200.0)
	_tut_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut_canvas.draw.connect(_on_tut_canvas_draw)
	col.add_child(_tut_canvas)

	# Slide Body Text
	_tut_body_l = _label("BodyLabel")
	_tut_body_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tut_body_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tut_body_l.add_theme_font_size_override("font_size", 20)
	_tut_body_l.add_theme_color_override("font_color", UITheme.TEXT)
	_tut_body_l.custom_minimum_size = Vector2(880.0, 60.0)
	col.add_child(_tut_body_l)

	col.add_child(_sep())

	# Footer: Prev, Pips, Next / Start
	var footer := _hbox(16)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(footer)

	_tut_prev_btn = Button.new()
	_tut_prev_btn.theme_type_variation = &"ChipButton"
	_tut_prev_btn.custom_minimum_size = Vector2(150.0, 56.0)
	_tut_prev_btn.text = I18n.t("tut.btn.prev")
	_tut_prev_btn.add_theme_font_size_override("font_size", 20)
	_tut_prev_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tut_prev_btn.pressed.connect(_on_tut_prev_pressed)
	footer.add_child(_tut_prev_btn)

	var pips_box := _hbox(12)
	pips_box.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_child(pips_box)
	_tut_pips.clear()
	for i in range(3):
		var pip := Label.new()
		pip.text = "●" if i == 0 else "○"
		pip.add_theme_font_size_override("font_size", 26)
		pip.add_theme_color_override("font_color", UITheme.AMBER if i == 0 else UITheme.TEXT_DIM)
		pips_box.add_child(pip)
		_tut_pips.append(pip)

	_tut_next_btn = Button.new()
	_tut_next_btn.theme_type_variation = &"ChipButton"
	_tut_next_btn.custom_minimum_size = Vector2(160.0, 56.0)
	_tut_next_btn.text = I18n.t("tut.btn.next")
	_tut_next_btn.add_theme_font_size_override("font_size", 20)
	_tut_next_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tut_next_btn.pressed.connect(_on_tut_next_pressed)
	footer.add_child(_tut_next_btn)

	_tut_start_btn = Button.new()
	_tut_start_btn.theme_type_variation = &"PrimaryButton"
	_tut_start_btn.custom_minimum_size = Vector2(280.0, 56.0)
	_tut_start_btn.text = I18n.t("tut3.btn.start")
	_tut_start_btn.add_theme_font_size_override("font_size", 22)
	_tut_start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_tut_start_btn.pressed.connect(_close_manual)
	footer.add_child(_tut_start_btn)

	_update_tut_slide()


func _update_tut_slide() -> void:
	_tut_slide = clampi(_tut_slide, 0, 2)
	if _tut_title_l == null or _tut_body_l == null:
		return
	var title_keys := ["tut3.slide1.title", "tut3.slide2.title", "tut3.slide3.title"]
	var body_keys := ["tut3.slide1.body", "tut3.slide2.body", "tut3.slide3.body"]
	_tut_title_l.text = I18n.t(title_keys[_tut_slide])
	_tut_body_l.text = I18n.t(body_keys[_tut_slide])

	for i in range(_tut_pips.size()):
		var p: Label = _tut_pips[i]
		if i == _tut_slide:
			p.text = "●"
			p.add_theme_color_override("font_color", UITheme.AMBER)
		else:
			p.text = "○"
			p.add_theme_color_override("font_color", UITheme.TEXT_DIM)

	if _tut_prev_btn != null:
		_tut_prev_btn.visible = _tut_slide > 0
	if _tut_next_btn != null:
		_tut_next_btn.visible = _tut_slide < 2
	if _tut_start_btn != null:
		_tut_start_btn.visible = _tut_slide == 2

	if _tut_canvas != null:
		_tut_canvas.queue_redraw()


func _on_tut_prev_pressed() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_tut_slide = maxi(0, _tut_slide - 1)
	_update_tut_slide()


func _on_tut_next_pressed() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_tut_slide = mini(2, _tut_slide + 1)
	_update_tut_slide()


func _on_tut_canvas_draw() -> void:
	if _tut_canvas == null:
		return
	var r: Rect2 = _tut_canvas.get_rect()
	var c: Vector2 = r.size * 0.5
	var font: Font = UITheme.mono_bold_font()

	# Backdrop subtle panel
	var bg_sb := UITheme.panel_box(UITheme.LINE_DIM, UITheme.with_alpha(UITheme.DEEP, 0.6), 1, Color(0,0,0,0), 0, 10)
	_tut_canvas.draw_style_box(bg_sb, Rect2(0.0, 0.0, r.size.x, r.size.y))

	match _tut_slide:
		0:
			# Slayt 1: HEDEFİN - Akdeniz Sağlığı %60+ vs Kriz %100
			var p_healthy := Vector2(c.x - 200.0, c.y)
			var p_crisis := Vector2(c.x + 200.0, c.y)

			# Healthy circle
			_tut_canvas.draw_circle(p_healthy, 56.0, UITheme.with_alpha(UITheme.HEALTHY, 0.18))
			_tut_canvas.draw_arc(p_healthy, 56.0, 0.0, TAU, 36, UITheme.HEALTHY, 3.0)
			_tut_canvas.draw_arc(p_healthy, 44.0, -PI * 0.7, PI * 0.7, 24, UITheme.HEALTHY.lightened(0.3), 3.5)
			_tut_canvas.draw_string(font, p_healthy + Vector2(-60.0, 80.0), I18n.t("tut3.slide1.healthy"), HORIZONTAL_ALIGNMENT_CENTER, 140.0, 18, UITheme.HEALTHY)

			# VS badge in center
			_tut_canvas.draw_string(font, c + Vector2(-20.0, 8.0), "VS", HORIZONTAL_ALIGNMENT_CENTER, 40.0, 26, UITheme.AMBER)

			# Crisis circle
			_tut_canvas.draw_circle(p_crisis, 56.0, UITheme.with_alpha(UITheme.CRISIS, 0.18))
			_tut_canvas.draw_arc(p_crisis, 56.0, 0.0, TAU, 36, UITheme.CRISIS, 3.0)
			_tut_canvas.draw_line(p_crisis + Vector2(-20.0, -20.0), p_crisis + Vector2(20.0, 20.0), UITheme.CRISIS, 4.0)
			_tut_canvas.draw_line(p_crisis + Vector2(-20.0, 20.0), p_crisis + Vector2(20.0, -20.0), UITheme.CRISIS, 4.0)
			_tut_canvas.draw_string(font, p_crisis + Vector2(-60.0, 80.0), I18n.t("tut3.slide1.crisis"), HORIZONTAL_ALIGNMENT_CENTER, 140.0, 18, UITheme.CRISIS)

		1:
			# Slayt 2: BALONLARI PATLAT & KAYNAK TOPLA
			var p_sci := Vector2(c.x - 220.0, c.y)
			var p_sup := Vector2(c.x + 220.0, c.y)

			# Cyan Science Bubble
			_tut_canvas.draw_circle(p_sci, 52.0, UITheme.with_alpha(UITheme.SCIENCE_BLUE, 0.25))
			_tut_canvas.draw_arc(p_sci, 52.0, 0.0, TAU, 36, UITheme.SCIENCE_BLUE, 3.0)
			_tut_canvas.draw_circle(p_sci + Vector2(-16.0, -16.0), 8.0, Color(1, 1, 1, 0.6))
			_tut_canvas.draw_string(font, p_sci + Vector2(-70.0, 80.0), I18n.t("tut3.slide2.sci"), HORIZONTAL_ALIGNMENT_CENTER, 160.0, 18, UITheme.SCIENCE_BLUE)

			# Center Tap Ripple
			_tut_canvas.draw_arc(c, 24.0, 0.0, TAU, 28, UITheme.AMBER, 2.5)
			_tut_canvas.draw_arc(c, 44.0, 0.0, TAU, 32, UITheme.with_alpha(UITheme.AMBER, 0.5), 2.0)
			_tut_canvas.draw_arc(c, 64.0, 0.0, TAU, 36, UITheme.with_alpha(UITheme.AMBER, 0.2), 1.5)
			_tut_canvas.draw_string(font, c + Vector2(-90.0, 8.0), I18n.t("tut3.slide2.tap"), HORIZONTAL_ALIGNMENT_CENTER, 180.0, 17, Color.WHITE)

			# Amber Support Bubble
			_tut_canvas.draw_circle(p_sup, 52.0, UITheme.with_alpha(UITheme.AMBER, 0.25))
			_tut_canvas.draw_arc(p_sup, 52.0, 0.0, TAU, 36, UITheme.AMBER, 3.0)
			_tut_canvas.draw_circle(p_sup + Vector2(-16.0, -16.0), 8.0, Color(1, 1, 1, 0.6))
			_tut_canvas.draw_string(font, p_sup + Vector2(-70.0, 80.0), I18n.t("tut3.slide2.sup"), HORIZONTAL_ALIGNMENT_CENTER, 160.0, 18, UITheme.AMBER)

		2:
			# Slayt 3: POLİTİKA AĞACINI GELİŞTİR
			var n1 := Vector2(c.x - 280.0, c.y - 20.0)
			var n2 := Vector2(c.x - 110.0, c.y - 20.0)
			var n3 := Vector2(c.x + 60.0, c.y - 20.0)

			# Connecting lines
			_tut_canvas.draw_line(n1 + Vector2(40.0, 0), n2 - Vector2(40.0, 0), UITheme.HEALTHY, 3.0)
			_tut_canvas.draw_line(n2 + Vector2(40.0, 0), n3 - Vector2(40.0, 0), UITheme.SCIENCE_BLUE, 3.0)

			# Node 1: Adopted
			_tut_canvas.draw_rect(Rect2(n1.x - 40.0, n1.y - 30.0, 80.0, 60.0), UITheme.with_alpha(UITheme.HEALTHY, 0.2), true)
			_tut_canvas.draw_rect(Rect2(n1.x - 40.0, n1.y - 30.0, 80.0, 60.0), UITheme.HEALTHY, false, 2.5)
			_tut_canvas.draw_string(font, n1 + Vector2(-40.0, 6.0), I18n.t("tut3.slide3.adopted"), HORIZONTAL_ALIGNMENT_CENTER, 80.0, 15, UITheme.HEALTHY)

			# Node 2: Available
			_tut_canvas.draw_rect(Rect2(n2.x - 40.0, n2.y - 30.0, 80.0, 60.0), UITheme.with_alpha(UITheme.SCIENCE_BLUE, 0.3), true)
			_tut_canvas.draw_rect(Rect2(n2.x - 40.0, n2.y - 30.0, 80.0, 60.0), UITheme.SCIENCE_BLUE, false, 2.5)
			_tut_canvas.draw_string(font, n2 + Vector2(-40.0, 6.0), I18n.t("tut3.slide3.available"), HORIZONTAL_ALIGNMENT_CENTER, 80.0, 15, Color.WHITE)

			# Node 3: Locked
			_tut_canvas.draw_rect(Rect2(n3.x - 40.0, n3.y - 30.0, 80.0, 60.0), UITheme.with_alpha(UITheme.LINE_DIM, 0.2), true)
			_tut_canvas.draw_rect(Rect2(n3.x - 40.0, n3.y - 30.0, 80.0, 60.0), UITheme.LINE_DIM, false, 2.0)
			_tut_canvas.draw_string(font, n3 + Vector2(-40.0, 6.0), I18n.t("tut3.slide3.locked"), HORIZONTAL_ALIGNMENT_CENTER, 80.0, 15, UITheme.TEXT_DIM)

			# Arrow to big button
			_tut_canvas.draw_line(n3 + Vector2(50.0, 0), n3 + Vector2(100.0, 0), UITheme.AMBER, 3.0)
			_tut_canvas.draw_line(n3 + Vector2(90.0, -10.0), n3 + Vector2(100.0, 0), UITheme.AMBER, 3.0)
			_tut_canvas.draw_line(n3 + Vector2(90.0, 10.0), n3 + Vector2(100.0, 0), UITheme.AMBER, 3.0)

			# Mock Policy Tree button
			var btn_r := Rect2(c.x + 180.0, c.y - 32.0, 180.0, 64.0)
			_tut_canvas.draw_rect(btn_r, UITheme.with_alpha(UITheme.AMBER, 0.25), true)
			_tut_canvas.draw_rect(btn_r, UITheme.AMBER, false, 2.5)
			_tut_canvas.draw_string(font, Vector2(btn_r.position.x, btn_r.position.y + 38.0), I18n.t("tut3.slide3.tree_btn"), HORIZONTAL_ALIGNMENT_CENTER, 180.0, 18, UITheme.AMBER.lightened(0.3))


func _show_manual() -> void:
	if _help_modal != null:
		_tut_slide = 0
		_update_tut_slide()
		_help_modal.visible = true
		_help_modal.mouse_filter = Control.MOUSE_FILTER_STOP
		GameState.set_pause_reason("manual", true)


func _close_manual() -> void:
	if _help_modal != null:
		_help_modal.visible = false
		_help_modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GameState.set_pause_reason("manual", false)


func is_manual_open() -> bool:
	return _help_modal != null and _help_modal.visible


func close_manual() -> void:
	_close_manual()


# --- COP31 Diplomatic Summits Modal (2031, 2036, 2041) -----------------------------------

func _build_summit_modal() -> void:
	_summit_modal = Control.new()
	_summit_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_summit_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_summit_modal.visible = false
	_summit_modal.z_index = 30
	add_child(_summit_modal)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.015, 0.025, 0.05, 0.88)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_summit_modal.add_child(backdrop)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(820.0, 520.0)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb: StyleBoxFlat = UITheme.panel_box(UITheme.LINE_AMBER, UITheme.with_alpha(UITheme.BG_PANEL, 0.98), 2, UITheme.with_alpha(UITheme.AMBER, 0.25), 24, 16)
	sb.content_margin_left = 36.0
	sb.content_margin_right = 36.0
	sb.content_margin_top = 30.0
	sb.content_margin_bottom = 30.0
	card.add_theme_stylebox_override("panel", sb)
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -410.0
	card.offset_top = -260.0
	card.offset_right = 410.0
	card.offset_bottom = 260.0
	_summit_modal.add_child(card)

	var col := _vbox(16)
	card.add_child(col)

	var top := _hbox(12)
	col.add_child(top)
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", UITheme.badge_box(UITheme.AMBER))
	var badge_lbl := _label("BadgeLabel", "summit.modal.title")
	badge.add_child(badge_lbl)
	top.add_child(badge)
	top.add_child(_spacer())

	_summit_badge_panel = PanelContainer.new()
	_summit_badge_label = _label("BadgeLabel")
	_summit_badge_panel.add_child(_summit_badge_label)
	top.add_child(_summit_badge_panel)

	col.add_child(_sep())

	_summit_title_label = _label("HeaderLabel")
	_summit_title_label.add_theme_font_size_override("font_size", 22)
	_summit_title_label.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.3))
	col.add_child(_summit_title_label)

	_summit_desc_text = RichTextLabel.new()
	_summit_desc_text.bbcode_enabled = true
	_summit_desc_text.fit_content = false
	_summit_desc_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_summit_desc_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_summit_desc_text.add_theme_font_override("normal_font", UITheme.body_font())
	_summit_desc_text.add_theme_font_size_override("normal_font_size", 16)
	_summit_desc_text.add_theme_color_override("default_color", UITheme.TEXT)
	col.add_child(_summit_desc_text)

	col.add_child(_sep())

	var opt_row := _hbox(18)
	opt_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(opt_row)

	# Option A
	var card_a := PanelContainer.new()
	card_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_a := UITheme.panel_box(UITheme.LINE, UITheme.with_alpha(UITheme.DEEP, 0.8), 1, Color(0,0,0,0), 0, 10)
	sb_a.content_margin_left = 16.0; sb_a.content_margin_right = 16.0
	sb_a.content_margin_top = 14.0; sb_a.content_margin_bottom = 14.0
	card_a.add_theme_stylebox_override("panel", sb_a)
	opt_row.add_child(card_a)
	var col_a := _vbox(8)
	card_a.add_child(col_a)
	_summit_opt_a_title = _label("HeaderLabel")
	_summit_opt_a_title.add_theme_font_size_override("font_size", 16)
	_summit_opt_a_title.add_theme_color_override("font_color", UITheme.HEALTHY)
	col_a.add_child(_summit_opt_a_title)
	_summit_opt_a_desc = _label("SmallLabel")
	_summit_opt_a_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summit_opt_a_desc.custom_minimum_size = Vector2(0.0, 48.0)
	_summit_opt_a_desc.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	col_a.add_child(_summit_opt_a_desc)
	_summit_opt_a_btn = Button.new()
	_summit_opt_a_btn.theme_type_variation = &"PrimaryButton"
	_summit_opt_a_btn.text = I18n.t("summit.btn.ratify")
	_summit_opt_a_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_summit_opt_a_btn.pressed.connect(_on_summit_choice.bind(0))
	col_a.add_child(_summit_opt_a_btn)

	# Option B
	var card_b := PanelContainer.new()
	card_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_b := UITheme.panel_box(UITheme.LINE_AMBER, UITheme.with_alpha(UITheme.DEEP, 0.8), 1, Color(0,0,0,0), 0, 10)
	sb_b.content_margin_left = 16.0; sb_b.content_margin_right = 16.0
	sb_b.content_margin_top = 14.0; sb_b.content_margin_bottom = 14.0
	card_b.add_theme_stylebox_override("panel", sb_b)
	opt_row.add_child(card_b)
	var col_b := _vbox(8)
	card_b.add_child(col_b)
	_summit_opt_b_title = _label("HeaderLabel")
	_summit_opt_b_title.add_theme_font_size_override("font_size", 16)
	_summit_opt_b_title.add_theme_color_override("font_color", UITheme.AMBER)
	col_b.add_child(_summit_opt_b_title)
	_summit_opt_b_desc = _label("SmallLabel")
	_summit_opt_b_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summit_opt_b_desc.custom_minimum_size = Vector2(0.0, 48.0)
	_summit_opt_b_desc.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	col_b.add_child(_summit_opt_b_desc)
	_summit_opt_b_btn = Button.new()
	_summit_opt_b_btn.theme_type_variation = &"SecondaryButton"
	_summit_opt_b_btn.text = I18n.t("summit.btn.ratify")
	_summit_opt_b_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_summit_opt_b_btn.pressed.connect(_on_summit_choice.bind(1))
	col_b.add_child(_summit_opt_b_btn)


func _on_summit_triggered(data: Dictionary) -> void:
	_current_summit_data = data
	_summit_modal.visible = true
	var passed: bool = bool(data.get("success", data.get("passed", true)))
	var badge_col: Color = UITheme.HEALTHY if passed else UITheme.AMBER
	_summit_badge_panel.add_theme_stylebox_override("panel", UITheme.badge_box(badge_col))
	_summit_badge_label.text = I18n.t("summit.status.success" if passed else "summit.status.warning")
	_summit_badge_label.add_theme_color_override("font_color", badge_col)

	_summit_title_label.text = I18n.t(str(data.get("title_key", "")))
	_summit_desc_text.text = I18n.t(str(data.get("desc_key", "")))

	var choices: Array = data.get("choices", [])
	if choices.size() > 0:
		var c0: Dictionary = choices[0]
		_summit_opt_a_title.text = I18n.t(str(c0.get("title_key", "")))
		_summit_opt_a_desc.text = I18n.t(str(c0.get("desc_key", "")))
	else:
		_summit_opt_a_title.text = I18n.t(str(data.get("opt_a_name", "")))
		_summit_opt_a_desc.text = I18n.t(str(data.get("opt_a_desc", "")))

	if choices.size() > 1:
		var c1: Dictionary = choices[1]
		_summit_opt_b_title.text = I18n.t(str(c1.get("title_key", "")))
		_summit_opt_b_desc.text = I18n.t(str(c1.get("desc_key", "")))
	else:
		_summit_opt_b_title.text = I18n.t(str(data.get("opt_b_name", "")))
		_summit_opt_b_desc.text = I18n.t(str(data.get("opt_b_desc", "")))

	AudioSynth.play_policy_adopt()


func _on_summit_choice(choice_idx: int) -> void:
	_summit_modal.visible = false
	GameState.resolve_summit(choice_idx)
	AudioSynth.play_policy_adopt()


func _build_tip() -> void:
	_tip_panel = PanelContainer.new()
	_tip_panel.theme_type_variation = &"TipPanel"
	_tip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip_panel.custom_minimum_size = Vector2(360.0, 0.0)
	_tip_panel.visible = false
	_tip_panel.z_index = 10
	add_child(_tip_panel)
	var col := _vbox(5)
	_tip_panel.add_child(col)
	_tip_title = _label("TipTitleLabel")
	_tip_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_title.custom_minimum_size = Vector2(330.0, 0.0)
	col.add_child(_tip_title)
	_tip_body = RichTextLabel.new()
	_tip_body.bbcode_enabled = true
	_tip_body.fit_content = true
	_tip_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip_body.custom_minimum_size = Vector2(330.0, 0.0)
	_tip_body.add_theme_font_override("normal_font", UITheme.body_font())
	_tip_body.add_theme_font_override("bold_font", UITheme.mono_bold_font())
	_tip_body.add_theme_font_size_override("normal_font_size", 12)
	_tip_body.add_theme_font_size_override("bold_font_size", 12)
	_tip_body.add_theme_color_override("default_color", UITheme.TEXT)
	col.add_child(_tip_body)
	_tip_meta = _label("DimLabel")
	_tip_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_meta.custom_minimum_size = Vector2(330.0, 0.0)
	col.add_child(_tip_meta)


func _show_tip(owner_ctrl: Control, title: String, body: String, meta: String, side: String) -> void:
	_tip_owner = owner_ctrl
	_tip_side = side
	_tip_title.text = title
	_tip_body.text = body
	_tip_body.visible = body != ""
	_tip_meta.text = meta
	_tip_meta.visible = meta != ""
	_tip_panel.size = Vector2(300.0, 40.0)
	_tip_panel.reset_size()
	_tip_panel.visible = true
	_place_tip()
	if _tip_tween != null and _tip_tween.is_valid():
		_tip_tween.kill()
	_tip_panel.modulate.a = 0.0
	_tip_tween = _tip_panel.create_tween()
	_tip_tween.tween_property(_tip_panel, "modulate:a", 1.0, 0.14)


func _place_tip() -> void:
	if _tip_owner == null or not is_instance_valid(_tip_owner):
		return
	var vs: Vector2 = get_viewport_rect().size
	_tip_panel.reset_size()
	var ts: Vector2 = _tip_panel.size
	var op: Vector2 = _tip_owner.global_position
	var osz: Vector2 = _tip_owner.size
	var p := Vector2.ZERO
	if _tip_side == "below":
		p = Vector2(op.x + osz.x * 0.5 - ts.x * 0.5, op.y + osz.y + 10.0)
		if _right_panel != null and _right_panel.visible and (p.x + ts.x > _right_panel.position.x):
			p.x = _right_panel.position.x - ts.x - 14.0
	elif _tip_side == "under_panel":
		# Below the REGION panel, clear of the sea regions (east edge ~x 1465 at 1080p).
		p = Vector2(_right_panel.position.x + (_right_panel.size.x - ts.x) * 0.5, _right_panel.position.y + _right_panel.size.y + 10.0)
	elif _tip_side == "right_of":
		# Next to the BASIN STATUS panel (resistance rows).
		p = Vector2(_left_panel.position.x + _left_panel.size.x + 14.0, op.y)
	else:
		p = Vector2(_right_panel.position.x - ts.x - 14.0, op.y)
	p.x = clampf(p.x, 8.0, vs.x - ts.x - 8.0)
	p.y = clampf(p.y, 8.0, vs.y - ts.y - 8.0)
	_tip_panel.position = p


func _hide_tip(owner_ctrl: Control) -> void:
	if owner_ctrl != _tip_owner:
		return
	_hide_tip_now()


func _hide_tip_now() -> void:
	_tip_owner = null
	if _tip_tween != null and _tip_tween.is_valid():
		_tip_tween.kill()
	_tip_panel.visible = false


func _wire_long_press(ctrl: Control, cb: Callable) -> void:
	if ctrl is BaseButton:
		var b := ctrl as BaseButton
		b.button_down.connect(_on_hold_start.bind(ctrl, cb))
		b.button_up.connect(_on_hold_end.bind(ctrl))
	else:
		ctrl.gui_input.connect(_on_ctrl_hold_input.bind(ctrl, cb))


func _on_ctrl_hold_input(event: InputEvent, ctrl: Control, cb: Callable) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_on_hold_start(ctrl, cb)
			else:
				_on_hold_end(ctrl)


func _on_hold_start(ctrl: Control, cb: Callable) -> void:
	_hold_ctrl = ctrl
	_hold_time = 0.0
	_hold_cb = cb
	_hold_triggered = false


func _on_hold_end(ctrl: Control) -> void:
	if _hold_ctrl == ctrl:
		_hold_ctrl = null
		_hold_time = 0.0
		_hold_cb = Callable()


func _on_speed_hover(btn: Button, index: int) -> void:
	_show_tip(btn, I18n.t(SPEED_KEYS[index]), "", "", "below")


func _on_action_hover(btn: Button, action_id: String) -> void:
	var def: Dictionary = Balance.ACTIONS[action_id]
	var cost: Dictionary = def.get("cost", {})
	var parts := PackedStringArray()
	for ck in RES_ORDER:
		var res_key: String = ck
		if cost.has(res_key):
			parts.append(str(roundi(float(cost[res_key]))) + " " + I18n.t(RES_KEYS[res_key]))
	var meta: String = I18n.t("hud.cost_line", {"list": ", ".join(parts)})
	_show_tip(btn, I18n.t(str(def.get("name_key", ""))), I18n.t(str(def.get("desc_key", ""))), meta, "under_panel")


func _on_res_hover(block: Control, key: String) -> void:
	var title: String = I18n.t(str(RES_KEYS[key]))
	var tip_k: String = "res.%s.tip" % key
	var body: String = I18n.t(tip_k) if I18n.has_key(tip_k) else I18n.t("hud.rate.tip")
	if key == "budget" and _budget_negative:
		body += "\n\n" + I18n.t("hud.rate.tip_negative")
	var meta: String = ""
	if _rate_values.has(key):
		meta = I18n.t("hud.rate.monthly", {"v": _signed(float(_rate_values[key]))})
	_show_tip(block, title, body, meta, "below")


func _on_species_hover(block: Control) -> void:
	var title: String = I18n.t("hud.species.title")
	var body: String = I18n.t("hud.species.body")
	_show_tip(block, title, body, I18n.t("hud.species.tip"), "below")


func _on_defcon_hover(block: Control) -> void:
	var title: String = I18n.t("hud.defcon.title")
	var body: String = I18n.t("hud.defcon." + str(_defcon_level) + ".desc")
	var meta: String = I18n.t("hud.defcon." + str(_defcon_level))
	_show_tip(block, title, body, meta, "below")


func _on_hq_hover(block: Control) -> void:
	var title: String = I18n.t("hud.antalya_hq.title")
	var lim: int = roundi(float(_snap.get("antalya_limit", 85.0)))
	var integ: int = roundi(float(_snap.get("antalya_integrity", 100.0)))
	var body: String = I18n.t("hud.antalya_hq.desc", {"limit": str(lim), "integrity": str(integ)})
	var meta: String = I18n.t("hud.hq.integrity", {"val": str(integ)})
	_show_tip(block, title, body, meta, "below")


func _on_audio_hover(block: Control) -> void:
	var key: String = "hud.btn.mute_on" if AudioSynth.is_muted else "hud.btn.mute_off"
	_show_tip(block, I18n.t(key), "", "", "below")


func _on_help_hover(block: Control) -> void:
	_show_tip(block, I18n.t("hud.btn.help"), "", "", "below")


func _on_audio_toggle() -> void:
	_hide_tip_now()
	AudioSynth.toggle_mute()
	if _audio_icon != null:
		_audio_icon.set_icon("sound_off" if AudioSynth.is_muted else "sound_on", UITheme.TEXT_DIM if AudioSynth.is_muted else UITheme.TEXT, 16.0)


func _on_pause_menu_pressed() -> void:
	_hide_tip_now()
	AudioSynth.play_click()
	EventBus.pause_menu_requested.emit()


func _update_defcon(level: int) -> void:
	_defcon_level = level
	if _defcon_label == null:
		return
	_defcon_label.text = "DEFCON %d" % level
	var c: Color = UITheme.HEALTHY
	match level:
		5: c = UITheme.HEALTHY
		4: c = UITheme.WARNING
		3: c = UITheme.AMBER
		2: c = UITheme.CRISIS.lerp(UITheme.AMBER, 0.4)
		1: c = UITheme.CRISIS
	_defcon_label.add_theme_color_override("font_color", c)
	_defcon_badge.add_theme_stylebox_override("panel", UITheme.badge_box(c))


func _update_antalya_hq(integrity: float, _limit: float) -> void:
	if _antalya_hq_label == null:
		return
	var i_val: int = clampi(roundi(integrity), 0, 100)
	_antalya_hq_label.text = "HQ: %d%%" % i_val
	var c: Color = UITheme.HEALTHY
	if i_val < 35:
		c = UITheme.CRISIS
	elif i_val < 65:
		c = UITheme.AMBER
	_antalya_hq_label.add_theme_color_override("font_color", c)
	_antalya_hq_chip.add_theme_stylebox_override("panel", UITheme.badge_box(c))


func _update_species(turtles: int, seals: int) -> void:
	if _turtle_count != null:
		_turtle_count.text = str(turtles)
	if _seal_count != null:
		_seal_count.text = str(seals)


func _update_difficulty_badge(diff_id: String) -> void:
	if _diff_badge_label == null:
		return
	var d_def: Dictionary = Balance.DIFFICULTIES.get(diff_id, {})
	var badge: String = str(d_def.get("badge", diff_id.to_upper()))
	_diff_badge_label.text = badge


func _on_tree_hover() -> void:
	_show_tip(_tree_btn, I18n.t("hud.tree.button"), I18n.t("hud.tree.tip"), "", "under_panel")


func _on_resist_hover(row: Control, evo_id: String) -> void:
	var def: Dictionary = TechTree.evolution_def(evo_id)
	var desc_key: String = str(def.get("desc_key", ""))
	var body: String = I18n.t(desc_key) if desc_key != "" and I18n.has_key(desc_key) else ""
	_show_tip(row, _evo_name(evo_id), body, _counter_text(evo_id), "right_of")


func _toast_text(text_key: String, args: Dictionary) -> String:
	var shown: Dictionary = {}
	for k in args.keys():
		var v: Variant = args[k]
		if v is String and I18n.has_key(str(v)):
			shown[k] = I18n.t(str(v))
		else:
			shown[k] = v
	return I18n.t(text_key, shown)


func _on_toast(text_key: String, args: Dictionary, severity: int) -> void:
	if not _is_shown:
		return
	var sev: int = clampi(severity, 0, 3)
	var col: Color = UITheme.severity_color(sev)
	var root := MarginContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("margin_left", 40)
	root.add_theme_constant_override("margin_right", 0)
	root.add_theme_constant_override("margin_top", 0)
	root.add_theme_constant_override("margin_bottom", 0)
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"ToastPanel"
	panel.add_theme_stylebox_override("panel", UITheme.stripe_box(col))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(panel)
	var row := _hbox(10)
	panel.add_child(row)
	var icon_ids: Array = ["info", "check", "warning", "crisis"]
	row.add_child(_icon(str(icon_ids[sev]), col, 18.0))
	var l := _label("SmallLabel")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size = Vector2(220.0, 0.0)
	l.text = _toast_text(text_key, args)
	if sev == 3:
		l.add_theme_color_override("font_color", UITheme.CRISIS.lerp(Color.WHITE, 0.5))
	elif sev == 1:
		l.add_theme_color_override("font_color", UITheme.HEALTHY.lerp(Color.WHITE, 0.55))
	row.add_child(l)
	_toast_box.add_child(root)
	root.modulate.a = 0.0
	_toasts.append({"root": root, "label": l, "key": text_key, "args": args})
	while _toasts.size() > MAX_TOASTS:
		var oldest: Dictionary = _toasts[0]
		_drop_toast(oldest["root"])
	_layout_toasts.call_deferred()

	var tw := root.create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(root, "modulate:a", 1.0, 0.3)
	tw.tween_method(_set_toast_margin.bind(root), 40.0, 0.0, 0.4)
	tw.chain().tween_interval(TOAST_LIFE)
	tw.chain().tween_property(root, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(_drop_toast.bind(root))
	if sev >= 2:
		var blink := panel.create_tween()
		blink.set_loops(3 if sev == 3 else 1)
		blink.tween_property(panel, "self_modulate", Color(1.8, 1.8, 1.8, 1.0), 0.08)
		blink.tween_property(panel, "self_modulate", Color.WHITE, 0.22)


func _set_toast_margin(v: float, root: MarginContainer) -> void:
	if is_instance_valid(root):
		root.add_theme_constant_override("margin_left", int(v))


func _drop_toast(root: Control) -> void:
	for i in range(_toasts.size() - 1, -1, -1):
		var rec: Dictionary = _toasts[i]
		if rec["root"] == root:
			_toasts.remove_at(i)
	if is_instance_valid(root):
		root.queue_free()


func _clear_toasts() -> void:
	for rec in _toasts:
		var r: Dictionary = rec
		var node: Control = r["root"]
		if is_instance_valid(node):
			node.queue_free()
	_toasts.clear()


# --- Public API (frozen) --------------------------------------------------------------------

func show_hud() -> void:
	_is_shown = true
	visible = true
	_kill_anim()
	var vs: Vector2 = get_viewport_rect().size
	_top_bar.position.y = -TOP_H - 8.0
	_left_panel.visible = false
	_left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_panel.visible = _selected != ""
	_right_panel.mouse_filter = Control.MOUSE_FILTER_STOP if _selected != "" else Control.MOUSE_FILTER_IGNORE
	var card_h: float = maxf(_right_panel.get_combined_minimum_size().y, 272.0)
	_right_panel.position = Vector2(MARGIN, clampf(vs.y - MARGIN - card_h, TOP_H + 8.0, vs.y - MARGIN - 60.0))
	if _ticker_strip != null:
		_ticker_strip.visible = (_selected == "")
	modulate.a = 0.0
	_anim = create_tween()
	_anim.set_parallel(true)
	_anim.set_trans(Tween.TRANS_CUBIC)
	_anim.set_ease(Tween.EASE_OUT)
	_anim.tween_property(self, "modulate:a", 1.0, 0.4)
	_anim.tween_property(_top_bar, "position:y", 0.0, 0.4)
	_refresh_actions()
	_on_hud_resized()

func hide_hud() -> void:
	_is_shown = false
	_hide_tip_now()
	_kill_anim()
	if not visible:
		return
	_anim = create_tween()
	_anim.set_parallel(true)
	_anim.set_trans(Tween.TRANS_CUBIC)
	_anim.set_ease(Tween.EASE_IN)
	_anim.tween_property(self, "modulate:a", 0.0, 0.35)
	_anim.tween_property(_top_bar, "position:y", -TOP_H - 8.0, 0.35)
	_anim.chain().tween_callback(_finish_hide)

func _finish_hide() -> void:
	if not _is_shown:
		visible = false
		_clear_toasts()


func _kill_anim() -> void:
	if _anim != null and _anim.is_valid():
		_anim.kill()
	_anim = null


# --- EventBus handlers -------------------------------------------------------------------------

func _on_game_started() -> void:
	_clear_toasts()
	_snap = GameState.get_snapshot()
	_update_time_labels()
	_update_sea_temp_pills(_snap)
	_select_region(GameState.selected_region)
	_local_hist.clear()
	_chart.reset_series()
	_rate_values.clear()
	_set_budget_negative(false)
	_neg_ticks = 0
	_pos_ticks = 0
	_neg_warned = false
	_resist_ids.clear()
	_refresh_resistances(false)
	_pressure_branch = ""
	_update_pressure()
	_update_tree_status()
	_update_defcon(5)
	_update_antalya_hq(100.0, float(_snap.get("antalya_limit", 85.0)))
	_update_species(int(_snap.get("turtle_nests", 0)), int(_snap.get("monk_seals", 0)))
	_update_difficulty_badge(str(_snap.get("difficulty", GameState.selected_difficulty)))
	if _audio_icon != null:
		_audio_icon.set_icon("sound_off" if AudioSynth.is_muted else "sound_on", UITheme.TEXT_DIM if AudioSynth.is_muted else UITheme.TEXT, 15.0)
	_start_directives()


func _on_tick_done(snapshot: Dictionary) -> void:
	_snap = snapshot
	_update_time_labels()
	_update_sea_temp_pills(snapshot)
	_update_chart(snapshot)
	_update_rates(snapshot)
	_update_pressure()
	_update_tree_status()
	_update_defcon(int(snapshot.get("defcon", 5)))
	_update_antalya_hq(float(snapshot.get("antalya_integrity", 100.0)), float(snapshot.get("antalya_limit", 85.0)))
	_update_species(int(snapshot.get("turtle_nests", 0)), int(snapshot.get("monk_seals", 0)))
	_update_difficulty_badge(str(snapshot.get("difficulty", GameState.selected_difficulty)))
	_timeline.set_value(float(snapshot.get("progress", 0.0)))
	var sh: float = float(snapshot.get("sea_health", 0.0))
	_sea_bar.set_value(sh)
	_sea_bar.alert = sh < 20.0
	var cr: float = float(snapshot.get("crisis", 0.0))
	_crisis_bar.set_value(cr)
	_crisis_bar.alert = cr >= 75.0
	_aware_bar.set_value(float(snapshot.get("awareness", 0.0)))
	_gauge.set_value(float(snapshot.get("temperature", Charts.TEMP_MIN)))
	_pulse.pulse_health = sh
	_refresh_actions()


func _update_sea_temp_pills(snap: Dictionary) -> void:
	if _sea_pill_label != null:
		var sh: float = float(snap.get("sea_health", 62.0))
		_sea_pill_label.text = "%d%%" % roundi(sh)
		if sh >= 60.0:
			_sea_pill_label.add_theme_color_override("font_color", UITheme.HEALTHY)
		elif sh >= 35.0:
			_sea_pill_label.add_theme_color_override("font_color", UITheme.WARNING)
		else:
			_sea_pill_label.add_theme_color_override("font_color", UITheme.CRISIS)
	if _temp_pill_label != null:
		var temp: float = float(snap.get("temperature", Charts.TEMP_MIN))
		_temp_pill_label.text = "+%.2f°C" % temp
		if temp < 1.8:
			_temp_pill_label.add_theme_color_override("font_color", UITheme.WARNING)
		elif temp < 2.5:
			_temp_pill_label.add_theme_color_override("font_color", UITheme.AMBER)
		else:
			_temp_pill_label.add_theme_color_override("font_color", UITheme.CRISIS)


func _update_time_labels() -> void:
	var y: int = int(_snap.get("year_int", Balance.START_YEAR))
	var m: int = int(_snap.get("month_int", 1))
	var left: int = int(_snap.get("years_left", Balance.END_YEAR - Balance.START_YEAR))
	var m_str: String = "%02d" % m
	_year_label.text = I18n.t("hud.month_fmt", {"year": str(y), "month": m_str})
	_years_left_label.text = I18n.t("hud.years_left", {"n": str(left)})


# --- Phase 2: live chart, net income, resistances, pressure, policy tree ----------------------

func _update_chart(snap: Dictionary) -> void:
	if snap.is_empty():
		return
	var tick: int = int(snap.get("tick", 0))
	var sh: float = float(snap.get("sea_health", 0.0))
	var cr: float = float(snap.get("crisis", 0.0))
	var need_sample: bool = true
	if not _local_hist.is_empty():
		var last: Array = _local_hist[_local_hist.size() - 1]
		var last_tick: int = int(last[0])
		if tick < last_tick:
			_local_hist.clear()
		elif tick - last_tick < HISTORY_EVERY:
			need_sample = false
	if need_sample:
		_local_hist.append([tick, sh, cr])
	var hist: Array = GameState.get_history()
	if hist.is_empty():
		hist = _local_hist
	_chart.set_series(hist, tick, sh, cr)


static func _ticks_per_year() -> float:
	return float(Balance.TOTAL_TICKS) / float(maxi(Balance.END_YEAR - Balance.START_YEAR, 1))


static func _signed(v: float) -> String:
	var a: float = absf(v)
	var body: String = str(roundi(a)) if a >= 9.95 else "%.1f" % a
	if body == "0" or body == "0.0":
		return "0"
	return ("+" if v > 0.0 else "-") + body


## Net income per month beside each resource (snapshot *_rate keys; hidden until the
## simulation provides them). Negative budget income pulses red and warns once.
func _update_rates(snap: Dictionary, count_ticks: bool = true) -> void:
	for k in RES_ORDER:
		var key: String = k
		var rl: Label = _rate_labels[key]
		var sk: String = RATE_KEYS[key]
		if not snap.has(sk):
			rl.visible = false
			_rate_values.erase(key)
			continue
		var per_month: float = float(snap[sk])
		_rate_values[key] = per_month
		rl.visible = true
		rl.text = "(%s)" % I18n.t("hud.rate.monthly", {"v": _signed(per_month)})
		var c: Color = UITheme.TEXT_DIM
		if per_month >= 0.05:
			c = UITheme.HEALTHY.lerp(Color.WHITE, 0.2)
		elif per_month <= -0.05:
			c = UITheme.CRISIS.lerp(Color.WHITE, 0.15)
		rl.add_theme_color_override("font_color", c)
	var neg: bool = _rate_values.has("budget") and float(_rate_values["budget"]) <= -0.05
	_set_budget_negative(neg)
	if not count_ticks:
		return
	if neg:
		_neg_ticks += 1
		_pos_ticks = 0
		if _neg_ticks >= NEG_INCOME_WARN_TICKS and not _neg_warned and _is_shown:
			_neg_warned = true
			EventBus.toast.emit("hud.toast.income_negative", {}, 2)
	else:
		_neg_ticks = 0
		_pos_ticks += 1
		if _pos_ticks >= NEG_INCOME_REARM_TICKS:
			_neg_warned = false


func _set_budget_negative(on: bool) -> void:
	if on == _budget_negative:
		return
	_budget_negative = on
	if not on:
		var bl: Label = _res_labels["budget"]
		bl.self_modulate = Color.WHITE
		var rl: Label = _rate_labels["budget"]
		rl.self_modulate = Color.WHITE
		var ic: Icons = _res_icons["budget"]
		ic.self_modulate = Color.WHITE


func _evo_name(evo_id: String) -> String:
	var def: Dictionary = TechTree.evolution_def(evo_id)
	var nk: String = str(def.get("name_key", ""))
	if nk != "":
		return I18n.t(nk)
	return evo_id


## "Countered by: A, B, C" from the policy nodes that list this evolution in "counters".
func _counter_text(evo_id: String) -> String:
	var names := PackedStringArray()
	for n in TechTree.counters_of(evo_id):
		var node_def: Dictionary = TechTree.node_def(str(n))
		var nk: String = str(node_def.get("name_key", ""))
		if nk == "":
			continue
		if names.size() >= MAX_RESIST_COUNTERS:
			names.append("…")
			break
		names.append(I18n.t(nk))
	if names.is_empty():
		return I18n.t("hud.resist.counter_unknown")
	return I18n.t("hud.resist.counter", {"list": ", ".join(names)})


## Rebuilds the resistance rows from GameState.active_evolutions(); animate marks new ones.
## Shows the newest MAX_RESIST_ROWS, then an "Also active: N" line for the rest.
func _refresh_resistances(animate: bool) -> void:
	if _resist_list == null:
		return
	var ids: Array = GameState.active_evolutions()
	for child in _resist_list.get_children():
		var c: Node = child
		if c != _resist_none and c != _resist_more:
			_resist_list.remove_child(c)
			c.queue_free()
	_resist_none.visible = ids.is_empty()
	var first: int = maxi(0, ids.size() - MAX_RESIST_ROWS)
	for i in range(ids.size() - 1, first - 1, -1):
		var evo_id: String = str(ids[i])
		var fresh: bool = animate and not _resist_ids.has(evo_id)
		_build_resist_row(evo_id, fresh)
	_resist_more.visible = first > 0
	if first > 0:
		_resist_more.text = I18n.t("hud.resist.more", {"n": str(first)})
	_resist_list.move_child(_resist_more, _resist_list.get_child_count() - 1)
	_resist_ids = ids.duplicate()
	_resist_count.text = str(ids.size())
	var bc: Color = UITheme.CRISIS if not ids.is_empty() else UITheme.TEXT_DIM
	_resist_badge.add_theme_stylebox_override("panel", UITheme.badge_box(bc))
	_resist_count.add_theme_color_override("font_color", bc.lerp(Color.WHITE, 0.3))
	call_deferred("_shrink_panels")


func _build_resist_row(evo_id: String, fresh: bool) -> void:
	var def: Dictionary = TechTree.evolution_def(evo_id)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", UITheme.stripe_box(UITheme.CRISIS, 0.7))
	panel.mouse_entered.connect(_on_resist_hover.bind(panel, evo_id))
	panel.mouse_exited.connect(_hide_tip.bind(panel))
	_resist_list.add_child(panel)
	var row := _hbox(10)
	panel.add_child(row)
	var icon_id: String = str(def.get("icon", ""))
	if not Icons.IDS.has(icon_id):
		icon_id = _icon_or("evolution", "crisis")
	row.add_child(_icon(icon_id, UITheme.CRISIS.lerp(Color.WHITE, 0.15), 24.0))
	var txt := _vbox(1)
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(txt)
	var name_l := _label("SmallLabel")
	name_l.add_theme_font_override("font", UITheme.mono_bold_font())
	name_l.add_theme_color_override("font_color", UITheme.CRISIS.lerp(Color.WHITE, 0.45))
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.custom_minimum_size = Vector2(200.0, 0.0)
	name_l.text = _evo_name(evo_id)
	txt.add_child(name_l)
	var hint := _label("DimLabel")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(200.0, 0.0)
	hint.text = _counter_text(evo_id)
	txt.add_child(hint)
	if fresh:
		panel.modulate = Color(2.2, 1.4, 1.4, 0.0)
		var tw := panel.create_tween()
		tw.set_trans(Tween.TRANS_CUBIC)
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "modulate", Color(1.6, 1.0, 1.0, 1.0), 0.25)
		tw.tween_property(panel, "modulate", Color.WHITE, 0.8)


func _branch_evolution_active(branch: String, active: Array) -> bool:
	for e in TechTree.all_evolutions():
		var def: Dictionary = e
		if str(def.get("trigger", "")) == "branch" and str(def.get("branch", "")) == branch and active.has(str(def.get("id", ""))):
			return true
	return false


func _branch_name(branch: String) -> String:
	var key: String = "hud.branch." + branch
	if I18n.has_key(key):
		return I18n.t(key)
	var info: Dictionary = TechTree.BRANCH_INFO.get(branch, {})
	return I18n.t(str(info.get("name_key", key)))


## Warns before a one-sided strategy provokes a resistance (GameState.evolution_pressure()).
func _update_pressure() -> void:
	if _pressure_box == null:
		return
	var p: Dictionary = GameState.evolution_pressure()
	var shares: Dictionary = p.get("shares", {})
	var threshold: float = float(p.get("threshold", 1.0))
	var moves: int = int(p.get("moves", 0))
	var min_moves: int = int(p.get("min_moves", 1))
	var active: Array = GameState.active_evolutions()
	var best_branch: String = ""
	var best: float = 0.0
	for b in shares.keys():
		var branch: String = str(b)
		var share: float = float(shares[b])
		if _branch_evolution_active(branch, active):
			continue
		if share > best:
			best = share
			best_branch = branch
	var need_moves: int = maxi(2, int(ceilf(float(min_moves) * 0.6)))
	var want: bool = GameState.running and best_branch != "" and threshold > 0.0 \
		and moves >= need_moves and best >= threshold * 0.8
	if want:
		_pressure_label.text = I18n.t("hud.pressure.warn", {"branch": _branch_name(best_branch)})
		_pressure_bar.markers = [threshold * 100.0]
		_pressure_bar.set_value(best * 100.0)
		_pressure_bar.alert = best >= threshold
	if want != _pressure_box.visible:
		_pressure_box.visible = want
		if want:
			_pressure_box.modulate = Color(1.8, 1.6, 1.0, 0.0)
			var tw := _pressure_box.create_tween()
			tw.tween_property(_pressure_box, "modulate", Color.WHITE, 0.5)
		call_deferred("_shrink_panels")
	_pressure_branch = best_branch if want else ""


func _count_adoptable() -> int:
	var n: int = 0
	for nd in TechTree.all_nodes():
		var def: Dictionary = nd
		if GameState.can_adopt(str(def.get("id", ""))):
			n += 1
	return n


func _update_tree_status() -> void:
	if _tree_status == null:
		return
	_adoptable = _count_adoptable() if GameState.running else 0
	if _adoptable > 0:
		_tree_status.text = I18n.t("hud.tree.available", {"n": str(_adoptable)})
		_tree_status.add_theme_color_override("font_color", UITheme.HEALTHY.lerp(Color.WHITE, 0.2))
	else:
		_tree_status.text = I18n.t("hud.tree.none")
		_tree_status.add_theme_color_override("font_color", UITheme.TEXT_DIM)


func _on_tree_pressed() -> void:
	_hide_tip_now()
	EventBus.tree_toggle_requested.emit()
	# main.gd may refuse (event card open): keep the button in step with the real state.
	_tree_btn.set_pressed_no_signal(_tree_open)


func _on_tree_toggled(is_open: bool) -> void:
	_tree_open = is_open
	_tree_btn.set_pressed_no_signal(is_open)
	_hide_tip_now()
	if not is_open:
		_update_tree_status()
	if _directive_active and _directive_step == 4 and is_open:
		AudioSynth.play_policy_adopt()
		_set_directive_step(5)


func _on_node_adopted(_node_id: String) -> void:
	_update_tree_status()
	_update_pressure()
	if _directive_active and _directive_step == 4:
		AudioSynth.play_policy_adopt()
		_set_directive_step(5)
	_flash_vignette(UITheme.HEALTHY, 0.40, 1.0)


func _on_evolution_happened(_evolution_id: String) -> void:
	_refresh_resistances(true)
	_update_pressure()
	_resist_flash = 1.0
	_flash_vignette(UITheme.CRISIS, 0.45, 1.2)


func _on_evolution_cured(_evolution_id: String) -> void:
	_refresh_resistances(false)
	_update_pressure()
	_flash_vignette(UITheme.HEALTHY, 0.45, 1.2)


func _on_spread_happened(_from_id: String, _to_id: String) -> void:
	_flash_vignette(UITheme.CRISIS, 0.35, 0.8)


func _on_bubble_collected(_bubble_id: int, kind: String, amount: float) -> void:
	if _directive_active and _directive_step == 3:
		_set_directive_step(4)
	var vs: Vector2 = get_viewport_rect().size
	var pos := Vector2(vs.x * 0.5 - 40.0, vs.y * 0.45)
	var col: Color = RES_COLORS.get(kind, UITheme.HEALTHY)
	var rname: String = I18n.t("hud." + kind) if RES_KEYS.has(kind) else kind.capitalize()
	_spawn_floating_text("+%d %s" % [roundi(amount), rname], col, pos, 45.0, 1.3)


func _on_resources_changed(budget: float, political: float, science: float) -> void:
	var values: Dictionary = {"budget": budget, "political": political, "science": science}
	for k in RES_ORDER:
		var key: String = k
		var nv: float = values[key]
		var old: float = _res_target[key]
		_res_target[key] = nv
		var l: Label = _res_labels[key]
		var diff: float = nv - old
		if nv < old - 0.5:
			_flash_label(l, UITheme.CRISIS)
			if absf(diff) >= 1.0:
				_spawn_floating_text("%d" % roundi(diff), UITheme.CRISIS, l.global_position + Vector2(10.0, 24.0))
		elif nv > old + 4.0:
			_flash_label(l, UITheme.HEALTHY)
			if absf(diff) >= 1.0:
				_spawn_floating_text("+%d" % roundi(diff), UITheme.HEALTHY, l.global_position + Vector2(10.0, 24.0))
	_refresh_actions()


func _flash_label(l: Label, col: Color) -> void:
	l.modulate = col.lerp(Color.WHITE, 0.25)
	var tw := l.create_tween()
	tw.tween_property(l, "modulate", Color.WHITE, 0.6)


func _on_region_selected(region_id: String) -> void:
	_hide_tip_now()
	_select_region(region_id)


func _select_region(region_id: String) -> void:
	_selected = region_id
	if _directive_active and _directive_step == 1 and (region_id == "antalya" or region_id != ""):
		AudioSynth.play_click()
		_set_directive_step(2)
	_region = {}
	if region_id != "":
		_region = GameState.get_region(region_id)
	var has: bool = not _region.is_empty()
	_hint_box.visible = false
	_details.visible = has
	_badge.visible = has
	_region_status = ""
	var vs: Vector2 = get_viewport_rect().size
	if has:
		if _left_panel != null and _left_panel.visible:
			_left_panel.visible = false
			_left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_right_panel.visible = true
		_right_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var card_h: float = maxf(_right_panel.get_combined_minimum_size().y, 272.0)
		_right_panel.position = Vector2(MARGIN, clampf(vs.y - MARGIN - card_h, TOP_H + 8.0, vs.y - MARGIN - 60.0))
		if _ticker_strip != null:
			_ticker_strip.visible = false
		_update_region(_region, true)
		_details.modulate.a = 0.0
		var tw := _details.create_tween()
		tw.tween_property(_details, "modulate:a", 1.0, 0.25)
	else:
		_right_panel.visible = false
		_right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_right_bracket_color = UITheme.TEXT_DIM
		if _ticker_strip != null:
			_ticker_strip.visible = true
	_refresh_actions()
	_right_panel.queue_redraw()
	call_deferred("_shrink_panels")

func _shrink_panels() -> void:
	_right_panel.reset_size()
	_left_panel.reset_size()
	_on_hud_resized()


func _on_hud_resized() -> void:
	var vs: Vector2 = get_viewport_rect().size
	var safe: Vector4 = UITheme.safe_insets(get_viewport())
	var pad_l: float = MARGIN + safe.x
	var pad_r: float = MARGIN + safe.z
	var pad_b: float = MARGIN + safe.w
	if _top_bar != null:
		var tbsb := _top_bar.get_theme_stylebox("panel") as StyleBoxFlat
		if tbsb != null:
			var nsb := tbsb.duplicate() as StyleBoxFlat
			nsb.content_margin_left = 14.0 + safe.x
			nsb.content_margin_right = 14.0 + safe.z
			_top_bar.add_theme_stylebox_override("panel", nsb)
	if _right_panel != null:
		var card_h: float = maxf(_right_panel.get_combined_minimum_size().y, 272.0)
		_right_panel.position = Vector2(pad_l, clampf(vs.y - pad_b - card_h, TOP_H + 8.0, vs.y - pad_b - 60.0))
	if _left_panel != null:
		_left_panel.position = Vector2(pad_l, TOP_H + 10.0)
	if _bottom_right_bar != null:
		_bottom_right_bar.position = Vector2(vs.x - pad_r - 350.0, vs.y - pad_b - 68.0)
	if _ticker_strip != null:
		_ticker_strip.position = Vector2(pad_l, vs.y - pad_b - TICKER_H)
		_ticker_strip.visible = (_selected == "")
	if _directive_box != null:
		var left_bound: float = (pad_l + LEFT_W + 14.0) if (_left_panel != null and _left_panel.visible) else pad_l
		var avail_w: float = maxf(360.0, vs.x - left_bound - pad_r)
		var dw: float = minf(avail_w - 16.0, 680.0)
		_directive_box.custom_minimum_size = Vector2(dw, 0.0)
		if _directive_body_label != null:
			_directive_body_label.custom_minimum_size = Vector2(dw - 36.0, 0.0)
		_directive_box.reset_size()
		_directive_box.position = Vector2(left_bound + (avail_w - dw) * 0.5, TOP_H + 8.0)
	_layout_toasts()

func _on_region_changed(region_id: String, data: Dictionary) -> void:
	if region_id == _selected and _selected != "":
		_update_region(data, false)


func _update_region(data: Dictionary, force: bool) -> void:
	_region = data
	_region_name.text = I18n.t(str(data.get("name_key", "")))
	var st: String = str(data.get("status", "healthy"))
	if st != _region_status or force:
		var changed: bool = _region_status != "" and st != _region_status
		_region_status = st
		var sc: Color = UITheme.status_color(st)
		_badge_label.text = I18n.t("hud.status." + st)
		_badge.add_theme_stylebox_override("panel", UITheme.badge_box(sc))
		_badge_label.add_theme_color_override("font_color", sc.lerp(Color.WHITE, 0.25))
		_right_bracket_color = sc
		_right_panel.queue_redraw()
		if changed:
			_badge.pivot_offset = _badge.size * 0.5
			_badge.scale = Vector2(1.25, 1.25)
			var tw := _badge.create_tween()
			tw.set_trans(Tween.TRANS_BACK)
			tw.set_ease(Tween.EASE_OUT)
			tw.tween_property(_badge, "scale", Vector2.ONE, 0.35)
	var h_val := roundi(float(data.get("coral_health", 50.0)))
	var c_val := roundi(float(data.get("crisis", 0.0)))
	if _region_hc_label != null:
		_region_hc_label.text = I18n.t("hud.region.health_crisis_fmt", {"health": str(h_val), "crisis": str(c_val)})
	_region_crisis_bar.set_value(float(data.get("crisis", 0.0)))
	_region_crisis_bar.alert = st == "collapsed"
	for k in _stat_bars.keys():
		var key: String = k
		var bar: Charts = _stat_bars[key]
		bar.set_value(float(data.get(key, 0.0)))
	if _coastal_value != null:
		_coastal_value.text = I18n.t("fmt.pct", {"v": str(roundi(float(data.get("coastal_pop", 0.0)) * 100.0))})

	var trait_k: String = str(data.get("trait_key", ""))
	if trait_k != "" and I18n.has_key(trait_k):
		if _region_trait_label != null:
			_region_trait_label.text = I18n.t("hud.region.problem_fmt", {"trait": I18n.t(trait_k)})
		if _region_trait_box != null:
			_region_trait_box.visible = true
	else:
		if _region_trait_box != null:
			_region_trait_box.visible = false

	# Biodiversity species for this region
	var rid: String = str(data.get("id", _selected))
	if rid in ["antalya", "aegean"]:
		_region_species_badge.visible = true
		_region_species_icon.set_icon("turtle", UITheme.HEALTHY, 14.0)
		var nests: int = int(_snap.get("turtle_nests", 0))
		_region_species_label.text = I18n.t("hud.species.caretta_nests", {"n": str(nests)})
	elif rid in ["marmara", "adriatic"]:
		_region_species_badge.visible = true
		_region_species_icon.set_icon("seal", UITheme.SCIENCE_BLUE, 14.0)
		var seals: int = int(_snap.get("monk_seals", 0))
		_region_species_label.text = I18n.t("hud.species.monk_seals", {"n": str(seals)})
	else:
		_region_species_badge.visible = false

	# Monthly Dynamics Net Trend Badge
	var bd: Dictionary = data.get("breakdown", {})
	if not bd.is_empty():
		_region_trend_badge.visible = true
		var net_val: float = float(bd.get("net", 0.0))
		var is_improving: bool = net_val <= -0.05
		var is_worsening: bool = net_val > 0.05
		var col_hint: Color = UITheme.HEALTHY if is_improving else (UITheme.CRISIS if is_worsening else UITheme.TEXT_DIM)
		var sign_str: String = "+" if net_val > 0.0 else ""
		var rate_str: String = I18n.t("hud.rate.monthly", {"v": sign_str + ("%.1f" % net_val)})
		_region_trend_label.text = I18n.t("hud.trend.fmt", {"trend": rate_str})
		_region_trend_label.add_theme_color_override("font_color", col_hint)
		_region_trend_icon.set_icon("trend_down" if is_improving else "trend_up", col_hint, 13.0)
		_region_trend_badge.add_theme_stylebox_override("panel", UITheme.badge_box(col_hint))
	else:
		_region_trend_badge.visible = false


func _on_trend_hover() -> void:
	if _region.is_empty():
		return
	var bd: Dictionary = _region.get("breakdown", {})
	var lines: Array = [
		I18n.t("hud.trend.tip"),
		"",
		"%s: +%.1f" % [I18n.t("hud.breakdown.shipping"), float(bd.get("shipping", 0.0))],
		"%s: +%.1f" % [I18n.t("hud.breakdown.currents"), float(bd.get("currents", 0.0))],
		"%s: +%.1f" % [I18n.t("hud.breakdown.coastal"), float(bd.get("coastal", 0.0))],
		"%s: +%.1f" % [I18n.t("hud.breakdown.heat"), float(bd.get("heat", 0.0))],
		"%s: -%.1f" % [I18n.t("hud.breakdown.shield"), float(bd.get("shield", 0.0))],
	]
	_show_tip(_region_trend_badge, I18n.t("hud.breakdown.title"), "\n".join(lines), "", "left_of")


func _refresh_actions() -> void:
	var has_region: bool = _selected != "" and GameState.running and not _region.is_empty()
	for r in _action_rows:
		var row: Dictionary = r
		var id: String = row["id"]
		var btn: Button = row["button"]
		var status_l: Label = row["status"]
		var ic: Icons = row["icon"]
		var cd_fill: ColorRect = row["cd"]
		var cd_left: float = 0.0
		var cd_frac: float = 0.0
		if has_region:
			cd_left = GameState.action_cooldown_left(id, _selected)
			# action_cooldown_left() is in 1x seconds; show real seconds at 2x / 4x.
			var mult: float = Balance.SPEEDS[GameState.speed_index]
			if mult > 0.0:
				cd_left /= mult
			cd_frac = GameState.action_cooldown_fraction(id, _selected)
		var afford: bool = GameState.can_afford(id)
		var can: bool = has_region and GameState.can_perform(id, _selected)
		var key: String = "hud.action.ready"
		var args: Dictionary = {}
		var scol: Color = UITheme.HEALTHY
		if not has_region:
			key = "hud.action.select_region"
			scol = UITheme.TEXT_DIM
		elif cd_left > 0.0:
			key = "hud.action.cooldown"
			args = {"n": str(ceili(cd_left))}
			scol = UITheme.AMBER
		elif not afford:
			key = "hud.action.no_funds"
			scol = UITheme.CRISIS
		elif not can:
			key = "hud.action.unavailable"
			scol = UITheme.TEXT_DIM
		status_l.text = I18n.t(key, args)
		status_l.add_theme_color_override("font_color", scol)
		if btn.disabled == can:
			btn.disabled = not can
			if btn.disabled:
				UITheme.reset_fx(btn)
		ic.color = UITheme.HEALTHY if can else UITheme.with_alpha(UITheme.TEXT_DIM, 0.55)
		var cap: PanelContainer = row["keycap"]
		if cap != null:
			cap.modulate.a = 1.0 if can else 0.4
		cd_fill.anchor_right = clampf(cd_frac, 0.0, 1.0)
		var cost: Dictionary = GameState.action_cost(id)
		var cost_labels: Dictionary = row["cost"]
		for ck in cost_labels.keys():
			var res_key: String = ck
			var cl: Label = cost_labels[res_key]
			var need: float = float(cost.get(res_key, 0.0))
			var have: float = float(_res_target.get(res_key, 0.0))
			var base: Color = RES_COLORS[res_key]
			cl.add_theme_color_override("font_color", base if have >= need else UITheme.CRISIS)


func _on_action_pressed(action_id: String) -> void:
	_hide_tip_now()   # never leave the tip over the map while the action pulse plays
	if _selected == "":
		return
	GameState.perform_action(action_id, _selected)


func _on_action_performed(action_id: String, region_id: String) -> void:
	if _directive_active and _directive_step == 2 and action_id == "cleanup":
		GameState.spawn_tutorial_bubble("science", "antalya")
		_set_directive_step(3)
	if region_id != _selected:
		return
	for r in _action_rows:
		var row: Dictionary = r
		if str(row["id"]) != action_id:
			continue
		var btn: Button = row["button"]
		btn.self_modulate = Color(0.7, 1.9, 1.7, 1.0)
		var tw := btn.create_tween()
		tw.tween_property(btn, "self_modulate", Color.WHITE, 0.6)
		var bpos: Vector2 = btn.global_position + Vector2(24.0, -8.0)
		var def: Dictionary = Balance.ACTIONS.get(action_id, {})
		var act_name: String = I18n.t(str(def.get("name_key", action_id)))
		_spawn_floating_text(act_name, UITheme.HEALTHY, bpos, 35.0, 1.1)
	_right_bracket_color = UITheme.HEALTHY
	_right_panel.queue_redraw()


func _on_speed_pressed(index: int) -> void:
	_hide_tip_now()
	if not GameState.running:
		_on_speed_changed(GameState.speed_index)
		return
	if index == 0 and GameState.speed_index == 0:
		GameState.toggle_pause()
	else:
		GameState.set_speed(index)
	_on_speed_changed(GameState.speed_index)


func _on_speed_changed(speed_index: int) -> void:
	for i in _speed_buttons.size():
		var btn: Button = _speed_buttons[i]
		var active: bool = i == speed_index
		btn.set_pressed_no_signal(active)
		var accent: Color = UITheme.WARNING if i == 0 else UITheme.HEALTHY
		var fg: Color = accent.lerp(Color.WHITE, 0.35) if active else UITheme.TEXT_DIM.lerp(UITheme.TEXT, 0.35)
		if active:
			var act_sb: StyleBoxFlat = UITheme.panel_box(accent, UITheme.with_alpha(UITheme.BG_PANEL.lerp(accent, 0.42), 0.96), 2, UITheme.with_alpha(accent, 0.45), 10, 8)
			act_sb.content_margin_left = 10.0
			act_sb.content_margin_right = 10.0
			act_sb.content_margin_top = 6.0
			act_sb.content_margin_bottom = 6.0
			btn.add_theme_stylebox_override("normal", act_sb)
			btn.add_theme_stylebox_override("pressed", act_sb)
			btn.add_theme_stylebox_override("hover", act_sb)
			btn.add_theme_stylebox_override("hover_pressed", act_sb)
		else:
			btn.remove_theme_stylebox_override("normal")
			btn.remove_theme_stylebox_override("pressed")
			btn.remove_theme_stylebox_override("hover")
			btn.remove_theme_stylebox_override("hover_pressed")
		if i < _speed_icons.size():
			var ic: Icons = _speed_icons[i]
			if ic != null:
				ic.color = fg
				ic.queue_redraw()
		if i < _speed_labels.size():
			var lbl: Label = _speed_labels[i]
			if lbl != null:
				lbl.add_theme_color_override("font_color", fg)
	_chip_on = speed_index == 0 and GameState.running
	if speed_index >= 1:
		if _directive_active and _directive_step == 5:
			_complete_directives()


func _on_paused_changed(paused: bool) -> void:
	_on_speed_changed(GameState.speed_index)
	if not paused and GameState.speed_index >= 1:
		if _directive_active and _directive_step == 5:
			_complete_directives()


func _on_language_changed(_lang: String) -> void:
	for pair in _tr_labels:
		var p: Array = pair
		var l: Label = p[0]
		var key: String = p[1]
		if is_instance_valid(l):
			l.text = I18n.t(key)
	_update_time_labels()
	if not _region.is_empty():
		_update_region(_region, true)
	for r in _action_rows:
		var row: Dictionary = r
		var name_l: Label = row["name"]
		name_l.text = I18n.t(str(row["name_key"]))
	_refresh_actions()
	for rec in _toasts:
		var t: Dictionary = rec
		var tl: Label = t["label"]
		if is_instance_valid(tl):
			tl.text = _toast_text(str(t["key"]), t["args"])
	_update_rates(_snap, false)
	_refresh_resistances(false)
	_update_pressure()
	_update_tree_status()
	_update_defcon(_defcon_level)
	_update_difficulty_badge(str(_snap.get("difficulty", GameState.selected_difficulty)))
	if _directive_active:
		_update_directive_ui()
	_hide_tip_now()
	call_deferred("_shrink_panels")


# --- Per-frame juice ----------------------------------------------------------------------------

func _process(delta: float) -> void:
	_time += delta
	if not visible:
		return
	if _hold_ctrl != null and is_instance_valid(_hold_ctrl) and not _hold_triggered:
		_hold_time += delta
		if _hold_time >= 0.30:
			_hold_triggered = true
			GameState.vibrate_light()
			if _hold_cb.is_valid():
				_hold_cb.call()
	for k in RES_ORDER:
		var key: String = k
		var shown: float = _res_shown[key]
		var target: float = _res_target[key]
		if absf(shown - target) > 0.01:
			shown = lerpf(shown, target, 1.0 - exp(-delta * 6.0))
			if absf(shown - target) < 0.5:
				shown = target
			_res_shown[key] = shown
			var l: Label = _res_labels[key]
			l.text = str(roundi(shown))
	if int(_time * 15.0) != int((_time - delta) * 15.0):
		_ticker_strip.queue_redraw()
	if _tick_bar != null:
		_tick_bar.value = GameState.tick_progress()
		if _tick_bar_fill != null:
			var tcol: Color = UITheme.WARNING if GameState.is_paused() else UITheme.HEALTHY
			_tick_bar_fill.bg_color = UITheme.with_alpha(tcol, 0.85)
			_tick_bar_fill.border_color = tcol
	_paused_chip.modulate.a = (0.55 + 0.45 * (0.5 + 0.5 * sin(_time * 5.0))) if _chip_on else 0.0
	_live_dot.modulate.a = 0.35 + 0.65 * (0.5 + 0.5 * sin(_time * 3.0))
	if _hint_box.visible:
		_hint_icon.pivot_offset = _hint_icon.size * 0.5
		_hint_icon.rotation = _time * 0.8
		_hint_icon.scale = Vector2.ONE * (1.0 + 0.08 * sin(_time * 3.0))
	if _region_status == "critical" or _region_status == "collapsed":
		_badge.modulate.a = 0.6 + 0.4 * (0.5 + 0.5 * sin(_time * 6.0))
		_right_panel.queue_redraw()
	else:
		_badge.modulate.a = 1.0
	if _tip_panel.visible:
		_place_tip()
	_guard_toasts()
	if _vignette != null and _vignette_alpha > 0.0:
		_vignette.queue_redraw()
	if _directive_active:
		_directive_pulse_time += delta
		if _directive_overlay != null:
			_directive_overlay.queue_redraw()
	_process_phase2(delta)


## Death-spiral pulse on the budget, attention pulses for resistances, pressure and the tree.
func _process_phase2(delta: float) -> void:
	var wave: float = 0.5 + 0.5 * sin(_time * 6.5)
	if _budget_negative:
		var hot := Color(1.0, 0.42, 0.38, 1.0)
		var bl: Label = _res_labels["budget"]
		bl.self_modulate = Color.WHITE.lerp(hot, 0.35 + 0.65 * wave)
		var rl: Label = _rate_labels["budget"]
		rl.self_modulate = Color(1.0, 1.0, 1.0, 0.55 + 0.45 * wave)
		var ic: Icons = _res_icons["budget"]
		ic.self_modulate = Color.WHITE.lerp(Color(1.6, 0.45, 0.4, 1.0), wave)
	if _resist_flash > 0.0:
		_resist_flash = maxf(0.0, _resist_flash - delta * 0.6)
		var f: float = _resist_flash * (0.5 + 0.5 * sin(_time * 14.0))
		_resist_title.self_modulate = Color.WHITE.lerp(Color(1.6, 0.5, 0.45, 1.0), f)
		_resist_icon.scale = Vector2.ONE * (1.0 + 0.3 * f)
		_resist_icon.pivot_offset = _resist_icon.size * 0.5
	else:
		_resist_title.self_modulate = Color.WHITE
		_resist_icon.scale = Vector2.ONE
	if _pressure_box.visible:
		_pressure_icon.self_modulate = Color(1.0, 1.0, 1.0, 0.45 + 0.55 * wave)
	if _adoptable > 0 and not _tree_open:
		var glow: float = 0.5 + 0.5 * sin(_time * 3.2)
		_tree_icon.self_modulate = Color.WHITE.lerp(Color(1.5, 1.35, 1.0, 1.0), glow)
	else:
		_tree_icon.self_modulate = Color.WHITE
