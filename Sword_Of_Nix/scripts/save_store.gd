class_name NeonSaveStore
extends RefCounted

const SAVE_PATH := "user://zero_hour_save.json"
const VERSION := 3
const LEVEL_NAMES: Array[String] = ["Story Prologue", "Nix City Rooftop", "Akai Hideout", "Warden Battle"]
const LEVEL_SCENES: Array[String] = [
	"res://scenes/tutorial.tscn",
	"res://scenes/game.tscn",
	"res://scenes/interior_level.tscn",
	"res://scenes/boss_battle.tscn"
]

static func get_best_time() -> float:
	return float(_load_data().get("best_time", 0.0))

static func submit_time(seconds: float) -> bool:
	var data := _load_data()
	var previous := float(data.get("best_time", 0.0))
	if previous <= 0.0 or seconds < previous:
		data["best_time"] = seconds
		_save_data(data)
		return true
	return false

static func has_completed_tutorial() -> bool:
	return bool(_load_data().get("tutorial_complete", false))

static func mark_tutorial_complete() -> void:
	mark_level_complete(0)

static func set_tutorial_complete(completed: bool) -> void:
	var data := _load_data()
	data["tutorial_complete"] = completed
	if completed:
		_add_completed_level(data, 0)
		data["unlocked_level"] = maxi(int(data.get("unlocked_level", 0)), 1)
		data["current_level"] = maxi(int(data.get("current_level", 0)), 1)
	else:
		data["completed_levels"] = []
		data["unlocked_level"] = 0
		data["current_level"] = 0
	_save_data(data)

static func get_current_level() -> int:
	return int(_load_data().get("current_level", 0))

static func get_highest_unlocked_level() -> int:
	return int(_load_data().get("unlocked_level", 0))

static func get_completed_levels() -> Array:
	return _load_data().get("completed_levels", [])

static func get_current_level_name() -> String:
	return LEVEL_NAMES[clampi(get_current_level(), 0, LEVEL_NAMES.size() - 1)]

static func get_continue_scene_path() -> String:
	return LEVEL_SCENES[clampi(get_current_level(), 0, LEVEL_SCENES.size() - 1)]

static func set_current_level(level_index: int) -> void:
	var data := _load_data()
	var bounded_level := clampi(level_index, 0, LEVEL_SCENES.size() - 1)
	if bounded_level > int(data.get("unlocked_level", 0)):
		return
	data["current_level"] = bounded_level
	_save_data(data)

static func mark_level_complete(level_index: int) -> void:
	var data := _load_data()
	var completed_index := clampi(level_index, 0, LEVEL_SCENES.size() - 1)
	_add_completed_level(data, completed_index)
	if completed_index == 0:
		data["tutorial_complete"] = true
	var next_level := mini(completed_index + 1, LEVEL_SCENES.size() - 1)
	data["unlocked_level"] = maxi(int(data.get("unlocked_level", 0)), next_level)
	data["current_level"] = maxi(int(data.get("current_level", 0)), next_level)
	_save_data(data)

static func _add_completed_level(data: Dictionary, level_index: int) -> void:
	var completed = data.get("completed_levels", [])
	if not completed is Array:
		completed = []
	if not completed.has(level_index):
		completed.append(level_index)
	data["completed_levels"] = completed

static func _default_data() -> Dictionary:
	return {
		"version": VERSION,
		"best_time": 0.0,
		"tutorial_complete": false,
		"current_level": 0,
		"unlocked_level": 0,
		"completed_levels": []
	}

static func _load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return _default_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return _default_data()
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _default_data()
	var stored_version := int(parsed.get("version", 0))
	if stored_version == VERSION:
		var tutorial_complete := bool(parsed.get("tutorial_complete", false))
		var completed: Array = []
		var raw_completed = parsed.get("completed_levels", [])
		if raw_completed is Array:
			for level in raw_completed:
				var index := int(level)
				if index >= 0 and index < LEVEL_SCENES.size() and not completed.has(index):
					completed.append(index)
		if tutorial_complete and not completed.has(0):
			completed.append(0)
		var unlocked := clampi(int(parsed.get("unlocked_level", 0)), 0, LEVEL_SCENES.size() - 1)
		if tutorial_complete:
			unlocked = maxi(unlocked, 1)
		return {
			"version": VERSION,
			"best_time": float(parsed.get("best_time", 0.0)),
			"tutorial_complete": tutorial_complete,
			"current_level": clampi(int(parsed.get("current_level", 0)), 0, unlocked),
			"unlocked_level": unlocked,
			"completed_levels": completed
		}
	if stored_version == 2:
		var old_tutorial_complete := bool(parsed.get("tutorial_complete", false))
		var migrated := _default_data()
		migrated["best_time"] = float(parsed.get("best_time", 0.0))
		migrated["tutorial_complete"] = old_tutorial_complete
		if old_tutorial_complete:
			migrated["completed_levels"] = [0]
			migrated["unlocked_level"] = 1
			migrated["current_level"] = 1
		_save_data(migrated)
		return migrated
	if stored_version == 1:
		var migrated_v1 := _default_data()
		migrated_v1["best_time"] = float(parsed.get("best_time", 0.0))
		_save_data(migrated_v1)
		return migrated_v1
	return _default_data()

static func _save_data(data: Dictionary) -> void:
	data["version"] = VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
