extends Control

const TITLE_ART: Texture2D = preload("res://assets/world/title_splash.webp")
const TITLE_BGM: AudioStream = preload("res://BGM SONG/Headlights_on_Wet_Pavement.mp3")
const HERO_CONCEPT: Texture2D = preload("res://assets/characters/blue_wraith/idle/idle_00.webp")
const MENU_FONT: Font = preload("res://assets/template/fonts/ui_regular.tres")
const SaveStore = preload("res://scripts/save_store.gd")
const TUTORIAL_SCENE := "res://scenes/tutorial.tscn"
const GAME_SCENE := "res://scenes/game.tscn"
const BOSS_SCENE := "res://scenes/boss_battle.tscn"
const SETTINGS_PATH := "user://sword_of_nix_settings.cfg"
const CYAN := Color("55eaff")
const PAPER := Color("e5f8ff")
const MUTED := Color("9ab3bf")
const INK := Color("04131b")

class NavButtonArt extends Control:
	var active := false
	var danger := false

	func _draw() -> void:
		var width := size.x
		var height := size.y
		if width < 10.0 or height < 10.0:
			return
		var tint := Color("ff4056") if danger else Color("08d6df")
		var fill := tint if active else Color(0.006, 0.024, 0.04, 0.82)
		var frame := PackedVector2Array([
			Vector2(1, 5), Vector2(6, 1), Vector2(width - 30, 1),
			Vector2(width - 1, 17), Vector2(width - 1, height - 11),
			Vector2(width - 11, height - 1), Vector2(1, height - 1)
		])
		draw_colored_polygon(frame, fill)
		var outline := frame.duplicate()
		outline.append(frame[0])
		draw_polyline(outline, tint if not active else Color(0.72, 1.0, 1.0, 1.0), 1.6, true)
		var number_block := PackedVector2Array([
			Vector2(2, 3), Vector2(73, 3), Vector2(57, height - 3), Vector2(2, height - 3)
		])
		draw_colored_polygon(number_block, Color(0.006, 0.025, 0.043, 0.96))
		draw_colored_polygon(PackedVector2Array([
			Vector2(74, 2), Vector2(109, 2), Vector2(91, height - 2), Vector2(57, height - 2)
		]), Color(tint.r, tint.g, tint.b, 0.38 if active else 0.12))
		draw_line(Vector2(74, 1), Vector2(57, height - 1), Color(tint.r, tint.g, tint.b, 0.92), 1.2, true)
		if active:
			draw_rect(Rect2(0, 5, 4, height - 10), Color("eaffff"))

class BrushMarks extends Control:
	func _draw() -> void:
		# Broad, uneven paint swashes keep the menu graphic and hand-painted.
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, 47), Vector2(24, 16), Vector2(168, 0), Vector2(200, 8),
			Vector2(158, 18), Vector2(31, 27), Vector2(188, 31), Vector2(143, 42),
			Vector2(23, 40), Vector2(88, 52)
		]), Color(0.10, 0.83, 1.0, 0.74))
		draw_colored_polygon(PackedVector2Array([
			Vector2(10, 7), Vector2(63, 1), Vector2(34, 6), Vector2(17, 13)
		]), Color(0.68, 0.97, 1.0, 0.8))
		draw_colored_polygon(PackedVector2Array([
			Vector2(12, 6), Vector2(126, 0), Vector2(164, 3), Vector2(95, 8), Vector2(29, 11)
		]), Color(0.15, 0.9, 1.0, 0.82))

var is_starting := false
var title_content: Control
var settings_layer: Control
var character_layer: Control
var level_select_layer: Control
var fade_layer: ColorRect
var buttons: Array[Button] = []
var master_slider: HSlider
var fullscreen_toggle: CheckButton
var character_status: Label
var character_back_button: Button
var level_select_back_button: Button
var title_music: AudioStreamPlayer
var controls_hint: Label


func _ready() -> void:
	_build_title()
	get_viewport().size_changed.connect(_layout_title)
	_load_settings()
	_start_title_music()
	_layout_title()
	fade_layer.modulate.a = 1.0
	create_tween().tween_property(fade_layer, "modulate:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if not buttons.is_empty():
		buttons[0].grab_focus()


func _build_title() -> void:
	var bg := TextureRect.new()
	bg.name = "TitleArt"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = TITLE_ART
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var wash := ColorRect.new()
	wash.name = "TitleWash"
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(0.006, 0.012, 0.027, 0.24)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wash)

	# A subtle dark plate keeps the left-side menu readable over any crop.
	var plate := ColorRect.new()
	plate.name = "MenuShadow"
	plate.anchor_right = 0.57
	plate.anchor_bottom = 1.0
	plate.color = Color(0.008, 0.014, 0.028, 0.40)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)

	title_content = VBoxContainer.new()
	title_content.name = "TitleContent"
	title_content.add_theme_constant_override("separation", 9)
	add_child(title_content)

	var eyebrow := _label("NIX CITY     /     DISTRICT 09", 13, CYAN)
	eyebrow.name = "CityLabel"
	title_content.add_child(eyebrow)

	var title_stack := VBoxContainer.new()
	title_stack.name = "TitleStack"
	title_stack.add_theme_constant_override("separation", -11)
	title_content.add_child(title_stack)
	var title_top := _label("SWORD", 76, PAPER)
	title_top.name = "GameTitle"
	title_top.add_theme_constant_override("outline_size", 5)
	title_top.add_theme_color_override("font_outline_color", Color(0.0, 0.10, 0.16, 0.9))
	title_stack.add_child(title_top)
	var title_bottom := _label("OF NIX", 76, CYAN)
	title_bottom.name = "GameTitleSecondLine"
	title_bottom.add_theme_constant_override("outline_size", 5)
	title_bottom.add_theme_color_override("font_outline_color", Color(0.0, 0.10, 0.16, 0.9))
	title_stack.add_child(title_bottom)

	var paint := BrushMarks.new()
	paint.name = "TitlePaintstroke"
	paint.position = Vector2(0, 156)
	paint.custom_minimum_size = Vector2(206, 54)
	paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_content.add_child(paint)

	var tagline := _label("A city in shadow. One blade against the night.", 15, MUTED)
	tagline.name = "Tagline"
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_content.add_child(tagline)

	var divider := ColorRect.new()
	divider.name = "MenuDivider"
	divider.custom_minimum_size = Vector2(360, 2)
	divider.color = Color(0.18, 0.83, 0.95, 0.72)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_content.add_child(divider)

	var continue_text := "ENTER THE CITY" if SaveStore.get_current_level() == 0 else "CONTINUE  //  " + SaveStore.get_current_level_name().to_upper()
	var run_button := _menu_button("01   /   " + continue_text, true)
	run_button.name = "StartButton"
	run_button.pressed.connect(_start_game)
	title_content.add_child(run_button)
	buttons.append(run_button)

	var story_button := _menu_button("02   /   STORY PROLOGUE")
	story_button.name = "StoryPrologueButton"
	story_button.pressed.connect(_start_tutorial)
	title_content.add_child(story_button)
	buttons.append(story_button)

	var replay_button := _menu_button("03   /   REPLAY CLEARED LEVELS")
	replay_button.name = "ReplayLevelsButton"
	replay_button.pressed.connect(_open_level_select)
	title_content.add_child(replay_button)
	buttons.append(replay_button)

	var boss_button := _menu_button("04   /   WARDEN CHALLENGE", false, true)
	boss_button.name = "BossTestButton"
	boss_button.pressed.connect(_start_boss_test)
	title_content.add_child(boss_button)
	buttons.append(boss_button)

	var character_button := _menu_button("05   /   CHARACTER & GEAR")
	character_button.name = "CharacterButton"
	character_button.pressed.connect(_open_character)
	title_content.add_child(character_button)
	buttons.append(character_button)

	var settings_button := _menu_button("06   /   SETTINGS")
	settings_button.name = "SettingsButton"
	settings_button.pressed.connect(_open_settings)
	title_content.add_child(settings_button)
	buttons.append(settings_button)

	controls_hint = _label("MOVE  A / D     •     JUMP  SPACE ×2     •     SLASH  J / X\nFOCUS  PRESS E (3s ACTIVE / 10s COOLDOWN)     •     DASH  D + R     •     STORY  F     •     PAUSE  ESC", 12, MUTED)
	controls_hint.name = "TitleControls"
	controls_hint.add_theme_constant_override("line_spacing", 5)
	controls_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	add_child(controls_hint)

	title_music = AudioStreamPlayer.new()
	title_music.name = "TitleMusic"
	title_music.bus = "Master"
	title_music.volume_db = -11.0
	var looping_title := TITLE_BGM.duplicate() as AudioStreamMP3
	looping_title.loop = true
	title_music.stream = looping_title
	add_child(title_music)

	_build_settings()
	_build_character_profile()
	_build_level_select()

	fade_layer = ColorRect.new()
	fade_layer.name = "TitleFade"
	fade_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_layer.color = Color("02070d")
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_layer)


func _build_settings() -> void:
	settings_layer = Control.new()
	settings_layer.name = "SettingsOverlay"
	settings_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_layer.visible = false
	settings_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(settings_layer)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.004, 0.008, 0.02, 0.84)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "SettingsPanel"
	panel.custom_minimum_size = Vector2(510, 500)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.018, 0.035, 0.06, 0.98)
	panel_style.border_color = Color(0.10, 0.72, 0.88, 0.86)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(3)
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)

	var heading := _label("SYSTEM SETTINGS", 32, PAPER)
	heading.name = "SettingsHeading"
	column.add_child(heading)
	var subheading := _label("Tune your signal before entering Nix City.", 14, MUTED)
	column.add_child(subheading)
	_add_rule(column)

	var volume_label := _label("MASTER VOLUME", 14, CYAN)
	column.add_child(volume_label)
	master_slider = HSlider.new()
	master_slider.name = "MasterVolume"
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = 0.01
	master_slider.custom_minimum_size = Vector2(420, 30)
	master_slider.value = _get_master_volume()
	master_slider.value_changed.connect(_set_master_volume)
	column.add_child(master_slider)

	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.name = "FullscreenToggle"
	fullscreen_toggle.text = "FULLSCREEN DISPLAY"
	fullscreen_toggle.add_theme_color_override("font_color", PAPER)
	fullscreen_toggle.toggled.connect(_set_fullscreen)
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	column.add_child(fullscreen_toggle)

	_add_rule(column)
	var controls_title := _label("FIELD CONTROLS", 14, CYAN)
	column.add_child(controls_title)
	var controls := _label("MOVE     A / D or Arrow Keys\nJUMP       Space  (up to two jumps)\nATTACK   J / X / Mouse Click\nFOCUS    Press E (3s active / 10s cooldown)       DASH  D + R\nSTORY     F       RESTART  Backspace       PAUSE   Esc", 14, MUTED)
	controls.name = "SettingsControls"
	controls.add_theme_constant_override("line_spacing", 5)
	column.add_child(controls)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var close_button := _menu_button("BACK TO TITLE", true)
	close_button.name = "SettingsBackButton"
	close_button.pressed.connect(_close_settings)
	column.add_child(close_button)


func _build_character_profile() -> void:
	character_layer = Control.new()
	character_layer.name = "CharacterOverlay"
	character_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character_layer.visible = false
	character_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(character_layer)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.004, 0.008, 0.02, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	character_layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "CharacterPanel"
	panel.custom_minimum_size = Vector2(900, 590)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.012, 0.025, 0.048, 0.99)
	panel_style.border_color = Color(0.08, 0.68, 0.9, 0.92)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var page := VBoxContainer.new()
	page.name = "VBoxContainer"
	page.add_theme_constant_override("separation", 12)
	panel.add_child(page)
	var heading := _label("OPERATIVE LOADOUT   /   NIX CITY", 26, CYAN)
	heading.name = "CharacterHeading"
	page.add_child(heading)
	_add_rule(page)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 24)
	page.add_child(content)

	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(315, 0)
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.005, 0.014, 0.028, 0.96)
	portrait_style.border_color = Color(0.05, 0.55, 0.76, 0.66)
	portrait_style.set_border_width_all(1)
	portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	content.add_child(portrait_frame)
	var portrait := TextureRect.new()
	portrait.name = "BlueHeroConcept"
	portrait.texture = HERO_CONCEPT
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_frame.add_child(portrait)

	var details := VBoxContainer.new()
	details.name = "CharacterDetails"
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 9)
	content.add_child(details)
	var name_label := _label("THE BLUE WRAITH", 31, PAPER)
	name_label.name = "CharacterName"
	details.add_child(name_label)
	var role := _label("NIXBLADE   /   CYBER-NINJA INFILTRATOR", 13, CYAN)
	role.name = "CharacterRole"
	details.add_child(role)
	var lore := _label("A silent blade in a city that never sleeps.\nBuilt for speed, precision, and a clean escape.", 14, MUTED)
	lore.name = "CharacterDescription"
	details.add_child(lore)
	_add_rule(details)
	var equipment_heading := _label("EQUIPPED FIELD KIT", 15, CYAN)
	details.add_child(equipment_heading)
	_add_gear_row(details, "01", "NIXBLADE KATANA", "Cyan plasma edge • primary melee weapon")
	_add_gear_row(details, "02", "ARMORED HOOD + VISOR", "Low-profile mask • luminous targeting slit")
	_add_gear_row(details, "03", "COBALT CHEST + SHOULDER PLATES", "Layered impact armor • cyan unit insignia")
	_add_gear_row(details, "04", "FOREARM BRACERS", "Blade-side guard • reinforced gauntlets")
	_add_gear_row(details, "05", "ENERGY SASH", "Blue signal cloth • trailing scarf panels")
	_add_gear_row(details, "06", "UTILITY BELT + KATANA SHEATH", "Field pouches • secured blade carry")
	_add_gear_row(details, "07", "KNEE, SHIN + BOOT ARMOR", "Lightweight protection • cyan accents")

	character_status = _label("ACTIVE OPERATIVE  •  CURRENT PLAYER", 12, Color("76ffcb"))
	character_status.name = "CharacterStatus"
	details.add_child(character_status)
	character_back_button = _menu_button("BACK TO TITLE", false)
	character_back_button.name = "CharacterBackButton"
	character_back_button.pressed.connect(_close_character)
	details.add_child(character_back_button)


func _build_level_select() -> void:
	level_select_layer = Control.new()
	level_select_layer.name = "LevelSelectOverlay"
	level_select_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	level_select_layer.visible = false
	level_select_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(level_select_layer)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.004, 0.008, 0.02, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select_layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_select_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "LevelSelectPanel"
	panel.custom_minimum_size = Vector2(540, 420)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.025, 0.048, 0.99)
	style.border_color = Color(0.08, 0.68, 0.9, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	column.add_child(_label("REPLAY CLEARED LEVELS", 27, CYAN))
	column.add_child(_label("Choose any stage you have already completed.", 13, MUTED))
	_add_rule(column)

	var completed: Array = SaveStore.get_completed_levels()
	if completed.is_empty():
		column.add_child(_label("No cleared levels yet. Complete a level to unlock replay.", 14, PAPER))
	else:
		for level_index in completed:
			var safe_index := int(level_index)
			var replay := _menu_button("REPLAY   /   " + SaveStore.LEVEL_NAMES[safe_index].to_upper(), true)
			replay.name = "ReplayLevel%dButton" % safe_index
			replay.pressed.connect(_replay_saved_level.bind(safe_index))
			column.add_child(replay)

	level_select_back_button = _menu_button("BACK TO TITLE")
	level_select_back_button.name = "LevelSelectBackButton"
	level_select_back_button.pressed.connect(_close_level_select)
	column.add_child(level_select_back_button)


func _open_level_select() -> void:
	settings_layer.visible = false
	character_layer.visible = false
	level_select_layer.visible = true
	var first_replay: Button
	for child in level_select_layer.get_node("CenterContainer/LevelSelectPanel/VBoxContainer").get_children():
		if child is Button and child.name.begins_with("ReplayLevel"):
			first_replay = child
			break
	if first_replay:
		first_replay.grab_focus()
	else:
		level_select_back_button.grab_focus()


func _close_level_select() -> void:
	level_select_layer.visible = false
	var replay_button := get_node_or_null("TitleContent/ReplayLevelsButton") as Button
	if replay_button:
		replay_button.grab_focus()


func _replay_saved_level(level_index: int) -> void:
	if level_index < 0 or level_index >= SaveStore.LEVEL_SCENES.size():
		return
	_transition_to_scene(SaveStore.LEVEL_SCENES[level_index], "REPLAYING " + SaveStore.LEVEL_NAMES[level_index].to_upper() + "…")


func _add_gear_row(parent: VBoxContainer, index: String, item_name: String, detail: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var number := _label(index, 14, CYAN)
	number.custom_minimum_size.x = 26
	row.add_child(number)
	var item := VBoxContainer.new()
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_constant_override("separation", 1)
	row.add_child(item)
	var name_label := _label(item_name, 13, PAPER)
	item.add_child(name_label)
	var detail_label := _label(detail, 11, MUTED)
	item.add_child(detail_label)


func _add_rule(parent: VBoxContainer) -> void:
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(410, 1)
	rule.color = Color(0.12, 0.56, 0.68, 0.55)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rule)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if level_select_layer.visible and event.keycode == KEY_ESCAPE:
			_close_level_select()
			get_viewport().set_input_as_handled()
		elif character_layer.visible and event.keycode == KEY_ESCAPE:
			_close_character()
			get_viewport().set_input_as_handled()
		elif settings_layer.visible and event.keycode == KEY_ESCAPE:
			_close_settings()
			get_viewport().set_input_as_handled()
		elif not settings_layer.visible and not character_layer.visible and not level_select_layer.visible and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			_start_game()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed and not settings_layer.visible and not character_layer.visible and not level_select_layer.visible:
		if event.button_index == JOY_BUTTON_START:
			_start_game()
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventJoypadButton):
		if is_instance_valid(title_music) and not title_music.playing:
			title_music.play()


func _start_title_music() -> void:
	if is_instance_valid(title_music) and not title_music.playing:
		title_music.play()


func get_start_scene_path() -> String:
	return SaveStore.get_continue_scene_path()


func _start_game() -> void:
	_transition_to_scene(get_start_scene_path(), "ENTERING NIX CITY…")


func _start_tutorial() -> void:
	_transition_to_scene(TUTORIAL_SCENE, "OPENING STORY PROLOGUE…")


func _start_boss_test() -> void:
	_transition_to_scene(BOSS_SCENE, "ENTERING WARDEN CHALLENGE…")


func _transition_to_scene(scene_path: String, prompt_text: String) -> void:
	if is_starting:
		return
	is_starting = true
	settings_layer.visible = false
	character_layer.visible = false
	level_select_layer.visible = false
	var start_button := get_node_or_null("TitleContent/StartButton") as Button
	if start_button:
		start_button.text = prompt_text
	for button in buttons:
		button.disabled = true
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.30)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))


func _open_settings() -> void:
	character_layer.visible = false
	settings_layer.visible = true
	master_slider.grab_focus()


func _close_settings() -> void:
	settings_layer.visible = false
	_save_settings()
	var settings_button := get_node_or_null("TitleContent/SettingsButton") as Button
	if settings_button:
		settings_button.grab_focus()


func _open_character() -> void:
	settings_layer.visible = false
	character_layer.visible = true
	if is_instance_valid(character_back_button):
		character_back_button.grab_focus()


func _close_character() -> void:
	character_layer.visible = false
	var character_button := get_node_or_null("TitleContent/CharacterButton") as Button
	if character_button:
		character_button.grab_focus()


func _layout_title() -> void:
	if title_content == null:
		return
	var viewport_size := get_viewport_rect().size
	var scale_factor := clampf(minf(viewport_size.y / 820.0, viewport_size.x / 1280.0), 0.50, 1.0)
	title_content.scale = Vector2.ONE * scale_factor
	title_content.position = Vector2(maxf(30.0, viewport_size.x * 0.065), maxf(28.0, viewport_size.y * 0.06))
	title_content.size = Vector2(minf(500.0, viewport_size.x * 0.49) / scale_factor, viewport_size.y * 0.94 / scale_factor)
	if controls_hint != null:
		var hint_width := minf(620.0, viewport_size.x * 0.51)
		controls_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		controls_hint.position = Vector2(-hint_width - 30.0, -70.0)
		controls_hint.size = Vector2(hint_width, 54.0)
		controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if settings_layer != null:
		var panel := settings_layer.get_node_or_null("CenterContainer/SettingsPanel") as Control
		if panel:
			panel.custom_minimum_size = Vector2(minf(510.0, viewport_size.x - 32.0), minf(500.0, viewport_size.y - 32.0))
	if character_layer != null:
		var profile := character_layer.get_node_or_null("CenterContainer/CharacterPanel") as Control
		if profile:
			profile.custom_minimum_size = Vector2(minf(900.0, viewport_size.x - 32.0), minf(590.0, viewport_size.y - 32.0))
	if level_select_layer != null:
		var replay_panel := level_select_layer.get_node_or_null("CenterContainer/LevelSelectPanel") as Control
		if replay_panel:
			replay_panel.custom_minimum_size = Vector2(minf(540.0, viewport_size.x - 32.0), minf(620.0, viewport_size.y - 32.0))


func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_override("font", MENU_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.015, 0.025, 0.84))
	return label


func _menu_button(text_value: String, primary := false, danger := false) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(500, 56) if text_value.contains("/") else Vector2(420, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 15 if primary else 13)
	button.add_theme_font_override("font", MENU_FONT)
	if text_value.contains("/"):
		var slash := text_value.find("/")
		var number_text := text_value.substr(0, slash).strip_edges()
		var caption_text := text_value.substr(slash + 1).strip_edges()
		var art := NavButtonArt.new()
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.danger = danger
		art.active = false
		button.add_child(art)
		var number_label := _label(number_text, 16, CYAN)
		number_label.position = Vector2(18, 0)
		number_label.size = Vector2(48, 56)
		number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(number_label)
		var divider_label := _label("/", 16, MUTED)
		divider_label.position = Vector2(80, 0)
		divider_label.size = Vector2(20, 56)
		divider_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		divider_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(divider_label)
		var caption := _label(caption_text, 15, PAPER if primary else MUTED)
		caption.position = Vector2(119, 0)
		caption.size = Vector2(370, 56)
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(caption)
		button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		for state_color in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
			button.add_theme_color_override(state_color, Color(0, 0, 0, 0))
		var update_state := func(active: bool) -> void:
			art.active = active
			art.queue_redraw()
			var label_color := INK if art.active else (Color("ff7480") if danger else MUTED)
			caption.add_theme_color_override("font_color", label_color)
			number_label.add_theme_color_override("font_color", CYAN if not art.active else Color("d9ffff"))
			divider_label.add_theme_color_override("font_color", label_color)
		button.focus_entered.connect(func(): update_state.call(true))
		button.focus_exited.connect(func(): update_state.call(false))
		button.mouse_entered.connect(func(): update_state.call(true))
		button.mouse_exited.connect(func(): update_state.call(button.has_focus()))
		return button
	var tint := Color("55eaff") if primary else (Color("ff687a") if danger else Color("9ab3bf"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.008, 0.045, 0.07, 0.68)
	normal.border_color = Color(tint.r, tint.g, tint.b, 0.62)
	normal.border_width_left = 3 if primary else 1
	normal.border_width_bottom = 1
	normal.set_corner_radius_all(2)
	normal.content_margin_left = 18
	normal.content_margin_right = 14
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = tint
	hover.border_color = Color(0.82, 0.98, 1.0, 0.96) if not danger else Color("ffb3bd")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", tint)
	button.add_theme_color_override("font_hover_color", Color("031117"))
	button.add_theme_color_override("font_focus_color", Color("031117"))
	button.add_theme_color_override("font_pressed_color", Color("031117"))
	return button


func _get_master_volume() -> float:
	var master := AudioServer.get_bus_index("Master")
	if master < 0 or AudioServer.is_bus_mute(master):
		return 0.0 if master >= 0 else 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(master))


func _set_master_volume(value: float) -> void:
	var master := AudioServer.get_bus_index("Master")
	if master >= 0:
		AudioServer.set_bus_volume_db(master, linear_to_db(maxf(value, 0.001)))
		AudioServer.set_bus_mute(master, is_zero_approx(value))
	_save_settings()


func _set_fullscreen(value: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	var volume_value: Variant = config.get_value("audio", "master_volume", _get_master_volume())
	if (volume_value is int or volume_value is float) and is_finite(float(volume_value)):
		var master := AudioServer.get_bus_index("Master")
		if master >= 0:
			AudioServer.set_bus_volume_db(master, linear_to_db(maxf(float(volume_value), 0.001)))
			AudioServer.set_bus_mute(master, is_zero_approx(float(volume_value)))
	var fullscreen_value: Variant = config.get_value("display", "fullscreen", false)
	if fullscreen_value is bool:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_value else DisplayServer.WINDOW_MODE_WINDOWED)
	if is_instance_valid(master_slider):
		master_slider.value = _get_master_volume()
	if is_instance_valid(fullscreen_toggle):
		fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value if is_instance_valid(master_slider) else _get_master_volume())
	config.set_value("display", "fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.save(SETTINGS_PATH)
