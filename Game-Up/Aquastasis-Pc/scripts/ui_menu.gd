extends Control
## UIMenu: cinematic main menu over the live map, pause menu and win/lose screen, all built
## in code with fade/slide Tweens and live language switching. Emits intent signals only;
## main.gd owns the game flow.

signal start_requested()
signal continue_requested()
signal resume_requested()
signal restart_requested()
signal main_menu_requested()
signal quit_requested()

const UITheme := preload("res://scripts/ui_theme.gd")
const Icons := preload("res://scripts/icons.gd")
const Charts := preload("res://scripts/charts.gd")
const RegionData := preload("res://scripts/region.gd")

const BAND_H := 36.0
const COLUMN_W := 960.0
const COLUMN_X := 52.0
const TITLE_MAX_SIZE := 62
const END_KEYS := {
	"win_health": ["end.win.title", "end.win.health.text"],
	"win_crisis": ["end.win.title", "end.win.crisis.text"],
	"lose_temperature": ["end.lose.temperature.title", "end.lose.temperature.text"],
	"lose_health": ["end.lose.health.title", "end.lose.health.text"],
	"lose_resources": ["end.lose.resources.title", "end.lose.resources.text"],
	"lose_hq": ["end.lose.hq.title", "end.lose.hq.text"],
	"lose_time": ["end.lose.time.title", "end.lose.time.text"],
}

var _mode: String = ""   # "", "main", "pause", "end"
var _tr_labels: Array = []     # [[Label, key]]
var _tr_buttons: Array = []    # [[Button, key]]
var _lang_buttons: Array = []  # [[Button, code]]
var _time: float = 0.0
var _anim: Tween = null
var _title_anim: Tween = null

# Main menu
var _main_root: Control
var _main_overlay: Control
var _main_margin: MarginContainer
var _main_items: Array = []
var _title_ctrl: Control
var _title_reveal: float = 1.0
var _title_spacing: float = 6.0
var _band_t: float = 1.0
var _rule: ColorRect
var _pulse: Charts
var _clock_label: Label
var _diff_buttons: Dictionary = {}
var _diff_desc_label: Label = null
var _continue_btn: Button = null
var _ach_chips: Dictionary = {}
var _end_ach_chips: Dictionary = {}
var _end_grade_badge: PanelContainer = null
var _end_grade_label: Label = null
var _end_chart: Charts = null
var _audio_sliders: Array[HSlider] = []
var _audio_pct_labels: Array[Label] = []
var _audio_mute_buttons: Array[Button] = []
var _audio_icons: Array[Icons] = []

# Pause menu
var _pause_root: Control
var _pause_panel: PanelContainer

# Achievements & Settings Modals (accessible from Main Menu & Pause/Esc Menu)
var _ach_modal: Control = null
var _ach_sub_label: Label = null
var _ach_diff_tabs: Dictionary = {}
var _ach_rows: Dictionary = {}
var _ach_view_diff: String = "commander"

var _settings_modal: Control = null
var _gfx_buttons: Dictionary = {}
var _fps_buttons: Dictionary = {}
var _haptic_buttons: Dictionary = {}

# HQ Selection Modal (after difficulty selection)
var _hq_modal: Control = null
var _hq_cards: Dictionary = {}
var _hq_title_label: Label = null
var _hq_sub_label: Label = null

# End screen
var _end_root: Control
var _end_overlay: ColorRect
var _end_panel: PanelContainer
var _end_icon: Icons
var _end_title: Label
var _end_text: Label
var _end_stat_labels: Array = []
var _end_won: bool = false
var _end_reason: String = ""
var _end_stats: Dictionary = {}
var _end_progress: float = 1.0
var _end_pulse: Charts


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = UITheme.build_theme()
	_build_main()
	_build_pause()
	_build_end()
	_build_achievements_modal()
	_build_settings_modal()
	_build_hq_modal()
	_main_root.visible = false
	_pause_root.visible = false
	_end_root.visible = false
	_ach_modal.visible = false
	_settings_modal.visible = false
	_hq_modal.visible = false
	visible = false
	EventBus.language_changed.connect(_on_language_changed)
	EventBus.achievement_unlocked.connect(func(_id: String) -> void: _sync_achievements())
	AudioSynth.volume_changed.connect(func(_v: float) -> void: _sync_audio_controls())
	AudioSynth.mute_changed.connect(func(_m: bool) -> void: _sync_audio_controls())


# --- Builders ----------------------------------------------------------------------------

func _full_rect(parent: Control, filter: int) -> Control:
	var c := Control.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = filter
	parent.add_child(c)
	return c


func _label(variation: String, key: String = "") -> Label:
	var l := Label.new()
	l.theme_type_variation = StringName(variation)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if key != "":
		_tr_labels.append([l, key])
		l.text = I18n.t(key)
	return l


func _icon(id: String, col: Color, px: float) -> Icons:
	var ic: Icons = Icons.new()
	ic.setup(id, col, px)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return ic


func _hbox(sep: int) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_constant_override("separation", sep)
	return b


func _vbox(sep: int) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_constant_override("separation", sep)
	return b


## Themed button with translated text and a vector icon pinned to its left edge.
func _button(variation: String, icon_id: String, key: String, min_size: Vector2, icon_col: Color) -> Button:
	var btn := Button.new()
	btn.theme_type_variation = StringName(variation)
	btn.custom_minimum_size = min_size
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = I18n.t(key)
	btn.clip_text = false
	_tr_buttons.append([btn, key])
	btn.mouse_entered.connect(_on_btn_hover.bind(btn, true))
	btn.mouse_exited.connect(_on_btn_hover.bind(btn, false))
	btn.button_down.connect(_on_btn_down.bind(btn))
	if icon_id != "":
		var px: float = clampf(min_size.y * 0.42, 16.0, 26.0)
		var ic := _icon(icon_id, icon_col, px)
		ic.anchor_left = 0.0
		ic.anchor_right = 0.0
		ic.anchor_top = 0.5
		ic.anchor_bottom = 0.5
		ic.offset_left = 16.0
		ic.offset_right = 16.0 + px
		ic.offset_top = -px * 0.5
		ic.offset_bottom = px * 0.5
		btn.add_child(ic)
		btn.add_theme_constant_override("h_separation", 8)
		var pad_left: float = 20.0 + px + 8.0
		var th: Theme = UITheme.build_theme()
		for st_name in ["normal", "hover", "pressed", "disabled", "focus"]:
			var base_sb: StyleBox = th.get_stylebox(st_name, StringName(variation))
			if base_sb == null:
				base_sb = th.get_stylebox(st_name, &"Button")
			if base_sb is StyleBoxFlat:
				var sb_copy := (base_sb as StyleBoxFlat).duplicate() as StyleBoxFlat
				sb_copy.content_margin_left = pad_left
				btn.add_theme_stylebox_override(st_name, sb_copy)
	return btn


func _on_btn_hover(btn: BaseButton, on: bool) -> void:
	UITheme.hover_fx(btn, on)


func _on_btn_down(btn: BaseButton) -> void:
	UITheme.press_fx(btn)


func _lang_row(parent: Control) -> void:
	var row := _hbox(8)
	parent.add_child(row)
	row.add_child(_icon("globe", UITheme.HEALTHY, 20.0))
	var l := _label("DimLabel", "ui.menu.language")
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.custom_minimum_size = Vector2(0.0, 0.0)
	row.add_child(l)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(6.0, 0.0)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	for c in I18n.LANGS:
		var code: String = c
		var b := Button.new()
		b.theme_type_variation = &"ChipButton"
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.text = I18n.lang_name(code)
		b.custom_minimum_size = Vector2(114.0, 56.0)
		b.mouse_entered.connect(_on_btn_hover.bind(b, true))
		b.mouse_exited.connect(_on_btn_hover.bind(b, false))
		b.button_down.connect(_on_btn_down.bind(b))
		b.pressed.connect(_on_lang_pressed.bind(code))
		row.add_child(b)
		_lang_buttons.append([b, code])
	_sync_lang_buttons()


func _sync_lang_buttons() -> void:
	for pair in _lang_buttons:
		var p: Array = pair
		var b: Button = p[0]
		var code: String = p[1]
		b.set_pressed_no_signal(code == I18n.lang)
		b.text = I18n.lang_name(code)


func _audio_row(parent: Control) -> void:
	var row := _hbox(10)
	parent.add_child(row)

	var ic: Icons = _icon("sound_on" if not AudioSynth.is_muted else "sound_off", UITheme.HEALTHY, 20.0)
	row.add_child(ic)
	_audio_icons.append(ic)

	var l := _label("DimLabel", "ui.menu.audio")
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.value = 0.0 if AudioSynth.is_muted else AudioSynth.master_volume * 100.0
	slider.custom_minimum_size = Vector2(180.0, 36.0)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var track := StyleBoxFlat.new()
	track.bg_color = UITheme.with_alpha(UITheme.LINE_DIM, 0.6)
	track.corner_radius_top_left = 4
	track.corner_radius_top_right = 4
	track.corner_radius_bottom_left = 4
	track.corner_radius_bottom_right = 4
	track.content_margin_top = 6.0
	track.content_margin_bottom = 6.0

	var fill := StyleBoxFlat.new()
	fill.bg_color = UITheme.HEALTHY
	fill.corner_radius_top_left = 4
	fill.corner_radius_bottom_left = 4
	fill.content_margin_top = 6.0
	fill.content_margin_bottom = 6.0

	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)

	slider.value_changed.connect(_on_volume_slider_changed)
	row.add_child(slider)
	_audio_sliders.append(slider)

	var pct_lbl := _label("SmallLabel")
	pct_lbl.add_theme_font_override("font", UITheme.mono_bold_font())
	pct_lbl.add_theme_font_size_override("font_size", 18)
	pct_lbl.custom_minimum_size = Vector2(54.0, 0.0)
	pct_lbl.text = "%d%%" % roundi(slider.value)
	row.add_child(pct_lbl)
	_audio_pct_labels.append(pct_lbl)

	var mute_btn := Button.new()
	mute_btn.theme_type_variation = &"ChipButton"
	mute_btn.custom_minimum_size = Vector2(116.0, 56.0)
	mute_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mute_btn.text = I18n.t("ui.audio.mute_on" if AudioSynth.is_muted else "ui.audio.mute_off")
	mute_btn.pressed.connect(_on_mute_btn_pressed)
	row.add_child(mute_btn)
	_audio_mute_buttons.append(mute_btn)


func _on_volume_slider_changed(val: float) -> void:
	AudioSynth.set_volume(val / 100.0)
	_sync_audio_controls()


func _on_mute_btn_pressed() -> void:
	AudioSynth.toggle_mute()
	_sync_audio_controls()


func _sync_audio_controls() -> void:
	var vol_pct: int = 0 if AudioSynth.is_muted else roundi(AudioSynth.master_volume * 100.0)
	var is_m: bool = AudioSynth.is_muted
	for s in _audio_sliders:
		s.set_value_no_signal(float(vol_pct))
	for p in _audio_pct_labels:
		p.text = "%d%%" % vol_pct
	for b in _audio_mute_buttons:
		b.text = I18n.t("ui.audio.mute_on" if is_m else "ui.audio.mute_off")
	for ic in _audio_icons:
		ic.set_icon("sound_off" if is_m else "sound_on", UITheme.TEXT_DIM if is_m else UITheme.HEALTHY, 20.0)


func _bracket_draw(panel: Control, col: Color) -> void:
	UITheme.draw_brackets(panel, Rect2(Vector2(-6.0, -6.0), panel.size + Vector2(12.0, 12.0)), col, 22.0, 2.0)


# --- Main menu ---------------------------------------------------------------------------

func _build_main() -> void:
	_main_root = _full_rect(self, Control.MOUSE_FILTER_STOP)
	_main_overlay = _full_rect(_main_root, Control.MOUSE_FILTER_IGNORE)
	_main_overlay.draw.connect(_draw_main_overlay)

	_main_margin = MarginContainer.new()
	_main_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_main_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_margin.add_theme_constant_override("margin_left", int(COLUMN_X))
	_main_margin.add_theme_constant_override("margin_top", int(BAND_H + 14.0))
	_main_margin.add_theme_constant_override("margin_bottom", int(BAND_H + 14.0))
	_main_margin.add_theme_constant_override("margin_right", 0)
	_main_root.add_child(_main_margin)
	var col := _vbox(8)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.custom_minimum_size = Vector2(COLUMN_W, 0.0)
	_main_margin.add_child(col)

	var top_row := _hbox(14)
	col.add_child(top_row)
	_pulse = Charts.new()
	_pulse.setup_pulse(Vector2(220.0, 28.0))
	_pulse.pulse_health = 38.0
	top_row.add_child(_pulse)
	var coords := _label("DimLabel")
	coords.text = "00.0000° N · 165.0000° E · GLOBAL OCEAN"
	coords.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	coords.add_theme_color_override("font_color", UITheme.with_alpha(UITheme.HEALTHY, 0.8))
	top_row.add_child(coords)
	_main_items.append(top_row)

	var title_row := _hbox(16)
	title_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	col.add_child(title_row)
	var logo_vec := _icon("aquastasis_logo", UITheme.HEALTHY, 82.0)
	title_row.add_child(logo_vec)

	_title_ctrl = Control.new()
	_title_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_ctrl.custom_minimum_size = Vector2(COLUMN_W - 110.0, 78.0)
	_title_ctrl.draw.connect(_draw_title)
	title_row.add_child(_title_ctrl)

	_rule = ColorRect.new()
	_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rule.color = UITheme.HEALTHY
	_rule.custom_minimum_size = Vector2(560.0, 3.0)
	_rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(_rule)

	var emblem_badge := PanelContainer.new()
	emblem_badge.theme_type_variation = &"BadgePanel"
	emblem_badge.add_theme_stylebox_override("panel", UITheme.badge_box(UITheme.HEALTHY))
	emblem_badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	emblem_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sub := _label("HeaderLabel", "game.emblem_subtitle")
	sub.add_theme_font_size_override("font_size", 19)
	sub.add_theme_color_override("font_color", UITheme.HEALTHY.lerp(Color.WHITE, 0.25))
	emblem_badge.add_child(sub)
	col.add_child(emblem_badge)
	_main_items.append(emblem_badge)

	var tag := _label("BodyLabel", "ui.menu.tagline")
	tag.add_theme_font_size_override("font_size", 22)
	tag.add_theme_color_override("font_color", UITheme.TEXT)
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.custom_minimum_size = Vector2(880.0, 0.0)
	tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(tag)
	_main_items.append(tag)

	var brief_box := _hbox(12)
	col.add_child(brief_box)
	var brief_line := ColorRect.new()
	brief_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brief_line.color = UITheme.with_alpha(UITheme.HEALTHY, 0.6)
	brief_line.custom_minimum_size = Vector2(3.0, 0.0)
	brief_box.add_child(brief_line)
	var brief := _label("BodyDimLabel", "ui.menu.briefing")
	brief.add_theme_font_size_override("font_size", 18)
	brief.add_theme_color_override("font_color", UITheme.TEXT.lerp(UITheme.TEXT_DIM, 0.35))
	brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	brief.max_lines_visible = 2
	brief.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	brief.custom_minimum_size = Vector2(820.0, 0.0)
	brief_box.add_child(brief)
	_main_items.append(brief_box)

	# Difficulty Selection Box
	var diff_box := _vbox(6)
	col.add_child(diff_box)
	var diff_title := _label("DimLabel", "diff.title")
	diff_title.add_theme_font_size_override("font_size", 18)
	diff_box.add_child(diff_title)

	var diff_row := _hbox(12)
	diff_box.add_child(diff_row)

	_diff_buttons.clear()
	for d_id in ["cadet", "commander", "admiral"]:
		var d_def: Dictionary = Balance.DIFFICULTIES[d_id]
		var btn := Button.new()
		btn.theme_type_variation = &"ChipButton"
		btn.custom_minimum_size = Vector2(200.0, 52.0)
		btn.text = I18n.t(str(d_def.get("name_key", d_id)))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(_on_diff_selected.bind(d_id))
		diff_row.add_child(btn)
		_diff_buttons[d_id] = btn

	_diff_desc_label = _label("SmallLabel")
	_diff_desc_label.add_theme_font_size_override("font_size", 18)
	_diff_desc_label.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	_diff_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_diff_desc_label.custom_minimum_size = Vector2(760.0, 26.0)
	diff_box.add_child(_diff_desc_label)
	_update_diff_selection(GameState.selected_difficulty)
	_main_items.append(diff_box)

	var buttons := _hbox(12)
	col.add_child(buttons)
	_continue_btn = _button("PrimaryButton", "play", "ui.menu.continue", Vector2(220.0, 60.0), UITheme.AMBER)
	_continue_btn.pressed.connect(_on_continue_pressed)
	_continue_btn.visible = false
	buttons.add_child(_continue_btn)
	var start := _button("PrimaryButton", "play", "ui.menu.start", Vector2(220.0, 60.0), UITheme.HEALTHY)
	start.pressed.connect(_on_start_pressed)
	buttons.add_child(start)
	var ach_btn := _button("Button", "cop_summit", "ui.menu.achievements", Vector2(220.0, 60.0), UITheme.AMBER)
	ach_btn.pressed.connect(_open_achievements_modal)
	buttons.add_child(ach_btn)
	var settings_btn := _button("Button", "globe", "ui.menu.settings", Vector2(190.0, 60.0), UITheme.HEALTHY)
	settings_btn.pressed.connect(_open_settings_modal)
	buttons.add_child(settings_btn)
	var quit := _button("GhostButton", "power", "ui.menu.quit", Vector2(140.0, 60.0), UITheme.TEXT_DIM)
	quit.pressed.connect(_on_quit_pressed)
	buttons.add_child(quit)
	_main_items.append(buttons)

	var bottom_bar_row := _hbox(24)
	col.add_child(bottom_bar_row)
	_lang_row(bottom_bar_row)
	_audio_row(bottom_bar_row)
	_main_items.append(bottom_bar_row)

	# Letterbox band texts.
	var event_line := _label("DimLabel", "ui.menu.event_line")
	event_line.add_theme_font_size_override("font_size", 16)
	event_line.add_theme_color_override("font_color", UITheme.AMBER.lerp(UITheme.TEXT_DIM, 0.35))
	event_line.position = Vector2(COLUMN_X, 7.0)
	event_line.size = Vector2(780.0, 24.0)
	event_line.clip_text = true
	event_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_main_root.add_child(event_line)

	_clock_label = _label("DimLabel")
	_clock_label.add_theme_font_size_override("font_size", 16)
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_clock_label.anchor_left = 1.0
	_clock_label.anchor_right = 1.0
	_clock_label.offset_left = -420.0
	_clock_label.offset_right = -COLUMN_X
	_clock_label.offset_top = 7.0
	_clock_label.offset_bottom = 31.0
	_main_root.add_child(_clock_label)

	var controls := _label("DimLabel", "ui.menu.controls")
	controls.add_theme_font_size_override("font_size", 16)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.anchor_left = 0.0
	controls.anchor_right = 1.0
	controls.anchor_top = 1.0
	controls.anchor_bottom = 1.0
	controls.offset_left = COLUMN_X
	controls.offset_right = -COLUMN_X
	controls.offset_top = -BAND_H + 4.0
	controls.offset_bottom = -4.0
	controls.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_main_root.add_child(controls)


func _grad_quad(ci: CanvasItem, r: Rect2, c0: Color, c1: Color, horizontal: bool) -> void:
	var pts := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var cols := PackedColorArray()
	if horizontal:
		cols = PackedColorArray([c0, c1, c1, c0])
	else:
		cols = PackedColorArray([c0, c0, c1, c1])
	ci.draw_polygon(pts, cols)


func _draw_main_overlay() -> void:
	var ci: Control = _main_overlay
	var s: Vector2 = ci.size
	var bg: Color = UITheme.BG
	ci.draw_rect(Rect2(Vector2.ZERO, s), UITheme.with_alpha(bg, 0.22))
	_grad_quad(ci, Rect2(0.0, 0.0, s.x * 0.7, s.y), UITheme.with_alpha(bg, 0.95), UITheme.with_alpha(bg, 0.0), true)
	_grad_quad(ci, Rect2(0.0, 0.0, s.x * 0.36, s.y), UITheme.with_alpha(bg, 0.55), UITheme.with_alpha(bg, 0.0), true)
	_grad_quad(ci, Rect2(0.0, BAND_H, s.x, 200.0), UITheme.with_alpha(bg, 0.75), UITheme.with_alpha(bg, 0.0), false)
	_grad_quad(ci, Rect2(0.0, s.y - BAND_H - 220.0, s.x, 220.0), UITheme.with_alpha(bg, 0.0), UITheme.with_alpha(bg, 0.85), false)
	var bh: float = BAND_H * _band_t
	ci.draw_rect(Rect2(0.0, 0.0, s.x, bh), UITheme.DEEP)
	ci.draw_rect(Rect2(0.0, s.y - bh, s.x, bh), UITheme.DEEP)
	ci.draw_line(Vector2(0.0, bh), Vector2(s.x, bh), UITheme.with_alpha(UITheme.AMBER, 0.45), 1.0)
	ci.draw_line(Vector2(0.0, s.y - bh), Vector2(s.x, s.y - bh), UITheme.with_alpha(UITheme.AMBER, 0.45), 1.0)
	# Scale ticks on the bands (tactical ruler).
	var x: float = 0.0
	var i: int = 0
	while x < s.x:
		var th: float = 8.0 if i % 10 == 0 else 3.0
		ci.draw_line(Vector2(x, bh), Vector2(x, bh + th), UITheme.with_alpha(UITheme.AMBER, 0.3), 1.0)
		ci.draw_line(Vector2(x, s.y - bh), Vector2(x, s.y - bh - th), UITheme.with_alpha(UITheme.AMBER, 0.3), 1.0)
		x += 16.0
		i += 1
	var frame := Rect2(28.0, bh + 24.0, s.x - 56.0, s.y - bh * 2.0 - 48.0)
	UITheme.draw_brackets(ci, frame, UITheme.with_alpha(UITheme.AMBER, 0.55 * _band_t), 34.0, 2.0)
	# Slow scanning beam across the map side.
	var sweep: float = fmod(_time * 0.08, 1.0)
	var sx: float = lerpf(s.x * 0.45, s.x - 40.0, sweep)
	_grad_quad(ci, Rect2(sx - 60.0, bh, 60.0, s.y - bh * 2.0), UITheme.with_alpha(UITheme.HEALTHY, 0.0), UITheme.with_alpha(UITheme.HEALTHY, 0.025), true)
	ci.draw_line(Vector2(sx, bh), Vector2(sx, s.y - bh), UITheme.with_alpha(UITheme.HEALTHY, 0.09), 1.0)


func _draw_title() -> void:
	var text: String = I18n.t("game.title")
	var n: int = text.length()
	if n == 0:
		return
	var font: Font = UITheme.mono_bold_font()
	# Glyphs are always rasterized at the final size (spacing 6) and zoomed with a draw
	# transform, so the letter-spacing intro never builds a new glyph cache per frame.
	var fs_end: float = _title_fit_size(text, font, 6.0)
	var fs: int = floori(fs_end)
	var k: float = _title_fit_size(text, font, _title_spacing) / fs_end
	var spacing: float = _title_spacing
	var ascent: float = font.get_ascent(fs) * k
	var base_y: float = (_title_ctrl.size.y - font.get_height(fs) * k) * 0.5 + ascent
	var x: float = 0.0
	var warm: Color = UITheme.TEXT.lerp(UITheme.AMBER, 0.18)
	for i in n:
		var ch: String = text[i]
		var w: float = font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * k
		var a: float = clampf(_title_reveal * float(n + 6) - float(i), 0.0, 1.0)
		if a > 0.0 and ch != " ":
			var flick: float = 1.0
			var noise: float = sin(_time * 7.3 + float(i) * 12.9) * sin(_time * 3.1 + float(i) * 4.7)
			if noise > 0.975:
				flick = 0.78
			var pos := Vector2(x, base_y - (1.0 - a) * 18.0)
			_title_ctrl.draw_set_transform(pos, 0.0, Vector2(k, k))
			_title_ctrl.draw_char_outline(font, Vector2.ZERO, ch, fs, 14, UITheme.with_alpha(UITheme.AMBER, 0.07 * a * flick))
			_title_ctrl.draw_char_outline(font, Vector2.ZERO, ch, fs, 6, UITheme.with_alpha(UITheme.AMBER, 0.16 * a * flick))
			_title_ctrl.draw_char(font, Vector2.ZERO, ch, fs, UITheme.with_alpha(warm, a * flick))
		x += w + spacing
	_title_ctrl.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Font size (unfloored, 28..TITLE_MAX_SIZE) at which the title fits the column with the
## given letter spacing.
func _title_fit_size(text: String, font: Font, spacing: float) -> float:
	var n: int = text.length()
	var avail: float = _title_ctrl.size.x
	var nat: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_MAX_SIZE).x
	var fs_f: float = float(TITLE_MAX_SIZE)
	if nat > 0.0 and nat + spacing * float(maxi(n - 1, 0)) > avail:
		fs_f = float(TITLE_MAX_SIZE) * (avail - spacing * float(maxi(n - 1, 0))) / nat
	return clampf(fs_f, 28.0, float(TITLE_MAX_SIZE))


# --- Pause menu --------------------------------------------------------------------------

func _build_pause() -> void:
	_pause_root = _full_rect(self, Control.MOUSE_FILTER_STOP)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.color = UITheme.with_alpha(UITheme.BG, 0.72)
	_pause_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_root.add_child(center)
	_pause_panel = PanelContainer.new()
	_pause_panel.theme_type_variation = &"MenuPanel"
	_pause_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_panel.custom_minimum_size = Vector2(540.0, 0.0)
	_pause_panel.draw.connect(_bracket_draw.bind(_pause_panel, UITheme.AMBER))
	center.add_child(_pause_panel)
	var col := _vbox(10)
	_pause_panel.add_child(col)

	var head := _hbox(14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(head)
	head.add_child(_icon("pause", UITheme.AMBER, 32.0))
	var t := _label("TitleLabel", "ui.pause.title")
	t.add_theme_color_override("font_color", UITheme.AMBER)
	head.add_child(t)
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep)

	var resume := _button("PrimaryButton", "play", "ui.pause.resume", Vector2(0.0, 60.0), UITheme.HEALTHY)
	resume.pressed.connect(_on_resume_pressed)
	col.add_child(resume)
	var pause_ach := _button("Button", "cop_summit", "ui.menu.achievements", Vector2(0.0, 56.0), UITheme.AMBER)
	pause_ach.pressed.connect(_open_achievements_modal)
	col.add_child(pause_ach)
	var pause_settings := _button("Button", "globe", "ui.menu.settings", Vector2(0.0, 56.0), UITheme.HEALTHY)
	pause_settings.pressed.connect(_open_settings_modal)
	col.add_child(pause_settings)
	var restart := _button("Button", "restart", "ui.pause.restart", Vector2(0.0, 56.0), UITheme.AMBER)
	restart.pressed.connect(_on_restart_pressed)
	col.add_child(restart)

	var sep2 := HSeparator.new()
	sep2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep2)
	var bottom_row := _hbox(12)
	col.add_child(bottom_row)
	var main_menu := _button("GhostButton", "home", "ui.pause.main_menu", Vector2(220.0, 56.0), UITheme.TEXT_DIM)
	main_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_menu.pressed.connect(_on_main_menu_pressed)
	bottom_row.add_child(main_menu)
	var quit := _button("DangerButton", "power", "ui.pause.quit", Vector2(200.0, 56.0), UITheme.TERRACOTTA)
	quit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quit.pressed.connect(_on_quit_pressed)
	bottom_row.add_child(quit)


# --- End screen ---------------------------------------------------------------------------

func _build_end() -> void:
	_end_root = _full_rect(self, Control.MOUSE_FILTER_STOP)
	_end_overlay = ColorRect.new()
	_end_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_end_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_overlay.color = UITheme.with_alpha(UITheme.BG, 0.78)
	_end_root.add_child(_end_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_root.add_child(center)
	_end_panel = PanelContainer.new()
	_end_panel.theme_type_variation = &"MenuPanel"
	_end_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_end_panel.custom_minimum_size = Vector2(920.0, 0.0)
	_end_panel.draw.connect(_on_end_panel_draw)
	center.add_child(_end_panel)
	var col := _vbox(8)
	_end_panel.add_child(col)

	var top_bar := _hbox(12)
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(top_bar)
	_end_icon = _icon("sea_health", UITheme.HEALTHY, 40.0)
	top_bar.add_child(_end_icon)
	var game_name := _label("HeaderLabel", "game.title")
	game_name.add_theme_color_override("font_color", UITheme.with_alpha(UITheme.AMBER, 0.85))
	top_bar.add_child(game_name)
	var spc := Control.new()
	spc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spc)
	_end_grade_badge = PanelContainer.new()
	_end_grade_badge.theme_type_variation = &"BadgePanel"
	_end_grade_label = _label("HeaderLabel")
	_end_grade_label.add_theme_font_size_override("font_size", 20)
	_end_grade_badge.add_child(_end_grade_label)
	top_bar.add_child(_end_grade_badge)

	_end_title = _label("TitleLabel")
	_end_title.add_theme_font_size_override("font_size", 32)
	_end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_end_title.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	col.add_child(_end_title)
	_end_pulse = Charts.new()
	_end_pulse.setup_pulse(Vector2(660.0, 24.0))
	_end_pulse.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_end_pulse)
	_end_text = _label("BodyLabel")
	_end_text.add_theme_font_size_override("font_size", 18)
	_end_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_end_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_end_text.custom_minimum_size = Vector2(780.0, 0.0)
	col.add_child(_end_text)
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep)

	# 2026-2046 Trajectory Chart inside Report Card
	var chart_title := _label("DimLabel", "end.report.chart")
	chart_title.add_theme_font_size_override("font_size", 15)
	chart_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(chart_title)
	var chart_inset := PanelContainer.new()
	chart_inset.theme_type_variation = &"InsetPanel"
	chart_inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(chart_inset)
	_end_chart = Charts.new()
	_end_chart.setup_line(Vector2(760.0, 68.0))
	chart_inset.add_child(_end_chart)

	var inset := PanelContainer.new()
	inset.theme_type_variation = &"InsetPanel"
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(inset)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	inset.add_child(grid)
	var stat_icons: Array = [
		["sea_health", UITheme.HEALTHY],
		["temperature", UITheme.WARNING],
		["clock", UITheme.AMBER],
		["check", Color(0.42, 0.78, 1.0)],
		["turtle", UITheme.HEALTHY],
		["tree", UITheme.AMBER],
	]
	for si in stat_icons:
		var s: Array = si
		var row := _hbox(8)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(row)
		var ic_col: Color = s[1]
		row.add_child(_icon(str(s[0]), ic_col, 22.0))
		var l := _label("SmallLabel")
		l.add_theme_font_size_override("font_size", 18)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.custom_minimum_size = Vector2(210.0, 0.0)
		row.add_child(l)
		_end_stat_labels.append(l)

	var buttons := _hbox(16)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(buttons)
	var again := _button("PrimaryButton", "restart", "end.play_again", Vector2(270.0, 58.0), UITheme.HEALTHY)
	again.pressed.connect(_on_restart_pressed)
	buttons.add_child(again)
	var end_ach_btn := _button("Button", "target", "ui.menu.achievements", Vector2(250.0, 58.0), UITheme.AMBER)
	end_ach_btn.pressed.connect(_open_achievements_modal)
	buttons.add_child(end_ach_btn)
	var to_menu := _button("GhostButton", "home", "end.main_menu", Vector2(230.0, 58.0), UITheme.TEXT_DIM)
	to_menu.pressed.connect(_on_main_menu_pressed)
	buttons.add_child(to_menu)


func _on_end_panel_draw() -> void:
	var c: Color = UITheme.HEALTHY if _end_won else UITheme.CRISIS
	_bracket_draw(_end_panel, UITheme.with_alpha(c, 0.85))
	if not _end_won:
		var r := _end_panel.get_rect()
		var y: float = 0.0
		while y < r.size.y:
			_end_panel.draw_line(Vector2(0, y), Vector2(r.size.x, y), Color(1.0, 0.15, 0.15, 0.08), 1.0)
			y += 4.0
		# CRT military glitch telemetry bars
		_end_panel.draw_rect(Rect2(0, 18, r.size.x, 3), Color(1.0, 0.2, 0.2, 0.35))
		_end_panel.draw_rect(Rect2(0, r.size.y - 24, r.size.x, 3), Color(1.0, 0.2, 0.2, 0.35))


func _end_keys() -> Array:
	if END_KEYS.has(_end_reason):
		var k: Array = END_KEYS[_end_reason]
		return k
	if _end_won:
		return ["end.win.title", "end.win.crisis.text"]
	return ["end.lose.time.title", "end.lose.time.text"]


func _render_end_texts() -> void:
	var keys: Array = _end_keys()
	var sh: float = float(_end_stats.get("sea_health", 0.0))
	var yr: int = int(_end_stats.get("year_int", Balance.END_YEAR))
	# A loss floors the value: rounding would show "10%" on a below-10% ending, or a
	# winning-looking "60%" on a 59.7% time-out.
	var sh_i: int = roundi(sh) if _end_won else floori(sh)
	var args: Dictionary = {"health": str(sh_i), "year": str(yr)}
	if _end_won:
		_end_title.text = I18n.t(str(keys[0]))
	else:
		_end_title.text = "[ SIGNAL LOST // TRANSMISSION TERMINATED ]\n" + I18n.t(str(keys[0]))
	_end_text.text = I18n.t(str(keys[1]), args)
	var accent: Color = UITheme.HEALTHY if _end_won else UITheme.CRISIS
	_end_title.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.12))
	_end_icon.icon_id = "sea_health" if _end_won else "warning"
	_end_icon.color = accent
	_end_pulse.pulse_health = sh if _end_won else minf(sh, 25.0)
	var sb := UITheme.panel_box(UITheme.with_alpha(accent, 0.6), UITheme.with_alpha(UITheme.BG_PANEL, 0.95), 1, UITheme.with_alpha(accent, 0.16), 22, 16)
	sb.content_margin_left = 34.0
	sb.content_margin_right = 34.0
	sb.content_margin_top = 22.0
	sb.content_margin_bottom = 22.0
	_end_panel.add_theme_stylebox_override("panel", sb)

	# Ecology Grade (S / A / B / C / F)
	var grade: String = "F"
	var g_col: Color = UITheme.CRISIS
	if _end_won:
		if sh >= 72.0:
			grade = "S"
			g_col = UITheme.HEALTHY
		elif sh >= 64.0:
			grade = "A"
			g_col = UITheme.HEALTHY
		else:
			grade = "B"
			g_col = UITheme.AMBER
	else:
		if sh >= 50.0:
			grade = "C"
			g_col = UITheme.WARNING
		else:
			grade = "F"
			g_col = UITheme.CRISIS
	if _end_grade_badge != null and _end_grade_label != null:
		_end_grade_badge.add_theme_stylebox_override("panel", UITheme.badge_box(g_col))
		_end_grade_label.text = I18n.t("end.report.grade", {"grade": grade})
		_end_grade_label.add_theme_color_override("font_color", g_col.lerp(Color.WHITE, 0.25))

	# Trajectory Chart
	if _end_chart != null:
		var hist: Array = _end_stats.get("history", GameState.get_history())
		var tick_val: int = int(_end_stats.get("tick", 240))
		var cr_val: float = float(_end_stats.get("crisis", 100.0 - sh))
		_end_chart.set_series(hist, tick_val, sh, cr_val)

	_sync_achievements()
	_end_panel.queue_redraw()


func _render_end_stats() -> void:
	var p: float = clampf(_end_progress, 0.0, 1.0)
	var sh: float = float(_end_stats.get("sea_health", 0.0))
	var temp: float = float(_end_stats.get("temperature", Charts.TEMP_MIN))
	var yr: int = int(_end_stats.get("year_int", Balance.END_YEAR))
	var acts: int = int(_end_stats.get("actions_used", 0))
	var turtles: int = int(_end_stats.get("turtle_nests", 0))
	var seals: int = int(_end_stats.get("monk_seals", 0))
	var pols: int = int(_end_stats.get("adopted_count", GameState.adopted_nodes().size()))
	var texts: Array = [
		I18n.t("end.stat.health", {"v": str(roundi(sh * p) if _end_won else floori(sh * p))}),
		I18n.t("end.stat.temp", {"v": "%.2f" % lerpf(Charts.TEMP_MIN, temp, p)}),
		I18n.t("end.stat.year", {"v": str(int(round(lerpf(float(Balance.START_YEAR), float(yr), p))))}),
		I18n.t("end.stat.actions", {"v": str(roundi(float(acts) * p))}),
		I18n.t("end.report.species", {"t": str(roundi(float(turtles) * p)), "s": str(roundi(float(seals) * p))}),
		I18n.t("end.report.policies", {"n": str(roundi(float(pols) * p))}),
	]
	for i in mini(texts.size(), _end_stat_labels.size()):
		var l: Label = _end_stat_labels[i]
		l.text = str(texts[i])


func _set_end_progress(v: float) -> void:
	_end_progress = v
	_render_end_stats()


# --- Public API (frozen) --------------------------------------------------------------------

func show_main() -> void:
	_mode = "main"
	_open_root(_main_root)
	_sync_lang_buttons()
	_sync_continue_button()
	_sync_achievements()
	_main_root.modulate.a = 0.0
	_band_t = 0.0
	_title_reveal = 0.0
	_title_spacing = 34.0
	_rule.scale = Vector2(0.0, 1.0)
	for it in _main_items:
		var item: Control = it
		item.modulate.a = 0.0
	_set_main_margin(COLUMN_X - 60.0)
	_anim = create_tween()
	_anim.set_parallel(true)
	_anim.set_trans(Tween.TRANS_CUBIC)
	_anim.set_ease(Tween.EASE_OUT)
	_anim.tween_property(_main_root, "modulate:a", 1.0, 0.7)
	_anim.tween_method(_set_band, 0.0, 1.0, 0.9).set_trans(Tween.TRANS_EXPO)
	_anim.tween_method(_set_main_margin, COLUMN_X - 60.0, COLUMN_X, 1.1)
	_anim.tween_method(_set_title_reveal, 0.0, 1.0, 1.4).set_delay(0.15)
	_anim.tween_method(_set_title_spacing, 34.0, 6.0, 1.7).set_delay(0.15)
	_anim.tween_property(_rule, "scale:x", 1.0, 0.8).set_delay(0.6)
	var delay: float = 0.35
	for it in _main_items:
		var item: Control = it
		_anim.tween_property(item, "modulate:a", 1.0, 0.55).set_delay(delay)
		delay += 0.12


func show_pause() -> void:
	_mode = "pause"
	_open_root(_pause_root)
	_sync_lang_buttons()
	_pause_root.modulate.a = 0.0
	_pause_panel.scale = Vector2(0.92, 0.92)
	_anim = create_tween()
	_anim.set_parallel(true)
	_anim.tween_property(_pause_root, "modulate:a", 1.0, 0.22)
	_anim.tween_property(_pause_panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func show_end(won: bool, reason: String, stats: Dictionary) -> void:
	_mode = "end"
	_end_won = won
	_end_reason = reason
	_end_stats = stats
	_end_progress = 0.0
	_render_end_texts()
	_render_end_stats()
	var tint: Color = UITheme.BG.lerp(UITheme.HEALTHY, 0.06) if won else UITheme.BG.lerp(UITheme.CRISIS, 0.12)
	_end_overlay.color = UITheme.with_alpha(tint, 0.76)
	_open_root(_end_root)
	_end_root.modulate.a = 0.0
	_end_panel.scale = Vector2(0.94, 0.94)
	_end_title.visible_ratio = 0.0
	_end_text.visible_ratio = 0.0
	_anim = create_tween()
	_anim.set_parallel(true)
	_anim.set_trans(Tween.TRANS_CUBIC)
	_anim.set_ease(Tween.EASE_OUT)
	_anim.tween_property(_end_root, "modulate:a", 1.0, 0.6)
	_anim.tween_property(_end_panel, "scale", Vector2.ONE, 0.6).set_delay(0.1)
	_anim.tween_property(_end_title, "visible_ratio", 1.0, 0.8).set_delay(0.35)
	_anim.tween_property(_end_text, "visible_ratio", 1.0, 1.1).set_delay(0.8)
	_anim.tween_method(_set_end_progress, 0.0, 1.0, 1.4).set_delay(1.0)


func hide_all() -> void:
	_mode = ""
	_kill_anim()
	_main_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not visible:
		return
	_anim = create_tween()
	_anim.tween_property(self, "modulate:a", 0.0, 0.3)
	_anim.tween_callback(_finish_hide)


func is_open() -> bool:
	return _mode != ""


func is_pause_open() -> bool:
	return _mode == "pause"


func is_modal_open() -> bool:
	return (_ach_modal != null and _ach_modal.visible) or (_settings_modal != null and _settings_modal.visible) or (_hq_modal != null and _hq_modal.visible)


func close_modals() -> void:
	if _ach_modal != null:
		_ach_modal.visible = false
	if _settings_modal != null:
		_settings_modal.visible = false
	if _hq_modal != null:
		_hq_modal.visible = false


# --- Internals -------------------------------------------------------------------------------

func _open_root(root: Control) -> void:
	_kill_anim()
	visible = true
	modulate = Color.WHITE
	close_modals()
	for r in [_main_root, _pause_root, _end_root]:
		var c: Control = r
		c.visible = c == root
		c.mouse_filter = Control.MOUSE_FILTER_STOP if c == root else Control.MOUSE_FILTER_IGNORE


func _finish_hide() -> void:
	if _mode != "":
		return
	visible = false
	_main_root.visible = false
	_pause_root.visible = false
	_end_root.visible = false


func _kill_anim() -> void:
	if _anim != null and _anim.is_valid():
		_anim.kill()
	_anim = null
	if _title_anim != null and _title_anim.is_valid():
		_title_anim.kill()
	_title_anim = null


func _set_band(v: float) -> void:
	_band_t = v
	_main_overlay.queue_redraw()


func _set_main_margin(v: float) -> void:
	_main_margin.add_theme_constant_override("margin_left", int(v))


func _set_title_reveal(v: float) -> void:
	_title_reveal = v
	_title_ctrl.queue_redraw()


func _set_title_spacing(v: float) -> void:
	_title_spacing = v
	_title_ctrl.queue_redraw()


# --- Button handlers --------------------------------------------------------------------------

func _on_start_pressed() -> void:
	AudioSynth.play_click()
	if _mode == "main":
		_open_hq_modal()


func _on_continue_pressed() -> void:
	AudioSynth.play_click()
	if _mode == "main":
		continue_requested.emit()


func _sync_continue_button() -> void:
	if _continue_btn == null:
		return
	var has_save: bool = GameState.has_save_game()
	_continue_btn.visible = has_save
	if has_save:
		var yr: int = GameState.saved_game_year()
		_continue_btn.text = I18n.t("ui.menu.continue", {"year": str(yr)})


func _sync_achievements() -> void:
	if _ach_sub_label != null:
		_ach_sub_label.text = I18n.t("ui.ach.subtitle", {"total": str(GameState.total_unlocked_count())})
	for d_id in GameState.DIFF_IDS:
		if _ach_diff_tabs.has(d_id):
			var btn: Button = _ach_diff_tabs[d_id]
			var d_def: Dictionary = Balance.DIFFICULTIES.get(d_id, {})
			var d_name: String = I18n.t(str(d_def.get("name_key", d_id)))
			var cnt: int = GameState.unlocked_count_for_diff(d_id)
			var total_d: int = GameState.ACH_IDS.size()
			btn.text = "%s (%d/%d)" % [d_name, cnt, total_d]
			btn.set_pressed_no_signal(d_id == _ach_view_diff)
			if d_id == _ach_view_diff:
				var col: Color = UITheme.HEALTHY if d_id == "cadet" else (UITheme.AMBER if d_id == "commander" else UITheme.CRISIS)
				btn.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.25))
			else:
				btn.remove_theme_color_override("font_color")
	for aid in _ach_rows.keys():
		var rec: Dictionary = _ach_rows[aid]
		var card: PanelContainer = rec["card"]
		var ic: Icons = rec["icon"]
		var name_l: Label = rec["name"]
		var desc_l: Label = rec["desc"]
		var badge: PanelContainer = rec["badge"]
		var badge_l: Label = rec["badge_label"]
		var unlocked: bool = GameState.is_ach_unlocked(_ach_view_diff, aid)
		var col: Color = UITheme.AMBER if unlocked else UITheme.LINE_DIM
		var sb := UITheme.panel_box(UITheme.with_alpha(col, 0.75 if unlocked else 0.35), UITheme.with_alpha(UITheme.DEEP, 0.90), 1, Color(0, 0, 0, 0), 0, 8)
		sb.content_margin_left = 16.0
		sb.content_margin_right = 16.0
		sb.content_margin_top = 10.0
		sb.content_margin_bottom = 10.0
		card.add_theme_stylebox_override("panel", sb)
		ic.set_icon("cop_summit" if unlocked else "lock", UITheme.AMBER if unlocked else UITheme.TEXT_DIM, 28.0)
		name_l.text = I18n.t("ach." + str(aid) + ".name")
		name_l.add_theme_color_override("font_color", UITheme.AMBER.lerp(Color.WHITE, 0.3) if unlocked else UITheme.TEXT)
		desc_l.text = I18n.t("ach." + str(aid) + ".desc")
		desc_l.add_theme_color_override("font_color", UITheme.TEXT if unlocked else UITheme.TEXT_DIM)
		var b_col: Color = UITheme.HEALTHY if unlocked else UITheme.LINE_DIM
		badge.add_theme_stylebox_override("panel", UITheme.badge_box(b_col))
		badge_l.text = I18n.t("ui.ach.unlocked" if unlocked else "ui.ach.locked")
		badge_l.add_theme_color_override("font_color", UITheme.HEALTHY.lerp(Color.WHITE, 0.25) if unlocked else UITheme.TEXT_DIM)


func _on_scroll_touch_drag(event: InputEvent, sc: ScrollContainer) -> void:
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device != InputEvent.DEVICE_ID_EMULATION and (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			sc.scroll_vertical -= int(mm.relative.y)


func _build_achievements_modal() -> void:
	_ach_modal = _full_rect(self, Control.MOUSE_FILTER_STOP)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = UITheme.with_alpha(UITheme.BG, 0.85)
	_ach_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ach_modal.add_child(center)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"MenuPanel"
	panel.custom_minimum_size = Vector2(960.0, 620.0)
	panel.draw.connect(_bracket_draw.bind(panel, UITheme.AMBER))
	center.add_child(panel)

	var col := _vbox(10)
	panel.add_child(col)

	var head := _hbox(12)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(head)
	head.add_child(_icon("cop_summit", UITheme.AMBER, 34.0))
	var title := _label("TitleLabel", "ui.ach.modal_title")
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UITheme.AMBER)
	head.add_child(title)

	_ach_sub_label = _label("DimLabel")
	_ach_sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ach_sub_label.add_theme_font_size_override("font_size", 18)
	col.add_child(_ach_sub_label)

	var tab_row := _hbox(12)
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(tab_row)
	_ach_diff_tabs.clear()
	for d_id in GameState.DIFF_IDS:
		var tbtn := Button.new()
		tbtn.theme_type_variation = &"ChipButton"
		tbtn.toggle_mode = true
		tbtn.focus_mode = Control.FOCUS_NONE
		tbtn.custom_minimum_size = Vector2(270.0, 56.0)
		tbtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tbtn.pressed.connect(_on_ach_tab_selected.bind(d_id))
		tab_row.add_child(tbtn)
		_ach_diff_tabs[d_id] = tbtn

	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(880.0, 340.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.gui_input.connect(_on_scroll_touch_drag.bind(scroll))
	col.add_child(scroll)

	var list := _vbox(10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.mouse_filter = Control.MOUSE_FILTER_PASS
	list.gui_input.connect(_on_scroll_touch_drag.bind(scroll))
	scroll.add_child(list)

	_ach_rows.clear()
	for aid in GameState.ACH_IDS:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.gui_input.connect(_on_scroll_touch_drag.bind(scroll))
		list.add_child(card)
		var crow := _hbox(14)
		crow.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_child(crow)
		var ic := _icon("lock", UITheme.TEXT_DIM, 30.0)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		crow.add_child(ic)
		var mid := _vbox(3)
		mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid.mouse_filter = Control.MOUSE_FILTER_PASS
		crow.add_child(mid)
		var nl := _label("HeaderLabel")
		nl.add_theme_font_size_override("font_size", 20)
		mid.add_child(nl)
		var dl := _label("BodyLabel")
		dl.add_theme_font_size_override("font_size", 18)
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.custom_minimum_size = Vector2(580.0, 0.0)
		mid.add_child(dl)
		var badge := PanelContainer.new()
		badge.theme_type_variation = &"BadgePanel"
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bl := _label("BadgeLabel")
		bl.add_theme_font_size_override("font_size", 16)
		badge.add_child(bl)
		crow.add_child(badge)
		_ach_rows[aid] = {
			"card": card,
			"icon": ic,
			"name": nl,
			"desc": dl,
			"badge": badge,
			"badge_label": bl,
		}

	var close_row := _hbox(12)
	close_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(close_row)
	var close_btn := _button("PrimaryButton", "close", "ui.ach.close", Vector2(280.0, 56.0), UITheme.AMBER)
	close_btn.pressed.connect(_close_achievements_modal)
	close_row.add_child(close_btn)


func _on_ach_tab_selected(d_id: String) -> void:
	_ach_view_diff = d_id
	AudioSynth.play_click()
	GameState.vibrate_light()
	_sync_achievements()


func _open_achievements_modal() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_ach_view_diff = GameState.selected_difficulty
	_sync_achievements()
	_ach_modal.visible = true


func _close_achievements_modal() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_ach_modal.visible = false


func _build_settings_modal() -> void:
	_settings_modal = _full_rect(self, Control.MOUSE_FILTER_STOP)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = UITheme.with_alpha(UITheme.BG, 0.85)
	_settings_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_modal.add_child(center)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"MenuPanel"
	panel.custom_minimum_size = Vector2(860.0, 646.0)
	panel.draw.connect(_bracket_draw.bind(panel, UITheme.HEALTHY))
	center.add_child(panel)

	var col := _vbox(8)
	panel.add_child(col)

	var head := _hbox(12)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(head)
	head.add_child(_icon("globe", UITheme.HEALTHY, 30.0))
	var title := _label("TitleLabel", "ui.settings.title")
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.HEALTHY)
	head.add_child(title)

	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep)

	var s_scroll := ScrollContainer.new()
	s_scroll.custom_minimum_size = Vector2(780.0, 462.0)
	s_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s_scroll.follow_focus = true
	s_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	s_scroll.gui_input.connect(_on_scroll_touch_drag.bind(s_scroll))
	col.add_child(s_scroll)

	var scol := _vbox(10)
	scol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scol.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.gui_input.connect(_on_scroll_touch_drag.bind(s_scroll))
	s_scroll.add_child(scol)

	# 1. Graphics Quality
	var gfx_box := _vbox(4)
	gfx_box.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.add_child(gfx_box)
	gfx_box.add_child(_label("HeaderLabel", "ui.settings.graphics"))
	var gfx_row := _hbox(12)
	gfx_row.mouse_filter = Control.MOUSE_FILTER_PASS
	gfx_box.add_child(gfx_row)
	_gfx_buttons.clear()
	var gfx_keys := {0: "ui.settings.gfx_low", 1: "ui.settings.gfx_med", 2: "ui.settings.gfx_high"}
	for q in [0, 1, 2]:
		var gb := _button("ChipButton", "", gfx_keys[q], Vector2(220.0, 46.0), UITheme.HEALTHY)
		gb.toggle_mode = true
		gb.mouse_filter = Control.MOUSE_FILTER_PASS
		gb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gb.pressed.connect(_on_gfx_selected.bind(q))
		gfx_row.add_child(gb)
		_gfx_buttons[q] = gb

	# 2. FPS Limit
	var fps_box := _vbox(4)
	fps_box.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.add_child(fps_box)
	fps_box.add_child(_label("HeaderLabel", "ui.settings.fps"))
	var fps_row := _hbox(12)
	fps_row.mouse_filter = Control.MOUSE_FILTER_PASS
	fps_box.add_child(fps_row)
	_fps_buttons.clear()
	for fps_val in [30, 60, 120]:
		var fb := Button.new()
		fb.theme_type_variation = &"ChipButton"
		fb.toggle_mode = true
		fb.focus_mode = Control.FOCUS_NONE
		fb.mouse_filter = Control.MOUSE_FILTER_PASS
		fb.custom_minimum_size = Vector2(220.0, 46.0)
		fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fb.text = "%d FPS" % fps_val
		fb.pressed.connect(_on_fps_selected.bind(fps_val))
		fps_row.add_child(fb)
		_fps_buttons[fps_val] = fb

	# 3. Audio Volume & Haptics
	var aud_box := _vbox(4)
	aud_box.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.add_child(aud_box)
	aud_box.add_child(_label("HeaderLabel", "ui.settings.audio"))
	_audio_row(aud_box)

	var hap_box := _vbox(4)
	hap_box.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.add_child(hap_box)
	hap_box.add_child(_label("HeaderLabel", "ui.settings.haptics"))
	var hap_row := _hbox(12)
	hap_row.mouse_filter = Control.MOUSE_FILTER_PASS
	hap_box.add_child(hap_row)
	_haptic_buttons.clear()
	for h_on in [true, false]:
		var hb := _button("ChipButton", "", "ui.settings.on" if h_on else "ui.settings.off", Vector2(220.0, 46.0), UITheme.HEALTHY)
		hb.toggle_mode = true
		hb.mouse_filter = Control.MOUSE_FILTER_PASS
		hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.pressed.connect(_on_haptic_selected.bind(h_on))
		hap_row.add_child(hb)
		_haptic_buttons[h_on] = hb

	# 4. Language
	var lng_box := _vbox(4)
	lng_box.mouse_filter = Control.MOUSE_FILTER_PASS
	scol.add_child(lng_box)
	lng_box.add_child(_label("HeaderLabel", "ui.settings.lang"))
	var lng_row := _hbox(12)
	lng_row.mouse_filter = Control.MOUSE_FILTER_PASS
	lng_box.add_child(lng_row)
	for c in I18n.LANGS:
		var code: String = c
		var b := Button.new()
		b.theme_type_variation = &"ChipButton"
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_filter = Control.MOUSE_FILTER_PASS
		b.text = I18n.lang_name(code)
		b.custom_minimum_size = Vector2(220.0, 46.0)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_on_lang_pressed.bind(code))
		lng_row.add_child(b)
		_lang_buttons.append([b, code])

	var sep2 := HSeparator.new()
	sep2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep2)

	var close_row := _hbox(12)
	close_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(close_row)
	var close_btn := _button("PrimaryButton", "check", "ui.settings.close", Vector2(320.0, 50.0), UITheme.HEALTHY)
	close_btn.pressed.connect(_close_settings_modal)
	close_row.add_child(close_btn)
	_sync_settings_controls()


func _sync_settings_controls() -> void:
	for q in _gfx_buttons.keys():
		var b: Button = _gfx_buttons[q]
		var sel: bool = (int(q) == GameState.graphics_quality)
		b.set_pressed_no_signal(sel)
		if sel:
			b.add_theme_color_override("font_color", UITheme.HEALTHY)
		else:
			b.remove_theme_color_override("font_color")
	for f in _fps_buttons.keys():
		var b: Button = _fps_buttons[f]
		var sel: bool = (int(f) == GameState.fps_limit)
		b.set_pressed_no_signal(sel)
		if sel:
			b.add_theme_color_override("font_color", UITheme.AMBER)
		else:
			b.remove_theme_color_override("font_color")
	for h in _haptic_buttons.keys():
		var b: Button = _haptic_buttons[h]
		var sel: bool = (bool(h) == GameState.haptics_enabled)
		b.set_pressed_no_signal(sel)
		if sel:
			b.add_theme_color_override("font_color", UITheme.HEALTHY)
		else:
			b.remove_theme_color_override("font_color")
	_sync_lang_buttons()
	_sync_audio_controls()


func _on_gfx_selected(q: int) -> void:
	GameState.set_graphics_quality(q)
	AudioSynth.play_click()
	GameState.vibrate_light()
	_sync_settings_controls()


func _on_fps_selected(fps_val: int) -> void:
	GameState.set_fps_limit(fps_val)
	AudioSynth.play_click()
	GameState.vibrate_light()
	_sync_settings_controls()


func _on_haptic_selected(on: bool) -> void:
	GameState.set_haptics_enabled(on)
	AudioSynth.play_click()
	if on:
		GameState.vibrate_medium()
	_sync_settings_controls()


func _open_settings_modal() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_sync_settings_controls()
	_settings_modal.visible = true


func _close_settings_modal() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_settings_modal.visible = false


func _build_hq_modal() -> void:
	_hq_modal = _full_rect(self, Control.MOUSE_FILTER_STOP)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = UITheme.with_alpha(UITheme.BG, 0.88)
	_hq_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hq_modal.add_child(center)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"MenuPanel"
	panel.custom_minimum_size = Vector2(960.0, 620.0)
	panel.draw.connect(_bracket_draw.bind(panel, UITheme.HEALTHY))
	center.add_child(panel)

	var col := _vbox(10)
	panel.add_child(col)

	var head := _hbox(12)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(head)
	head.add_child(_icon("target", UITheme.HEALTHY, 32.0))
	_hq_title_label = _label("TitleLabel", "ui.hq.title")
	_hq_title_label.add_theme_font_size_override("font_size", 28)
	_hq_title_label.add_theme_color_override("font_color", UITheme.HEALTHY)
	head.add_child(_hq_title_label)

	_hq_sub_label = _label("DimLabel", "ui.hq.subtitle")
	_hq_sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hq_sub_label.add_theme_font_size_override("font_size", 17)
	_hq_sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hq_sub_label.custom_minimum_size = Vector2(860.0, 0.0)
	col.add_child(_hq_sub_label)

	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(880.0, 390.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.gui_input.connect(_on_scroll_touch_drag.bind(scroll))
	col.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	grid.gui_input.connect(_on_scroll_touch_drag.bind(scroll))
	scroll.add_child(grid)

	_hq_cards.clear()
	for rid in RegionData.IDS:
		var btn := Button.new()
		btn.theme_type_variation = &"ChipButton"
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(420.0, 74.0)
		btn.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(_on_hq_selected.bind(rid))
		grid.add_child(btn)

		var m := MarginContainer.new()
		m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m.add_theme_constant_override("margin_left", 14)
		m.add_theme_constant_override("margin_right", 14)
		m.add_theme_constant_override("margin_top", 8)
		m.add_theme_constant_override("margin_bottom", 8)
		btn.add_child(m)

		var v := _vbox(3)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m.add_child(v)

		var top_r := _hbox(8)
		top_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(top_r)
		var ic := _icon("target", UITheme.AMBER, 20.0)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_r.add_child(ic)
		var nl := _label("HeaderLabel")
		nl.add_theme_font_size_override("font_size", 19)
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.clip_text = true
		top_r.add_child(nl)

		var sl := _label("SmallLabel")
		sl.add_theme_font_size_override("font_size", 15)
		sl.add_theme_color_override("font_color", UITheme.TEXT_DIM)
		sl.clip_text = true
		v.add_child(sl)

		_hq_cards[rid] = {
			"btn": btn,
			"icon": ic,
			"name": nl,
			"species": sl,
		}

	var sep2 := HSeparator.new()
	sep2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sep2)

	var btn_row := _hbox(16)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(btn_row)
	var back_btn := _button("GhostButton", "close", "ui.hq.back", Vector2(240.0, 54.0), UITheme.TEXT_DIM)
	back_btn.pressed.connect(_close_hq_modal)
	btn_row.add_child(back_btn)
	var confirm_btn := _button("PrimaryButton", "play", "ui.hq.confirm", Vector2(320.0, 54.0), UITheme.HEALTHY)
	confirm_btn.pressed.connect(_on_hq_confirmed)
	btn_row.add_child(confirm_btn)


func _sync_hq_modal() -> void:
	for rid in _hq_cards.keys():
		var rec: Dictionary = _hq_cards[rid]
		var btn: Button = rec["btn"]
		var ic: Icons = rec["icon"]
		var nl: Label = rec["name"]
		var sl: Label = rec["species"]
		var sel: bool = (rid == GameState.hq_region)
		btn.set_pressed_no_signal(sel)
		btn.text = ""
		nl.text = I18n.t("region." + str(rid) + ".name")
		nl.add_theme_color_override("font_color", UITheme.HEALTHY.lerp(Color.WHITE, 0.25) if sel else UITheme.TEXT)
		sl.text = "🐾 " + I18n.t("region." + str(rid) + ".species") + "  ·  " + I18n.t("region." + str(rid) + ".trait")
		sl.add_theme_color_override("font_color", UITheme.AMBER if sel else UITheme.TEXT_DIM)
		ic.set_icon("target" if sel else "globe", UITheme.HEALTHY if sel else UITheme.TEXT_DIM, 20.0)


func _on_hq_selected(rid: String) -> void:
	GameState.hq_region = rid
	AudioSynth.play_click()
	GameState.vibrate_light()
	_sync_hq_modal()


func _open_hq_modal() -> void:
	if not RegionData.DEFS.has(GameState.hq_region):
		GameState.hq_region = RegionData.HERO_ID
	_sync_hq_modal()
	_hq_modal.visible = true


func _close_hq_modal() -> void:
	AudioSynth.play_click()
	GameState.vibrate_light()
	_hq_modal.visible = false


func _on_hq_confirmed() -> void:
	AudioSynth.play_click()
	GameState.vibrate_medium()
	_hq_modal.visible = false
	GameState.clear_save_game()
	start_requested.emit()


func _on_diff_selected(d_id: String) -> void:
	GameState.selected_difficulty = d_id
	AudioSynth.play_click()
	_update_diff_selection(d_id)


func _update_diff_selection(d_id: String) -> void:
	for k in _diff_buttons.keys():
		var btn: Button = _diff_buttons[k]
		var k_def: Dictionary = Balance.DIFFICULTIES.get(k, {})
		btn.text = I18n.t(str(k_def.get("name_key", k)))
		if k == d_id:
			var c: Color = UITheme.HEALTHY if k == "cadet" else (UITheme.AMBER if k == "commander" else UITheme.CRISIS)
			btn.add_theme_color_override("font_color", c)
		else:
			btn.remove_theme_color_override("font_color")
	if _diff_desc_label != null:
		var d_def: Dictionary = Balance.DIFFICULTIES.get(d_id, {})
		_diff_desc_label.text = I18n.t(str(d_def.get("desc_key", "")))


func _on_resume_pressed() -> void:
	if _mode == "pause":
		resume_requested.emit()


func _on_restart_pressed() -> void:
	if _mode == "pause" or _mode == "end":
		restart_requested.emit()


func _on_main_menu_pressed() -> void:
	if _mode == "pause" or _mode == "end":
		main_menu_requested.emit()


func _on_quit_pressed() -> void:
	if _mode == "main" or _mode == "pause":
		quit_requested.emit()


func _on_lang_pressed(code: String) -> void:
	I18n.set_language(code)
	_sync_lang_buttons()


func _on_language_changed(_lang: String) -> void:
	for pair in _tr_labels:
		var p: Array = pair
		var l: Label = p[0]
		var key: String = p[1]
		l.text = I18n.t(key)
	for pair in _tr_buttons:
		var p: Array = pair
		var b: Button = p[0]
		var key: String = p[1]
		b.text = I18n.t(key)
	_sync_lang_buttons()
	_sync_continue_button()
	_sync_achievements()
	_sync_hq_modal()
	_update_diff_selection(GameState.selected_difficulty)
	_title_ctrl.queue_redraw()
	if _mode == "main":
		if _title_anim != null and _title_anim.is_valid():
			_title_anim.kill()
		_title_anim = create_tween()
		_title_anim.tween_method(_set_title_reveal, 0.0, 1.0, 0.7)
	if _mode == "end":
		_render_end_texts()
		_render_end_stats()


func _process(delta: float) -> void:
	_time += delta
	if not visible:
		return
	if _main_root.visible:
		_main_overlay.queue_redraw()
		_title_ctrl.queue_redraw()
		_clock_label.text = Time.get_date_string_from_system() + "  ·  " + Time.get_time_string_from_system()
	if _pause_root.visible:
		_pause_panel.pivot_offset = _pause_panel.size * 0.5
	if _end_root.visible:
		_end_panel.pivot_offset = _end_panel.size * 0.5
		_end_icon.pivot_offset = _end_icon.size * 0.5
		_end_icon.scale = Vector2.ONE * (1.0 + 0.06 * sin(_time * 3.0))
