class_name NeonAnimationFrames
extends RefCounted

# Literal preloads keep every runtime frame discoverable by the Web exporter.
# Klint uses a cleaned, reflection-free atlas; Quel uses a separate atlas below.

const KLINT_MAIN_SHEET: Texture2D = preload("res://assets/characters/blue_wraith/source/klint_redesign.png")
const KLINT_ATLAS_SCALE := 0.6
static var _klint_frames: Dictionary = {}

static func get_klint_frames(animation_name: String) -> Array:
	if _klint_frames.is_empty():
		var animation_rows := {"idle": 0, "run": 1, "jump": 2, "attack": 3, "death": 4}
		var cell_size := KLINT_MAIN_SHEET.get_size() / Vector2(4.0, 5.0)
		for animation in animation_rows:
			var row := int(animation_rows[animation])
			var frames: Array[Texture2D] = []
			for column in range(4):
				var frame := AtlasTexture.new()
				frame.atlas = KLINT_MAIN_SHEET
				frame.region = Rect2(Vector2(column, row) * cell_size, cell_size)
				frame.filter_clip = true
				frames.append(frame)
			_klint_frames[animation] = frames
	return _klint_frames.get(animation_name, _klint_frames["idle"])

const HERO_JUMP = [
	preload("res://assets/characters/blue_wraith/jump/jump_00.webp"),
	preload("res://assets/characters/blue_wraith/jump/jump_01.webp"),
	preload("res://assets/characters/blue_wraith/jump/jump_02.webp"),
	preload("res://assets/characters/blue_wraith/jump/jump_03.webp"),
]

const WHITE_WRAITH_SHEET: Texture2D = preload("res://assets/characters/white_wraith_spritesheet.png")
static var _white_wraith_frames: Dictionary = {}

static func get_white_wraith_frames(animation_name: String) -> Array:
	if _white_wraith_frames.is_empty():
		var cell_size := Vector2(WHITE_WRAITH_SHEET.get_width() / 4.0, WHITE_WRAITH_SHEET.get_height() / 5.0)
		var animation_rows := {"idle": 0, "run": 1, "jump": 2, "attack": 3, "death": 4}
		for animation in animation_rows:
			var row := int(animation_rows[animation])
			var frames: Array[Texture2D] = []
			for column in range(4):
				var frame := AtlasTexture.new()
				frame.atlas = WHITE_WRAITH_SHEET
				frame.region = Rect2(Vector2(column, row) * cell_size, cell_size)
				frame.filter_clip = true
				frames.append(frame)
			_white_wraith_frames[animation] = frames
		return _white_wraith_frames.get(animation_name, _white_wraith_frames["idle"])
	return _white_wraith_frames.get(animation_name, _white_wraith_frames["idle"])

const RHEA_SHEET: Texture2D = preload("res://assets/characters/rhea/rhea_animation_atlas.png")
static var _rhea_frames: Dictionary = {}

static func get_rhea_frames(animation_name: String) -> Array:
	if _rhea_frames.is_empty():
		var cell_size := Vector2(RHEA_SHEET.get_width() / 4.0, RHEA_SHEET.get_height() / 5.0)
		var animation_rows := {"idle": 0, "run": 1, "jump": 2, "attack": 3, "death": 4}
		for animation in animation_rows:
			var row := int(animation_rows[animation])
			var frames: Array[Texture2D] = []
			for column in range(4):
				var frame := AtlasTexture.new()
				frame.atlas = RHEA_SHEET
				frame.region = Rect2(Vector2(column, row) * cell_size, cell_size)
				frame.filter_clip = true
				frames.append(frame)
			_rhea_frames[animation] = frames
	return _rhea_frames.get(animation_name, _rhea_frames["idle"])

const BLADE_IDLE = [
	preload("res://assets/characters/blade_guard/idle/idle_00.webp"),
]

const BLADE_RUN = [
	preload("res://assets/characters/blade_guard/run/run_00.webp"),
	preload("res://assets/characters/blade_guard/run/run_01.webp"),
	preload("res://assets/characters/blade_guard/run/run_02.webp"),
	preload("res://assets/characters/blade_guard/run/run_03.webp"),
	preload("res://assets/characters/blade_guard/run/run_04.webp"),
	preload("res://assets/characters/blade_guard/run/run_05.webp"),
	preload("res://assets/characters/blade_guard/run/run_06.webp"),
	preload("res://assets/characters/blade_guard/run/run_07.webp"),
	preload("res://assets/characters/blade_guard/run/run_08.webp"),
	preload("res://assets/characters/blade_guard/run/run_09.webp"),
	preload("res://assets/characters/blade_guard/run/run_10.webp"),
	preload("res://assets/characters/blade_guard/run/run_11.webp"),
	preload("res://assets/characters/blade_guard/run/run_12.webp"),
]

const BLADE_ATTACK = [
	preload("res://assets/characters/blade_guard/attack/attack_00.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_01.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_02.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_03.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_04.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_05.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_06.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_07.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_08.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_09.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_10.webp"),
	preload("res://assets/characters/blade_guard/attack/attack_11.webp"),
]

const BLADE_DEATH = [
	preload("res://assets/characters/blade_guard/death/death_00.webp"),
	preload("res://assets/characters/blade_guard/death/death_01.webp"),
	preload("res://assets/characters/blade_guard/death/death_02.webp"),
	preload("res://assets/characters/blade_guard/death/death_03.webp"),
	preload("res://assets/characters/blade_guard/death/death_04.webp"),
	preload("res://assets/characters/blade_guard/death/death_05.webp"),
	preload("res://assets/characters/blade_guard/death/death_06.webp"),
	preload("res://assets/characters/blade_guard/death/death_07.webp"),
	preload("res://assets/characters/blade_guard/death/death_08.webp"),
	preload("res://assets/characters/blade_guard/death/death_09.webp"),
	preload("res://assets/characters/blade_guard/death/death_10.webp"),
	preload("res://assets/characters/blade_guard/death/death_11.webp"),
]

const GUNNER_IDLE = [
	preload("res://assets/characters/gunner/idle/idle_00.webp"),
]

const GUNNER_WALK = [
	preload("res://assets/characters/gunner/walk/walk_00.webp"),
	preload("res://assets/characters/gunner/walk/walk_01.webp"),
	preload("res://assets/characters/gunner/walk/walk_02.webp"),
	preload("res://assets/characters/gunner/walk/walk_03.webp"),
	preload("res://assets/characters/gunner/walk/walk_04.webp"),
	preload("res://assets/characters/gunner/walk/walk_05.webp"),
	preload("res://assets/characters/gunner/walk/walk_06.webp"),
	preload("res://assets/characters/gunner/walk/walk_07.webp"),
	preload("res://assets/characters/gunner/walk/walk_08.webp"),
	preload("res://assets/characters/gunner/walk/walk_09.webp"),
	preload("res://assets/characters/gunner/walk/walk_10.webp"),
	preload("res://assets/characters/gunner/walk/walk_11.webp"),
	preload("res://assets/characters/gunner/walk/walk_12.webp"),
]

const GUNNER_SHOOT = [
	preload("res://assets/characters/gunner/shoot/shoot_00.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_01.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_02.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_03.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_04.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_05.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_06.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_07.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_08.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_09.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_10.webp"),
	preload("res://assets/characters/gunner/shoot/shoot_11.webp"),
]

const GUNNER_DEATH = [
	preload("res://assets/characters/gunner/death/death_00.webp"),
	preload("res://assets/characters/gunner/death/death_01.webp"),
	preload("res://assets/characters/gunner/death/death_02.webp"),
	preload("res://assets/characters/gunner/death/death_03.webp"),
	preload("res://assets/characters/gunner/death/death_04.webp"),
	preload("res://assets/characters/gunner/death/death_05.webp"),
	preload("res://assets/characters/gunner/death/death_06.webp"),
	preload("res://assets/characters/gunner/death/death_07.webp"),
	preload("res://assets/characters/gunner/death/death_08.webp"),
	preload("res://assets/characters/gunner/death/death_09.webp"),
	preload("res://assets/characters/gunner/death/death_10.webp"),
	preload("res://assets/characters/gunner/death/death_11.webp"),
]
