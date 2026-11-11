extends Node
## GameState (autoload): owns the running CrisisSim, advances it with a fixed-step
## accumulator scaled by game speed, applies player actions (field operations, policy
## adoptions, event choices, bubble pickups) and republishes every result on EventBus.

const CrisisSim := preload("res://scripts/crisis_sim.gd")
const RegionData := preload("res://scripts/region.gd")

## Sim toast keys that may be newer than the string table: if I18n lacks one, the toast
## uses this older key with a close meaning instead of showing the raw key.
const TOAST_KEY_FALLBACK := {"toast.depleted": "toast.low_resources"}

var sim: CrisisSim = null
var running: bool = false          # a game is in progress (false in menus and after game over)
var menu_paused: bool = false      # pause menu is open (kept for Phase 1 callers)
var speed_index: int = 1           # index into Balance.SPEEDS (0 = pause)
var selected_region: String = ""
var game_seed: int = 0
var selected_difficulty: String = "commander"

var _last_speed: int = 1
var _accumulator: float = 0.0
var _pause_reasons: Dictionary = {}   # "menu" | "tree" | "event" | "summit" | "tutorial" -> true; any reason pauses time

const SAVE_PATH := "user://savegame.dat"
const ACH_PATH := "user://achievements.cfg"
const SETTINGS_PATH := "user://settings.cfg"
const DIFF_IDS := ["cadet", "commander", "admiral"]
const ACH_IDS := [
	"marmara_zero",
	"antalya_zero",
	"aegean_zero",
	"adriatic_zero",
	"blacksea_zero",
	"levant_zero",
	"western_zero",
	"central_zero",
	"marmara_clean",
	"species_guardian",
	"reformer",
	"full_shield",
	"high_awareness",
	"cool_basin",
	"basin_victor",
]
var unlocked_achievements: Dictionary = {}

# Persistent Mobile Settings
var graphics_quality: int = 1      # 0 = Low (0.60x), 1 = Medium (0.75x), 2 = High (1.00x)
var fps_limit: int = 60            # 30, 60, 120
var haptics_enabled: bool = true


func _ready() -> void:
	_load_settings()
	_load_achievements()
	EventBus.region_selected.connect(_on_region_selected)
	EventBus.language_changed.connect(_on_language_saved)
	call_deferred("apply_settings")


func _on_language_saved(_lang: String) -> void:
	save_settings()


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		graphics_quality = clampi(int(cfg.get_value("system", "graphics_quality", 1)), 0, 2)
		fps_limit = int(cfg.get_value("system", "fps_limit", 60))
		if fps_limit != 30 and fps_limit != 60 and fps_limit != 120:
			fps_limit = 60
		haptics_enabled = bool(cfg.get_value("system", "haptics", true))
		var saved_lang: String = str(cfg.get_value("system", "language", ""))
		if saved_lang in ["tr", "en", "ru"] and saved_lang != I18n.lang:
			I18n.set_language(saved_lang)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("system", "graphics_quality", graphics_quality)
	cfg.set_value("system", "fps_limit", fps_limit)
	cfg.set_value("system", "haptics", haptics_enabled)
	cfg.set_value("system", "language", I18n.lang)
	cfg.save(SETTINGS_PATH)


func apply_settings() -> void:
	Engine.max_fps = fps_limit
	var vp := get_viewport()
	if vp != null:
		if graphics_quality == 0:
			vp.scaling_3d_scale = 0.60
		elif graphics_quality == 1:
			vp.scaling_3d_scale = 0.75
		else:
			vp.scaling_3d_scale = 1.00


func set_graphics_quality(q: int) -> void:
	graphics_quality = clampi(q, 0, 2)
	apply_settings()
	save_settings()


func set_fps_limit(fps: int) -> void:
	fps_limit = fps
	apply_settings()
	save_settings()


func set_haptics_enabled(on: bool) -> void:
	haptics_enabled = on
	save_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if running and sim != null and not sim.over:
			save_game()


# --- Haptic Feedback (Mobile Vibration) -----------------------------------------------------

func vibrate_light() -> void:
	if not haptics_enabled:
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		Input.vibrate_handheld(16)


func vibrate_medium() -> void:
	if not haptics_enabled:
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		Input.vibrate_handheld(32)


func vibrate_heavy() -> void:
	if not haptics_enabled:
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		Input.vibrate_handheld(75)


# --- Achievements & Medals (15 per difficulty = 45 total) -----------------------------------

func _ach_key(diff: String, ach_id: String) -> String:
	return diff + ":" + ach_id


func is_ach_unlocked(diff: String, ach_id: String) -> bool:
	return unlocked_achievements.has(_ach_key(diff, ach_id))


func unlocked_count_for_diff(diff: String) -> int:
	var c: int = 0
	for id in ACH_IDS:
		if is_ach_unlocked(diff, id):
			c += 1
	return c


func total_unlocked_count() -> int:
	var c: int = 0
	for d in DIFF_IDS:
		c += unlocked_count_for_diff(d)
	return c


func _load_achievements() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ACH_PATH) == OK:
		for d in DIFF_IDS:
			for id in ACH_IDS:
				if bool(cfg.get_value(d, id, false)):
					unlocked_achievements[_ach_key(d, id)] = true


func _save_achievements() -> void:
	var cfg := ConfigFile.new()
	for d in DIFF_IDS:
		for id in ACH_IDS:
			cfg.set_value(d, id, is_ach_unlocked(d, id))
	cfg.save(ACH_PATH)


func unlock_achievement(ach_id: String, diff: String = "") -> void:
	var d: String = diff if diff != "" else selected_difficulty
	if not (d in DIFF_IDS):
		d = "commander"
	var key: String = _ach_key(d, ach_id)
	if unlocked_achievements.has(key):
		return
	unlocked_achievements[key] = true
	_save_achievements()
	vibrate_medium()
	AudioSynth.play_policy_adopt()
	var nm: String = I18n.t("ach." + ach_id + ".name")
	EventBus.toast.emit("toast.ach_unlocked", {"name": nm}, 1)
	EventBus.achievement_unlocked.emit(ach_id)


func _check_achievements(won_game: bool = false) -> void:
	if sim == null:
		return
	var d: String = sim.difficulty if sim.difficulty != "" else selected_difficulty
	# 1-8: Regional 0% crisis achievements
	var zero_map := {
		"marmara": "marmara_zero",
		"antalya": "antalya_zero",
		"aegean": "aegean_zero",
		"adriatic": "adriatic_zero",
		"blacksea": "blacksea_zero",
		"levant": "levant_zero",
		"western": "western_zero",
		"central": "central_zero",
	}
	for rid in zero_map:
		if sim.regions.has(rid):
			var r_zero = sim.regions[rid]
			if r_zero.crisis_level() <= 1.0:
				unlock_achievement(zero_map[rid], d)
	# 9: Marmara clean & healthy
	if sim.regions.has("marmara"):
		var mr = sim.regions["marmara"]
		if mr.pollution <= 15.0 and mr.health() >= 80.0:
			unlock_achievement("marmara_clean", d)
	# 10: Biodiversity guardian (Caretta nests + Monk seals)
	if sim.turtle_nests() + sim.monk_seals() >= 2800:
		unlock_achievement("species_guardian", d)
	# 11: Policy reformer (10+ policies adopted)
	if sim.adopted_nodes().size() >= 10:
		unlock_achievement("reformer", d)
	# 12: Full protection shield in any region (>= 85%)
	for rid in RegionData.IDS:
		if sim.regions.has(rid):
			var r = sim.regions[rid]
			if r.protection >= 85.0:
				unlock_achievement("full_shield", d)
				break
	# 13: High basin-wide public awareness (>= 75%)
	if sim.avg_awareness() >= 75.0:
		unlock_achievement("high_awareness", d)
	# 14 & 15: Victory achievements
	if won_game:
		unlock_achievement("basin_victor", d)
		if sim.temperature <= 2.6:
			unlock_achievement("cool_basin", d)


# --- Auto-Save & Continue System ------------------------------------------------------------

func has_save_game() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func saved_game_year() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 2026
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return 2026
	var data: Variant = f.get_var()
	if data is Dictionary:
		var t: int = int(data.get("tick", 0))
		return 2026 + int(t / 12)
	return 2026


func save_game() -> void:
	if sim == null or not running or sim.over:
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	var payload: Dictionary = sim.serialize()
	payload["game_seed"] = game_seed
	f.store_var(payload)


func clear_save_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func load_saved_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var data: Variant = f.get_var()
	if not (data is Dictionary):
		return false
	var d: Dictionary = data
	Engine.time_scale = 1.0
	game_seed = int(d.get("game_seed", randi()))
	selected_difficulty = str(d.get("difficulty", "commander"))
	sim = CrisisSim.new(game_seed, selected_difficulty)
	sim.deserialize(d)
	running = true
	menu_paused = false
	_pause_reasons.clear()
	_accumulator = 0.0
	_last_speed = 1
	EventBus.difficulty_changed.emit(selected_difficulty)
	EventBus.game_started.emit()
	_publish_all()
	var yr: int = 2026 + int(sim.tick / 12)
	EventBus.toast.emit("toast.game_resumed", {"year": str(yr)}, 1)
	return true


## Starts a fresh game. p_seed < 0 picks a random seed (logged for reproducibility).
func new_game(p_seed: int = -1, p_difficulty: String = "") -> void:
	Engine.time_scale = 1.0
	game_seed = p_seed if p_seed >= 0 else randi()
	if p_difficulty != "":
		selected_difficulty = p_difficulty
	print("GameState: new game, seed ", game_seed, " diff: ", selected_difficulty)
	sim = CrisisSim.new(game_seed, selected_difficulty)
	running = true
	menu_paused = false
	_pause_reasons.clear()
	_accumulator = 0.0
	_last_speed = 1
	EventBus.difficulty_changed.emit(selected_difficulty)
	EventBus.game_started.emit()
	_publish_all()
	EventBus.toast.emit("toast.game_start", {}, 1)


func stop_game() -> void:
	running = false
	menu_paused = false
	_pause_reasons.clear()
	_accumulator = 0.0


func set_speed(index: int) -> void:
	Engine.time_scale = 1.0
	speed_index = clampi(index, 0, Balance.SPEEDS.size() - 1)
	if speed_index > 0:
		_last_speed = speed_index
	EventBus.speed_changed.emit(speed_index)
	EventBus.paused_changed.emit(is_paused())


func toggle_pause() -> void:
	if speed_index == 0:
		set_speed(_last_speed)
	else:
		set_speed(0)


func set_menu_paused(on: bool) -> void:
	menu_paused = on
	set_pause_reason("menu", on)


## Modal views stop time while they are open: "menu", "tree", "event".
func set_pause_reason(reason: String, on: bool) -> void:
	if on:
		_pause_reasons[reason] = true
	else:
		_pause_reasons.erase(reason)
	EventBus.paused_changed.emit(is_paused())


func has_pause_reason(reason: String) -> bool:
	return _pause_reasons.has(reason)


func is_paused() -> bool:
	return speed_index == 0 or not _pause_reasons.is_empty() or not running


## Sub-tick accumulator progress 0..1 for the live HUD tick progress bar.
func tick_progress() -> float:
	if sim == null or not running:
		return 0.0
	return clampf(_accumulator / maxf(Balance.TICK_SECONDS, 0.001), 0.0, 1.0)


func _process(delta: float) -> void:
	if _pause_reasons.has("event") and (sim == null or sim.pending_event.is_empty()):
		_pause_reasons.erase("event")
		EventBus.paused_changed.emit(is_paused())
	if sim == null or not running or not _pause_reasons.is_empty():
		return
	var speed: float = Balance.SPEEDS[speed_index]
	if speed <= 0.0:
		return
	_accumulator += delta * speed
	var steps: int = 0
	while running and _pause_reasons.is_empty() and _accumulator >= Balance.TICK_SECONDS and steps < Balance.MAX_TICKS_PER_FRAME:
		_accumulator -= Balance.TICK_SECONDS
		steps += 1
		_do_tick()
	if steps >= Balance.MAX_TICKS_PER_FRAME or not _pause_reasons.is_empty():
		_accumulator = 0.0  # drop the backlog after a frame spike or when an event card stops time


func _do_tick() -> void:
	var result: Dictionary = sim.step()
	_publish_result(result)
	_publish_all()
	var is_over: bool = bool(result.get("game_over", false))
	var won_now: bool = bool(result.get("won", false))
	_check_achievements(is_over and won_now)
	if is_over:
		running = false
		_pause_reasons.clear()
		clear_save_game()
		vibrate_heavy()
		AudioSynth.set_siren(false)
		AudioSynth.set_heartbeat(false)
		var stats: Dictionary = sim.snapshot()
		var reason: String = str(result.get("reason", ""))
		stats["reason"] = reason
		stats["adopted_count"] = sim.adopted_nodes().size()
		stats["history"] = sim.history.duplicate(true)
		EventBus.game_over.emit(won_now, reason, stats)
		return
	if sim.tick % 6 == 0:
		save_game()
	var ev: Dictionary = result.get("event", {})
	if not ev.is_empty():
		set_pause_reason("event", true)
		EventBus.event_triggered.emit(str(ev.get("id", "")))
	var summit: Dictionary = result.get("summit", {})
	if not summit.is_empty():
		set_pause_reason("summit", true)
		EventBus.summit_triggered.emit(summit)


# --- Field operations -------------------------------------------------------------------

func can_perform(action_id: String, region_id: String) -> bool:
	return sim != null and running and sim.can_perform(action_id, region_id)


func can_afford(action_id: String) -> bool:
	return sim != null and sim.can_afford(action_id)


## {"budget": float, "political": float, "science": float} (missing keys = 0). Includes the
## running cost modifiers once a game is on.
func action_cost(action_id: String) -> Dictionary:
	if sim != null:
		return sim.action_cost(action_id)
	var def: Dictionary = Balance.ACTIONS.get(action_id, {})
	return def.get("cost", {})


## Remaining cooldown in seconds at 1x speed (0 = ready).
func action_cooldown_left(action_id: String, region_id: String) -> float:
	if sim == null:
		return 0.0
	return float(sim.cooldown_left_ticks(action_id, region_id)) * Balance.TICK_SECONDS


## Remaining cooldown as a fraction 0..1 (1 = just used).
func action_cooldown_fraction(action_id: String, region_id: String) -> float:
	if sim == null:
		return 0.0
	var def: Dictionary = Balance.ACTIONS.get(action_id, {})
	var total: int = int(def.get("cooldown_ticks", 1))
	return clampf(float(sim.cooldown_left_ticks(action_id, region_id)) / float(maxi(total, 1)), 0.0, 1.0)


func perform_action(action_id: String, region_id: String) -> bool:
	if not can_perform(action_id, region_id) or has_pause_reason("event"):
		return false
	var result: Dictionary = sim.perform(action_id, region_id)
	if not bool(result.get("ok", false)):
		return false
	AudioSynth.play_click()
	vibrate_medium()
	EventBus.action_performed.emit(action_id, region_id)
	_publish_result(result)
	_publish_all()
	_check_achievements(false)
	save_game()
	return true


# --- Policy tree --------------------------------------------------------------------------

## "adopted" | "available" (prerequisites met) | "locked". "" before the first game.
func node_state(node_id: String) -> String:
	if sim == null:
		return ""
	return sim.node_state(node_id)


## 0..1 implementation progress of an adopted node (1 = full effect).
func node_ramp(node_id: String) -> float:
	if sim == null:
		return 0.0
	return sim.node_ramp(node_id)


## Current cost with modifiers: {"budget", "political", "science"} (missing keys = 0).
func node_cost(node_id: String) -> Dictionary:
	if sim == null:
		return {}
	return sim.node_cost(node_id)


func can_adopt(node_id: String) -> bool:
	return sim != null and running and not has_pause_reason("event") and sim.can_adopt(node_id)


func adopt_node(node_id: String) -> bool:
	if not can_adopt(node_id):
		return false
	var result: Dictionary = sim.adopt(node_id)
	if not bool(result.get("ok", false)):
		return false
	AudioSynth.play_policy_adopt()
	vibrate_medium()
	EventBus.node_adopted.emit(node_id)
	_publish_result(result)
	_publish_all()
	_check_achievements(false)
	save_game()
	return true


func adopted_nodes() -> Array:
	if sim == null:
		return []
	return sim.adopted_nodes()


# --- Crisis evolution ------------------------------------------------------------------------

## Ids of the resistances the crisis has evolved and the player has not cured.
func active_evolutions() -> Array:
	if sim == null:
		return []
	return sim.active_evolutions()


func can_synthesize_counter(evo_id: String) -> bool:
	return sim != null and running and not has_pause_reason("event") and sim.can_synthesize_counter(evo_id)


func synthesize_counter(evo_id: String) -> bool:
	if not can_synthesize_counter(evo_id):
		return false
	var res: Dictionary = sim.synthesize_counter(evo_id)
	if not bool(res.get("ok", false)):
		return false
	AudioSynth.play_cured()
	_publish_result(res)
	_publish_all()
	return true


func can_perform_project(project_id: String) -> bool:
	return sim != null and running and not has_pause_reason("event") and sim.can_perform_project(project_id)


func project_cooldown_left_ticks(project_id: String) -> int:
	if sim == null:
		return 0
	return sim.project_cooldown_left_ticks(project_id)


func perform_project(project_id: String) -> bool:
	if not can_perform_project(project_id):
		return false
	var res: Dictionary = sim.perform_project(project_id)
	if not bool(res.get("ok", false)):
		return false
	_publish_result(res)
	_publish_all()
	return true


## {"shares": {branch: 0..1}, "threshold": float, "moves": int, "min_moves": int} - how close
## the player's recent strategy is to provoking a resistance.
func evolution_pressure() -> Dictionary:
	if sim == null:
		return {}
	return sim.evolution_pressure()


# --- Decision events ---------------------------------------------------------------------------

## {"id": String, "region": String} while a card is waiting for a choice, else {}.
func current_event() -> Dictionary:
	if sim == null:
		return {}
	return sim.pending_event.duplicate()


func can_choose(choice_index: int) -> bool:
	return sim != null and running and sim.can_choose(choice_index)


func resolve_event(choice_index: int) -> bool:
	if not can_choose(choice_index):
		return false
	var event_id: String = str(sim.pending_event.get("id", ""))
	var result: Dictionary = sim.resolve_event(choice_index)
	if not bool(result.get("ok", false)):
		return false
	set_pause_reason("event", false)
	EventBus.event_resolved.emit(event_id, choice_index)
	_publish_result(result)
	_publish_all()
	return true


## Dev / demo hook (main.gd --event=<id>): shows that event card now, as if it was rolled.
func debug_force_event(event_id: String) -> void:
	if sim == null or not running:
		return
	var ev: Dictionary = sim.force_event(event_id)
	if ev.is_empty():
		return
	set_pause_reason("event", true)
	EventBus.event_triggered.emit(str(ev.get("id", "")))


# --- Data bubbles ---------------------------------------------------------------------------------

func active_bubbles() -> Array:
	if sim == null:
		return []
	return sim.active_bubbles()


func collect_bubble(bubble_id: int) -> bool:
	if sim == null or not running:
		return false
	var result: Dictionary = sim.collect_bubble(bubble_id)
	if not bool(result.get("ok", false)):
		return false
	var b_kind: String = str(result.get("kind", ""))
	vibrate_light()
	AudioSynth.play_bubble(b_kind == "science")
	EventBus.bubble_collected.emit(bubble_id, b_kind, float(result.get("amount", 0.0)))
	var snap: Dictionary = get_snapshot()
	EventBus.resources_changed.emit(float(snap.get("budget", 0.0)), float(snap.get("political", 0.0)), float(snap.get("science", 0.0)))
	return true


func spawn_tutorial_bubble(kind: String = "science", region_id: String = "antalya") -> void:
	if sim != null and running:
		var b: Dictionary = sim.spawn_tutorial_bubble(kind, region_id)
		EventBus.bubble_spawned.emit(b)


# --- COP31 Summits -------------------------------------------------------------------

func current_summit() -> Dictionary:
	if sim == null:
		return {}
	return sim.pending_summit.duplicate(true)


func resolve_summit(choice_idx: int) -> bool:
	if sim == null or not running:
		return false
	var res: Dictionary = sim.resolve_summit(choice_idx)
	if not bool(res.get("ok", false)):
		return false
	set_pause_reason("summit", false)
	EventBus.summit_resolved.emit(choice_idx)
	_publish_result(res)
	_publish_all()
	AudioSynth.play_policy_adopt()
	return true


# --- Read access for views ------------------------------------------------------------

## See docs/ARCHITECTURE.md "Snapshot" for keys. Empty before the first game.
func get_snapshot() -> Dictionary:
	if sim == null:
		return {}
	var snap: Dictionary = sim.snapshot()
	snap["speed_index"] = speed_index
	return snap


## See docs/ARCHITECTURE.md "Region dictionary" for keys. Empty if unknown.
func get_region(region_id: String) -> Dictionary:
	if sim == null:
		return {}
	return sim.region_dict(region_id)


## A copy of the region id list (the constant itself is read-only).
func region_ids() -> Array:
	return RegionData.IDS.duplicate()


## [[tick, sea_health, crisis], ...] sampled every Balance.HISTORY_EVERY ticks (live chart).
func get_history() -> Array:
	if sim == null:
		return []
	return sim.history.duplicate()


# --- Publishing -----------------------------------------------------------------------

func _publish_all() -> void:
	if sim == null:
		return
	for rid in RegionData.IDS:
		var region_id: String = rid
		EventBus.region_changed.emit(region_id, sim.region_dict(region_id))
	var snap: Dictionary = get_snapshot()
	EventBus.resources_changed.emit(float(snap.get("budget", 0.0)), float(snap.get("political", 0.0)), float(snap.get("science", 0.0)))
	EventBus.tick_done.emit(snap)
	if running:
		var defcon: int = sim.defcon_level()
		AudioSynth.set_siren(defcon <= 1)
		AudioSynth.set_heartbeat(sim.sea_health() < 30.0)


## Re-emits every list of a sim step / perform / adopt / resolve result.
func _publish_result(result: Dictionary) -> void:
	var spreads: Array = result.get("spreads", [])
	for s in spreads:
		var pair: Array = s
		EventBus.spread_happened.emit(str(pair[0]), str(pair[1]))
	var toasts: Array = result.get("toasts", [])
	for t in toasts:
		var item: Array = t
		var args: Dictionary = item[1]
		var key: String = str(item[0])
		if TOAST_KEY_FALLBACK.has(key) and not I18n.has_key(key):
			key = str(TOAST_KEY_FALLBACK[key])
		var sev_i: int = int(item[2])
		if sev_i >= 3:
			vibrate_heavy()
		EventBus.toast.emit(key, args, sev_i)
	var news_items: Array = result.get("news", [])
	for n in news_items:
		var item: Array = n
		var args: Dictionary = item[1]
		EventBus.news.emit(str(item[0]), args, int(item[2]))
	var evolved: Array = result.get("evolutions", [])
	for e in evolved:
		vibrate_heavy()
		EventBus.evolution_happened.emit(str(e))
	var cured: Array = result.get("cured", [])
	for c in cured:
		EventBus.evolution_cured.emit(str(c))
	var spawned: Array = result.get("bubbles_spawned", [])
	for b in spawned:
		var bubble: Dictionary = b
		EventBus.bubble_spawned.emit(bubble)
	var expired: Array = result.get("bubbles_expired", [])
	for x in expired:
		EventBus.bubble_expired.emit(int(x))


func _on_region_selected(region_id: String) -> void:
	selected_region = region_id
