extends Control

const TITLE_ART: Texture2D = preload("res://assets/world/title_splash.webp")
const TITLE_BGM: AudioStream = preload("res://BGM SONG/Headlights_on_Wet_Pavement.mp3")
const HERO_CONCEPT: Texture2D = preload("res://assets/characters/blue_wraith/idle/idle_00.webp")
const AnimFrames = preload("res://scripts/animation_frames.gd")
const WHITE_WRAITH_KEY_SHADER: Shader = preload("res://shaders/white_wraith_key.gdshader")
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
var character_portrait: TextureRect
var character_name_label: Label
var character_role_label: Label
var character_description_label: Label
var character_select_buttons: Array[Button] = []
var character_gear_rows: Array[Dictionary] = []
var blade_gear_detail: Label
var level_select_back_button: Button
var level_select_list: VBoxContainer
var level_select_buttons: Array[Button] = []
var title_music: AudioStreamPlayer
var controls_hint: Label
var mobile_menu: Control
var mobile_city_label: Label
var mobile_game_title: Label
var mobile_tagline: Label
var mobile_actions_scroll: ScrollContainer
var mobile_actions_list: VBoxContainer
var mobile_more_button: Button
var mobile_more_panel: PanelContainer
var mobile_more_list: VBoxContainer
var mobile_title_mode := false


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

	var replay_button := _menu_button("03   /   LEVEL SELECT")
	replay_button.name = "ReplayLevelsButton"
	replay_button.pressed.connect(_open_level_select)
	title_content.add_child(replay_button)
	buttons.append(replay_button)

	var boss_button := _menu_button("04   /   WARDEN CHALLENGE", false, true)
	boss_button.name = "BossTestButton"
	boss_button.pressed.connect(_start_boss_test)
	title_content.add_child(boss_button)
	buttons.append(boss_button)

	var character_button := _menu_button("05   /   PROFILE & GEAR")
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
	_build_mobile_title_menu()

	fade_layer = ColorRect.new()
	fade_layer.name = "TitleFade"
	fade_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_layer.color = Color("02070d")
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_layer)


func _build_mobile_title_menu() -> void:
	mobile_menu = Control.new()
	mobile_menu.name = "MobileTitleMenu"
	mobile_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mobile_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_menu.visible = false
	add_child(mobile_menu)

	var left_wash := ColorRect.new()
	left_wash.name = "MobileMenuWash"
	left_wash.anchor_right = 0.64
	left_wash.anchor_bottom = 1.0
	left_wash.color = Color(0.004, 0.012, 0.026, 0.58)
	left_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_menu.add_child(left_wash)

	mobile_city_label = _label("NIX CITY    /    DISTRICT 09", 14, CYAN)
	mobile_city_label.name = "MobileCityLabel"
	mobile_menu.add_child(mobile_city_label)
	mobile_game_title = _label("SWORD OF NIX", 58, PAPER)
	mobile_game_title.name = "MobileGameTitle"
	mobile_game_title.add_theme_constant_override("outline_size", 5)
	mobile_game_title.add_theme_color_override("font_outline_color", Color(0.0, 0.10, 0.16, 0.9))
	mobile_menu.add_child(mobile_game_title)
	mobile_tagline = _label("A city in shadow. One blade against the night.", 15, MUTED)
	mobile_tagline.name = "MobileTagline"
	mobile_tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mobile_menu.add_child(mobile_tagline)
	var divider := ColorRect.new()
	divider.name = "MobileMenuDivider"
	divider.color = Color(0.18, 0.83, 0.95, 0.78)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_menu.add_child(divider)

	mobile_actions_scroll = ScrollContainer.new()
	mobile_actions_scroll.name = "MobileMainActionsScroll"
	mobile_actions_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mobile_actions_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_menu.add_child(mobile_actions_scroll)
	mobile_actions_list = VBoxContainer.new()
	mobile_actions_list.name = "MobileMainActions"
	mobile_actions_list.add_theme_constant_override("separation", 11)
	mobile_actions_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_actions_scroll.add_child(mobile_actions_list)

	mobile_more_button = Button.new()
	mobile_more_button.name = "MobileMoreButton"
	mobile_more_button.text = "⋮"
	mobile_more_button.tooltip_text = "Settings and profile"
	mobile_more_button.focus_mode = Control.FOCUS_NONE
	mobile_more_button.add_theme_font_size_override("font_size", 38)
	mobile_more_button.add_theme_color_override("font_color", PAPER)
	var more_style := StyleBoxFlat.new()
	more_style.bg_color = Color(0.008, 0.045, 0.07, 0.82)
	more_style.border_color = Color(0.18, 0.83, 0.95, 0.9)
	more_style.set_border_width_all(2)
	more_style.set_corner_radius_all(12)
	mobile_more_button.add_theme_stylebox_override("normal", more_style)
	mobile_more_button.add_theme_stylebox_override("hover", more_style)
	var more_pressed := more_style.duplicate() as StyleBoxFlat
	more_pressed.bg_color = Color(0.08, 0.68, 0.78, 0.92)
	mobile_more_button.add_theme_stylebox_override("pressed", more_pressed)
	mobile_more_button.pressed.connect(_toggle_mobile_more_menu)
	mobile_menu.add_child(mobile_more_button)

	mobile_more_panel = PanelContainer.new()
	mobile_more_panel.name = "MobileMorePanel"
	mobile_more_panel.visible = false
	var popup_style := StyleBoxFlat.new()
	popup_style.bg_color = Color(0.008, 0.025, 0.045, 0.97)
	popup_style.border_color = Color(0.18, 0.83, 0.95, 0.94)
	popup_style.set_border_width_all(2)
	popup_style.set_corner_radius_all(8)
	popup_style.content_margin_left = 10
	popup_style.content_margin_right = 10
	popup_style.content_margin_top = 10
	popup_style.content_margin_bottom = 10
	mobile_more_panel.add_theme_stylebox_override("panel", popup_style)
	mobile_menu.add_child(mobile_more_panel)
	mobile_more_list = VBoxContainer.new()
	mobile_more_list.name = "MobileMoreActions"
	mobile_more_list.add_theme_constant_override("separation", 8)
	mobile_more_panel.add_child(mobile_more_list)

func _fit_mobile_menu_button(button: Button) -> void:
	for child in button.get_children():
		if child is Label:
			child.size.y = button.custom_minimum_size.y
			if child.text.strip_edges() not in ["/", "01", "02", "03", "04", "05", "06"]:
				child.position.x = 112.0
				child.size.x = maxf(120.0, button.custom_minimum_size.x - 126.0)
				child.add_theme_font_size_override("font_size", 18)
			else:
				child.add_theme_font_size_override("font_size", 16)


func _set_mobile_title_mode(touch_layout: bool) -> void:
	if touch_layout != mobile_title_mode:
		if touch_layout:
			for index in range(buttons.size()):
				var button := buttons[index]
				button.reparent(mobile_actions_list if index < 4 else mobile_more_list)
		else:
			mobile_more_panel.visible = false
			var divider := title_content.get_node_or_null("MenuDivider")
			var insert_at := divider.get_index() + 1 if divider else title_content.get_child_count()
			for index in range(buttons.size()):
				buttons[index].reparent(title_content)
				title_content.move_child(buttons[index], mini(insert_at + index, title_content.get_child_count() - 1))
		mobile_title_mode = touch_layout
	title_content.visible = not touch_layout
	mobile_menu.visible = touch_layout and not is_starting and not settings_layer.visible and not character_layer.visible and not level_select_layer.visible


func _toggle_mobile_more_menu() -> void:
	if not is_instance_valid(mobile_more_panel):
		return
	mobile_more_panel.visible = not mobile_more_panel.visible


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
	character_portrait = TextureRect.new()
	character_portrait.name = "HeroConceptPreview"
	character_portrait.texture = HERO_CONCEPT
	character_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_frame.add_child(character_portrait)

	var details := VBoxContainer.new()
	details.name = "CharacterDetails"
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 9)
	content.add_child(details)
	character_name_label = _label("KLINT", 31, PAPER)
	character_name_label.name = "CharacterName"
	details.add_child(character_name_label)
	character_role_label = _label("NIXBLADE   /   CYBER-NINJA INFILTRATOR", 13, CYAN)
	character_role_label.name = "CharacterRole"
	details.add_child(character_role_label)
	var selection_row := HBoxContainer.new()
	selection_row.name = "CharacterSelection"
	selection_row.add_theme_constant_override("separation", 10)
	details.add_child(selection_row)
	var blue_select := _menu_button("KLINT", true)
	blue_select.name = "SelectBlueWraith"
	blue_select.custom_minimum_size = Vector2(180, 44)
	blue_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blue_select.pressed.connect(func(): _select_player_character("blue_wraith"))
	selection_row.add_child(blue_select)
	character_select_buttons.append(blue_select)
	var white_select := _menu_button("QUEL")
	white_select.name = "SelectWhiteWraith"
	white_select.custom_minimum_size = Vector2(180, 44)
	white_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	white_select.pressed.connect(func(): _select_player_character("white_wraith"))
	selection_row.add_child(white_select)
	character_select_buttons.append(white_select)
	character_description_label = _label("A silent blade in a city that never sleeps.\nBuilt for speed, precision, and a clean escape.", 14, MUTED)
	character_description_label.name = "CharacterDescription"
	character_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(character_description_label)
	_add_rule(details)
	var equipment_heading := _label("EQUIPPED FIELD KIT", 15, CYAN)
	details.add_child(equipment_heading)
	blade_gear_detail = _add_gear_row(details, "01", "NIXBLADE KATANA", "Cyan plasma edge • primary melee weapon")
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
	_refresh_character_profile()


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
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_select_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "LevelSelectPanel"
	panel.custom_minimum_size = Vector2(540, 560)
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
	column.name = "LevelSelectContent"
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	column.add_child(_label("SELECT A LEVEL", 27, CYAN))
	column.add_child(_label("All campaign stages • cleared and unlocked levels can be replayed.", 13, MUTED))
	_add_rule(column)

	var scroll := ScrollContainer.new()
	scroll.name = "LevelListScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 320.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	level_select_list = VBoxContainer.new()
	level_select_list.name = "LevelList"
	level_select_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_select_list.add_theme_constant_override("separation", 7)
	scroll.add_child(level_select_list)
	level_select_buttons.clear()

	var completed: Array = SaveStore.get_completed_levels()
	var highest_unlocked := SaveStore.get_highest_unlocked_level()
	for level_index in range(SaveStore.LEVEL_NAMES.size()):
		var is_cleared := completed.has(level_index)
		var is_unlocked := level_index <= highest_unlocked
		var state_text := "CLEARED" if is_cleared else ("AVAILABLE" if is_unlocked else "LOCKED")
		var level_button := _menu_button("%02d   /   %s     ·  %s" % [level_index + 1, SaveStore.LEVEL_NAMES[level_index].to_upper(), state_text], is_unlocked)
		level_button.name = "Level%dButton" % level_index
		level_button.custom_minimum_size.y = 48.0
		level_button.disabled = not is_unlocked
		if is_unlocked:
			level_button.pressed.connect(_replay_saved_level.bind(level_index))
		else:
			level_button.tooltip_text = "Clear earlier stages to unlock this level."
		level_select_list.add_child(level_button)
		level_select_buttons.append(level_button)

	level_select_back_button = _menu_button("BACK TO TITLE")
	level_select_back_button.name = "LevelSelectBackButton"
	level_select_back_button.pressed.connect(_close_level_select)
	column.add_child(level_select_back_button)


func _open_level_select() -> void:
	settings_layer.visible = false
	character_layer.visible = false
	level_select_layer.visible = true
	_layout_title()
	for level_button in level_select_buttons:
		if not level_button.disabled:
			level_button.grab_focus()
			return
	level_select_back_button.grab_focus()

func _close_level_select() -> void:
	level_select_layer.visible = false
	_layout_title()
	var replay_button: Button = buttons[2] if buttons.size() > 2 else null
	if replay_button:
		replay_button.grab_focus()


func _replay_saved_level(level_index: int) -> void:
	if level_index < 0 or level_index >= SaveStore.LEVEL_SCENES.size() or level_index > SaveStore.get_highest_unlocked_level():
		return
	_transition_to_scene(SaveStore.LEVEL_SCENES[level_index], "REPLAYING " + SaveStore.LEVEL_NAMES[level_index].to_upper() + "…")


func _add_gear_row(parent: VBoxContainer, index: String, item_name: String, detail: String) -> Label:
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
	character_gear_rows.append({"name": name_label, "detail": detail_label})
	return detail_label


func _select_player_character(character_id: String) -> void:
	SaveStore.set_player_character(character_id)
	_refresh_character_profile()


func _refresh_character_profile() -> void:
	if not is_instance_valid(character_portrait):
		return
	var white_selected := SaveStore.get_player_character() == "white_wraith"
	character_name_label.text = "QUEL" if white_selected else "KLINT"
	character_role_label.text = "PALE EDGE   /   CYBER-NINJA INFILTRATOR" if white_selected else "NIXBLADE   /   CYBER-NINJA INFILTRATOR"
	character_description_label.text = "A pale silhouette against Nix City's neon rain.\nWhite armor and a bright blade cut through the dark." if white_selected else "A silent blade in a city that never sleeps.\nBuilt for speed, precision, and a clean escape."
	character_portrait.material = null
	if white_selected:
		character_portrait.texture = AnimFrames.get_white_wraith_frames("idle")[0]
		var key_material := ShaderMaterial.new()
		key_material.shader = WHITE_WRAITH_KEY_SHADER
		character_portrait.material = key_material
	else:
		character_portrait.texture = HERO_CONCEPT
	character_status.text = "ACTIVE OPERATIVE  •  QUEL" if white_selected else "ACTIVE OPERATIVE  •  KLINT"
	character_status.add_theme_color_override("font_color", Color("eef7ff") if white_selected else Color("76ffcb"))
	character_select_buttons[0].text = "✓  KLINT" if not white_selected else "KLINT"
	character_select_buttons[1].text = "✓  QUEL" if white_selected else "QUEL"
	if not character_gear_rows.is_empty():
		var names := ["PALE EDGE KATANA", "ARMORED HOOD + VISOR", "IVORY CHEST + SHOULDER PLATES", "WHITE FOREARM BRACERS", "WHITE SIGNAL SASH", "PALE UTILITY BELT + SHEATH", "WHITE KNEE, SHIN + BOOT ARMOR"]
		var blue_names := ["NIXBLADE KATANA", "ARMORED HOOD + VISOR", "COBALT CHEST + SHOULDER PLATES", "FOREARM BRACERS", "ENERGY SASH", "UTILITY BELT + KATANA SHEATH", "KNEE, SHIN + BOOT ARMOR"]
		var white_details := ["White energy edge • primary melee weapon", "Low-profile mask • luminous targeting slit", "Layered pale armor • white unit insignia", "Blade-side guard • polished white gauntlets", "White signal cloth • trailing scarf panels", "Field pouches • white katana sheath", "Lightweight white protection • silver accents"]
		var blue_details := ["Cyan plasma edge • primary melee weapon", "Low-profile mask • luminous targeting slit", "Layered impact armor • cyan unit insignia", "Blade-side guard • reinforced gauntlets", "Blue signal cloth • trailing scarf panels", "Field pouches • secured blade carry", "Lightweight protection • cyan accents"]
		for index in range(character_gear_rows.size()):
			var row: Dictionary = character_gear_rows[index]
			(row["name"] as Label).text = names[index] if white_selected else blue_names[index]
			(row["detail"] as Label).text = white_details[index] if white_selected else blue_details[index]


func _add_rule(parent: VBoxContainer) -> void:
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(410, 1)
	rule.color = Color(0.12, 0.56, 0.68, 0.55)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rule)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if is_instance_valid(mobile_more_panel) and mobile_more_panel.visible and event.keycode == KEY_ESCAPE:
			mobile_more_panel.visible = false
			get_viewport().set_input_as_handled()
		elif level_select_layer.visible and event.keycode == KEY_ESCAPE:
			_close_level_select()
			get_viewport().set_input_as_handled()
		elif character_layer.visible and event.keycode == KEY_ESCAPE:
			_close_character()
			get_viewport().set_input_as_handled()
		elif settings_layer.visible and event.keycode == KEY_ESCAPE:
			_close_settings()
			get_viewport().set_input_as_handled()
		elif not settings_layer.visible and not character_layer.visible and not level_select_layer.visible and not mobile_more_panel.visible and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
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
	if is_instance_valid(mobile_menu):
		mobile_menu.visible = false
	var start_button: Button = buttons[0] if not buttons.is_empty() else null
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
	if is_instance_valid(mobile_more_panel):
		mobile_more_panel.visible = false
	_layout_title()
	master_slider.grab_focus()


func _close_settings() -> void:
	settings_layer.visible = false
	_save_settings()
	_layout_title()
	var settings_button: Button = buttons[5] if buttons.size() > 5 else null
	if settings_button:
		settings_button.grab_focus()


func _open_character() -> void:
	settings_layer.visible = false
	character_layer.visible = true
	if is_instance_valid(mobile_more_panel):
		mobile_more_panel.visible = false
	_layout_title()
	if is_instance_valid(character_back_button):
		character_back_button.grab_focus()


func _close_character() -> void:
	character_layer.visible = false
	_layout_title()
	var character_button: Button = buttons[4] if buttons.size() > 4 else null
	if character_button:
		character_button.grab_focus()


func _layout_title() -> void:
	if title_content == null:
		return
	var viewport_size := get_viewport_rect().size
	var touch_layout := viewport_size.x < 1000.0 or OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	_set_mobile_title_mode(touch_layout)
	var scale_factor := clampf(minf(viewport_size.y / 820.0, viewport_size.x / 1280.0), 0.50, 1.0)
	if touch_layout:
		scale_factor = maxf(scale_factor, 0.96)
	title_content.add_theme_constant_override("separation", 5 if touch_layout else 9)
	title_content.scale = Vector2.ONE * scale_factor
	title_content.position = Vector2(maxf(30.0, viewport_size.x * 0.065), maxf(28.0, viewport_size.y * 0.06))
	title_content.size = Vector2(minf(500.0, viewport_size.x * 0.49) / scale_factor, viewport_size.y * 0.94 / scale_factor)
	for button in buttons:
		button.custom_minimum_size.y = (64.0 if button.text.contains("/") else 54.0) if touch_layout else (56.0 if button.text.contains("/") else 46.0)
		button.add_theme_font_size_override("font_size", 17 if touch_layout else 15)
		if touch_layout:
			for child in button.get_children():
				if child is Label:
					child.size.y = button.custom_minimum_size.y
					child.add_theme_font_size_override("font_size", 17 if child.text.strip_edges() != "/" else 18)
		else:
			button.custom_minimum_size.x = 500.0 if button.text.contains("/") else 420.0
			for child in button.get_children():
				if child is Label and child.text.strip_edges() not in ["/", "01", "02", "03", "04", "05", "06"]:
					child.position.x = 119.0
					child.size.x = 370.0
					child.add_theme_font_size_override("font_size", 15)
	if controls_hint != null:
		controls_hint.text = "MOVE / JUMP     •     DODGE     •     SKILL     •     SLASH" if touch_layout else "MOVE  A / D     •     JUMP  SPACE ×2     •     SLASH  J / X\nFOCUS  PRESS E (3s ACTIVE / 10s COOLDOWN)     •     DASH  D + R     •     STORY  F     •     PAUSE  ESC"
		controls_hint.add_theme_font_size_override("font_size", 16 if touch_layout else 12)
		var hint_width := minf(620.0, viewport_size.x * 0.51)
		controls_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		controls_hint.position = Vector2(-hint_width - 30.0, -44.0 if touch_layout else -70.0)
		controls_hint.size = Vector2(hint_width, 36.0 if touch_layout else 54.0)
		controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		# Touch players get larger on-screen controls in gameplay; keep the title clean.
		controls_hint.visible = not touch_layout
	var settings_controls := get_node_or_null("SettingsOverlay/CenterContainer/SettingsPanel/VBoxContainer/SettingsControls") as Label
	if settings_controls:
		settings_controls.text = "MOVE  ◀ / ▶     JUMP  ▲  (2×)\nDODGE     SKILL     SLASH" if touch_layout else "MOVE     A / D or Arrow Keys\nJUMP       Space  (up to two jumps)\nATTACK   J / X / Mouse Click\nFOCUS    Press E (3s active / 10s cooldown)       DASH  D + R\nSTORY     F       RESTART  Backspace       PAUSE   Esc"
		settings_controls.add_theme_font_size_override("font_size", 16 if touch_layout else 14)
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
	if touch_layout and is_instance_valid(mobile_menu):
		var margin := clampf(viewport_size.x * 0.045, 18.0, 56.0)
		var header_scale := clampf(minf(viewport_size.x / 700.0, viewport_size.y / 700.0), 0.68, 1.0)
		mobile_city_label.position = Vector2(margin, viewport_size.y * 0.045)
		mobile_city_label.size = Vector2(viewport_size.x * 0.54, 26.0 * header_scale)
		mobile_city_label.add_theme_font_size_override("font_size", maxi(12, roundi(14.0 * header_scale)))
		mobile_game_title.position = Vector2(margin, viewport_size.y * 0.085)
		mobile_game_title.size = Vector2(viewport_size.x * 0.65, viewport_size.y * 0.105)
		mobile_game_title.add_theme_font_size_override("font_size", clampi(roundi(viewport_size.x / 13.0), 34, 58))
		mobile_tagline.position = Vector2(margin + 2.0, viewport_size.y * 0.205)
		mobile_tagline.size = Vector2(viewport_size.x * 0.67, viewport_size.y * 0.055)
		mobile_tagline.add_theme_font_size_override("font_size", maxi(12, roundi(15.0 * header_scale)))
		var action_width := minf(viewport_size.x * 0.73, 690.0)
		var action_top := viewport_size.y * 0.285
		var action_height := viewport_size.y - action_top - margin
		mobile_actions_scroll.position = Vector2(margin, action_top)
		mobile_actions_scroll.size = Vector2(action_width, action_height)
		mobile_more_button.position = Vector2(viewport_size.x - margin - 64.0, margin)
		mobile_more_button.size = Vector2(64.0, 64.0)
		var popup_width := minf(320.0, viewport_size.x - margin * 2.0)
		mobile_more_panel.position = Vector2(viewport_size.x - margin - popup_width, margin + 76.0)
		mobile_more_panel.size = Vector2(popup_width, 146.0)
		for index in range(buttons.size()):
			var button := buttons[index]
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if index < 4:
				button.custom_minimum_size = Vector2(action_width, clampf(viewport_size.y * 0.095, 54.0, 70.0))
				_fit_mobile_menu_button(button)
			else:
				button.custom_minimum_size = Vector2(popup_width - 22.0, 54.0)
				_fit_mobile_menu_button(button)


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
