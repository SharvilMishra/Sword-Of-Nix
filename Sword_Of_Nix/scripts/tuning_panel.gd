extends CanvasLayer

const TuningStore = preload("res://scripts/tuning_store.gd")

const TAB_DEFINITIONS := [
		{
			"id": "Player",
			"title": "Character",
		"sections": [
			{
					"title": "Movement",
				"controls": [
						["run_speed", "Run Speed", 180.0, 480.0, 5.0, "px/s"],
						["acceleration", "Acceleration", 700.0, 3200.0, 50.0, ""],
						["gravity", "Gravity", 800.0, 2300.0, 20.0, ""],
						["jump_force", "Jump Strength", 480.0, 1000.0, 10.0, ""],
						["jump_launch_multiplier", "Takeoff Speed", 0.80, 1.60, 0.05, "×"],
						["jump_rise_gravity_multiplier", "Ascent Gravity", 0.80, 2.20, 0.05, "×"],
						["jump_fall_gravity_multiplier", "Fall Gravity", 0.80, 2.20, 0.05, "×"],
						["jump_animation_fps", "Jump Animation", 8.0, 36.0, 1.0, "FPS"]
				]
			},
		]
	},
	{
		"id": "Combat",
			"title": "Combat",
		"sections": [
			{
					"title": "Attack Animation",
				"controls": [
						["attack_cooldown", "Attack Cooldown", 0.12, 0.80, 0.01, "s"],
						["slash_dash_distance", "Slash Dash Distance", 0.0, 420.0, 5.0, "px"],
						["slash_dash_speed", "Slash Dash Speed", 500.0, 2200.0, 25.0, "px/s"]
				]
			},
			{
					"title": "Attack Hitbox",
				"controls": [
						["attack_hitbox_forward", "Forward Length", 50.0, 220.0, 2.0, "px"],
						["attack_hitbox_back", "Backward Length", 0.0, 60.0, 1.0, "px"],
						["attack_hitbox_height", "Total Height", 30.0, 150.0, 2.0, "px"]
				]
			},
			{
					"title": "Character Hurtbox",
				"controls": [
						["player_hurtbox_width", "Body Width", 20.0, 44.0, 1.0, "px"],
						["player_hurtbox_height", "Body Height", 48.0, 100.0, 1.0, "px"]
				]
			},
			{
					"title": "Parry Feedback // All Scenes",
				"controls": [
						["melee_parry_slow_duration", "Parry Slow-Motion Duration", 0.0, 2.0, 0.05, "s"],
						["melee_parry_time_scale", "Parry Time Scale", 0.10, 1.0, 0.05, "×"],
						["parry_zoom_amount", "Center Zoom Strength", 0.0, 0.25, 0.01, "×"],
						["parry_zoom_duration", "Center Zoom Duration", 0.0, 0.80, 0.02, "s"]
				]
			}
		]
	},
	{
		"id": "Enemies",
				"title": "Enemies",
			"sections": [
				{
						"title": "Shared Enemy Hurtbox",
					"controls": [
							["enemy_hurtbox_width", "Body Width", 18.0, 50.0, 1.0, "px"],
							["enemy_hurtbox_height", "Body Height", 50.0, 120.0, 1.0, "px"]
					]
				},
				{
						"title": "Blade Guard",
				"controls": [
						["blade_move_speed", "Chase Speed", 40.0, 240.0, 2.0, "px/s"],
						["blade_patrol_speed", "Patrol Speed", 10.0, 120.0, 2.0, "px/s"],
						["blade_aggression", "Aggression", 0.35, 2.50, 0.05, "×"],
						["blade_alert_range", "Detection Range", 220.0, 1100.0, 10.0, "px"]
				]
			},
				{
						"title": "Gunner",
					"controls": [
							["gunner_patrol_speed", "Patrol Speed", 10.0, 120.0, 2.0, "px/s"],
							["gunner_aggression", "Aggression", 0.35, 2.50, 0.05, "×"],
							["gunner_alert_range", "Detection Range", 300.0, 1500.0, 10.0, "px"],
							["gunner_projectile_speed", "Bullet Speed", 240.0, 1000.0, 10.0, "px/s"]
					]
				},
					{
							"title": "The Warden // Boss Difficulty",
						"controls": [
							["boss_max_health", "Health Pips", 8.0, 40.0, 1.0, "pips"],
							["boss_katana_damage", "Slash Damage", 1.0, 6.0, 1.0, "pips"],
							["boss_melee_parry_damage", "Melee Parry Damage", 1.0, 8.0, 1.0, "pips"],
						["boss_reflected_damage", "Reflected Bullet Damage", 1.0, 6.0, 1.0, "pips"],
						["boss_action_interval", "Move Interval", 0.30, 1.20, 0.02, "s"],
					["boss_dash_speed", "Approach Speed", 500.0, 1600.0, 20.0, "px/s"],
					["boss_projectile_speed", "Volley Speed", 380.0, 1100.0, 10.0, "px/s"]
				]
				}
		]
	},
	{
		"id": "AudioVisual",
				"title": "Audiovisual",
			"sections": [
				{
						"title": "Camera",
					"controls": [
							["camera_distance", "Camera Distance", 0.75, 1.60, 0.05, "×"]
					]
				},
				{
						"title": "Character Rim Light",
				"controls": [
						["rim_width", "Outline Thickness", 0.5, 8.0, 0.1, "px"],
						["rim_brightness", "Outline Brightness", 0.0, 1.5, 0.05, "×"]
				]
			},
			{
					"title": "Audio Mix",
				"controls": [
						["bgm_volume_db", "Music Volume", -36.0, 3.0, 0.5, "dB"],
						["sfx_volume_db", "SFX Volume Offset", -24.0, 6.0, 0.5, "dB"],
						["rain_volume_db", "Rain Volume", -40.0, 0.0, 0.5, "dB"]
				]
			}
		]
	}
]

var panel: PanelContainer
var value_labels: Dictionary = {}
var value_suffixes: Dictionary = {}
var export_status: Label
var last_export_path := ""
var tab_buttons: Array[Button] = []
var tab_pages: Array[Control] = []
var tab_scrolls: Array[ScrollContainer] = []
var active_tab := 0
var tab_group: ButtonGroup

func _ready() -> void:
	layer = 90
	_build_panel()
	panel.visible = false
	I18n.language_changed.connect(_refresh_localized_values)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_F1 or event.keycode == KEY_P):
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()

func _build_panel() -> void:
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-524, 18)
	panel.size = Vector2(500, 684)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.032, 0.046, 0.98)
	style.border_color = Color("247c8b")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 7)
	margin.add_child(shell)

	var title := Label.new()
	title.text = "Live Tuning  //  F1 or P"
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color("54e8f8"))
	shell.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Hitboxes appear while the panel is open; the mouse wheel only scrolls the page."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color("78939c"))
	shell.add_child(subtitle)

	tab_group = ButtonGroup.new()
	tab_group.allow_unpress = false
	var tab_bar := HBoxContainer.new()
	tab_bar.name = "TweakTabBar"
	tab_bar.add_theme_constant_override("separation", 4)
	shell.add_child(tab_bar)

	var page_host := VBoxContainer.new()
	page_host.name = "TweakPageHost"
	page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(page_host)

	for tab_index in range(TAB_DEFINITIONS.size()):
		var tab_data: Dictionary = TAB_DEFINITIONS[tab_index]
		var tab_button := _make_tab_button(String(tab_data["id"]), String(tab_data["title"]))
		tab_button.button_group = tab_group
		var captured_index := tab_index
		tab_button.pressed.connect(func(): select_tab(captured_index))
		tab_bar.add_child(tab_button)
		tab_buttons.append(tab_button)

		var scroll := ScrollContainer.new()
		scroll.name = "TweakScroll%s" % String(tab_data["id"])
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page_host.add_child(scroll)
		tab_pages.append(scroll)
		tab_scrolls.append(scroll)

		var content := VBoxContainer.new()
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_theme_constant_override("separation", 7)
		scroll.add_child(content)
		for section in tab_data["sections"]:
			_add_section(content, String(section["title"]), section["controls"])

	var footer_line := HSeparator.new()
	shell.add_child(footer_line)

	var footer_actions := HBoxContainer.new()
	footer_actions.add_theme_constant_override("separation", 8)
	shell.add_child(footer_actions)

	var export_button := Button.new()
	export_button.name = "ExportTweaksButton"
	export_button.text = "Export Tuning File"
	export_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	export_button.custom_minimum_size.y = 38
	var export_normal := StyleBoxFlat.new()
	export_normal.bg_color = Color("15343d")
	export_normal.border_color = Color("35d9eb")
	export_normal.set_border_width_all(1)
	export_normal.set_corner_radius_all(3)
	var export_hover := export_normal.duplicate() as StyleBoxFlat
	export_hover.bg_color = Color("35d9eb")
	export_button.add_theme_stylebox_override("normal", export_normal)
	export_button.add_theme_stylebox_override("hover", export_hover)
	export_button.add_theme_color_override("font_hover_color", Color("071319"))
	export_button.pressed.connect(_export_values)
	footer_actions.add_child(export_button)

	var reset_button := Button.new()
	reset_button.name = "ResetTweaksButton"
	reset_button.text = "Restore Defaults"
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.custom_minimum_size.y = 38
	reset_button.pressed.connect(_reset_values)
	footer_actions.add_child(reset_button)

	export_status = Label.new()
	export_status.name = "ExportStatus"
	export_status.text = "The exported tuning file includes all tabs."
	export_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	export_status.add_theme_font_size_override("font_size", 10)
	export_status.add_theme_color_override("font_color", Color("78939c"))
	shell.add_child(export_status)

	select_tab(0)

func _make_tab_button(tab_id: String, label_text: String) -> Button:
	var button := Button.new()
	button.name = "TweakTab%s" % tab_id
	button.text = label_text
	button.toggle_mode = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 36
	button.add_theme_font_size_override("font_size", 10)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.07, 0.09, 0.74)
	normal.border_color = Color(0.18, 0.36, 0.40, 0.72)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.04, 0.13, 0.16, 0.92)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.07, 0.23, 0.27, 0.98)
	pressed.border_color = Color("54e8f8")
	pressed.set_border_width(SIDE_BOTTOM, 3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("78939c"))
	button.add_theme_color_override("font_hover_color", Color("c6f7fb"))
	button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	return button

func select_tab(tab_index: int) -> void:
	active_tab = clampi(tab_index, 0, tab_pages.size() - 1)
	for index in range(tab_pages.size()):
		tab_pages[index].visible = index == active_tab
		tab_buttons[index].button_pressed = index == active_tab

func get_active_scroll() -> ScrollContainer:
	return tab_scrolls[active_tab]

func _add_section(parent: VBoxContainer, title_text: String, controls: Array) -> void:
	var heading := Label.new()
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 12)
	heading.add_theme_color_override("font_color", Color("ffae63"))
	heading.add_theme_constant_override("outline_size", 3)
	heading.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	heading.custom_minimum_size.y = 27
	heading.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	parent.add_child(heading)
	for data in controls:
		_add_control(parent, String(data[0]), String(data[1]), float(data[2]), float(data[3]), float(data[4]), String(data[5]))

func _add_control(parent: VBoxContainer, key: String, display_name: String, minimum: float, maximum: float, step: float, suffix: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = display_name
	label.custom_minimum_size.x = 240
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("a8bbc2"))
	row.add_child(label)
	var value_label := Label.new()
	value_label.text = _format_value(TuningStore.get_value(key), suffix)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.add_theme_color_override("font_color", Color("ffcf8b"))
	row.add_child(value_label)
	parent.add_child(row)
	value_labels[key] = value_label
	value_suffixes[key] = suffix

	var slider := HSlider.new()
	slider.name = key
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = TuningStore.get_value(key)
	slider.scrollable = false
	slider.custom_minimum_size.y = 18
	slider.value_changed.connect(func(value: float):
		TuningStore.set_value(key, value)
		value_label.text = _format_value(value, suffix)
	)
	parent.add_child(slider)

func _reset_values() -> void:
	TuningStore.reset()
	for tab_data in TAB_DEFINITIONS:
		for section in tab_data["sections"]:
			for data in section["controls"]:
				var key := String(data[0])
				var slider := panel.find_child(key, true, false) as HSlider
				if slider:
					slider.value = TuningStore.get_value(key)
					value_labels[key].text = _format_value(slider.value, String(value_suffixes[key]))
	export_status.text = "Defaults restored for all four tabs."

func _export_values() -> String:
	var file_name := "ying-tweaks-v%d.json" % TuningStore.CONFIG_VERSION
	var json_text := TuningStore.export_json()
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(json_text.to_utf8_buffer(), file_name, "application/json")
		last_export_path = "download://%s" % file_name
		export_status.text = "Tuning file downloaded."
	else:
		last_export_path = "user://%s" % file_name
		var file := FileAccess.open(last_export_path, FileAccess.WRITE)
		if file == null:
			last_export_path = ""
			export_status.text = "Export Failed  //  Try Again"
			return last_export_path
		file.store_string(json_text)
		file.close()
		export_status.text = "Tuning file saved."
	return last_export_path

func _format_value(value: float, suffix: String) -> String:
	var rounded := roundf(value)
	var number := "%.2f" % value if absf(value) < 10.0 else ("%d" % int(rounded) if is_equal_approx(value, rounded) else "%.1f" % value)
	return number if suffix.is_empty() else "%s %s" % [number, tr(suffix)]

func _refresh_localized_values(_locale: String) -> void:
	for key in value_labels:
		value_labels[key].text = _format_value(TuningStore.get_value(key), String(value_suffixes[key]))
