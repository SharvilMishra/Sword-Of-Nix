extends CanvasLayer

var root: Control
var action_buttons: Dictionary = {}
var story_continue_button: Button
var combat_controls_visible := true

func _ready() -> void:
	layer = 30
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_make_button("move_left", "◀", "Move left", Vector2.ZERO)
	_make_button("move_right", "▶", "Move right", Vector2.ZERO)
	_make_button("aim_down", "▼", "Drop through platforms", Vector2.ZERO)
	_make_button("aim_up", "▲\nJUMP", "Jump (up to two times) / aim up", Vector2.ZERO)
	_make_button("dodge", "DODGE", "Dodge slash (mobile equivalent of holding D + R)", Vector2.ZERO)
	_make_button("focus", "SKILL", "Skill: slow the world for 3 seconds", Vector2.ZERO)
	_make_button("attack", "SLASH", "Attack", Vector2.ZERO)
	story_continue_button = _make_button("continue_story", "NEXT", "Continue story", Vector2.ZERO)
	story_continue_button.visible = false
	_make_button("pause_game", "Ⅱ\nPAUSE", "Pause", Vector2.ZERO)
	get_viewport().size_changed.connect(_update_visibility)
	_update_visibility()

func _make_button(action: String, text_value: String, tooltip: String, _unused_offset: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.tooltip_text = tooltip
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", Color("d5faff"))
	button.add_theme_color_override("font_pressed_color", Color("061319"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.08, 0.11, 0.54)
	normal.border_color = Color(0.25, 0.88, 0.97, 0.86)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.25, 0.9, 1.0, 0.82)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.button_down.connect(_dispatch_action.bind(action, true))
	button.button_up.connect(_dispatch_action.bind(action, false))
	button.tree_exiting.connect(_dispatch_action.bind(action, false))
	root.add_child(button)
	action_buttons[action] = button
	return button

func set_story_continue_visible(is_visible: bool) -> void:
	if is_instance_valid(story_continue_button):
		story_continue_button.visible = is_visible

func set_combat_controls_visible(is_visible: bool) -> void:
	combat_controls_visible = is_visible
	for action in action_buttons:
		var action_name := String(action)
		if action_name == "continue_story":
			continue
		var button: Button = action_buttons[action_name]
		if not is_visible:
			_dispatch_action(action_name, false)
		button.visible = is_visible

func _dispatch_action(action: String, pressed: bool) -> void:
	match action:
		"dodge":
			_dispatch_input_action(&"move_right", pressed)
			_dispatch_input_action(&"focus_dash", pressed)
		"aim_up":
			_dispatch_input_action(&"aim_up", pressed)
			_dispatch_input_action(&"jump", pressed)
		_:
			_dispatch_input_action(StringName(action), pressed)

func _dispatch_input_action(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)

func _update_visibility() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var touch_layout := viewport_size.x < 1000.0 or OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	root.visible = touch_layout
	if not touch_layout:
		return
	var ui_scale := clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.78, 1.0)
	var pad := 84.0 * ui_scale
	var edge := 28.0 * ui_scale
	var bottom := 24.0 * ui_scale
	_place("move_left", Vector2(edge, -bottom - pad - 8.0 * ui_scale), Vector2(pad, pad), 26)
	_place("move_right", Vector2(edge + pad * 2.08, -bottom - pad - 8.0 * ui_scale), Vector2(pad, pad), 26)
	_place("aim_up", Vector2(edge + pad + 8.0 * ui_scale, -bottom - pad * 2.08 - 16.0 * ui_scale), Vector2(pad, pad), 15)
	_place("aim_down", Vector2(edge + pad + 8.0 * ui_scale, -bottom), Vector2(pad, pad), 15)
	var action_size := Vector2(94.0, 82.0) * ui_scale
	var right_edge := 22.0 * ui_scale
	_place("attack", Vector2(-right_edge - action_size.x, -bottom - action_size.y), action_size, 17)
	_place("focus", Vector2(-right_edge - action_size.x * 2.0 - 10.0 * ui_scale, -bottom - action_size.y), action_size, 16)
	_place("dodge", Vector2(-right_edge - action_size.x * 3.0 - 20.0 * ui_scale, -bottom - action_size.y), action_size, 16)
	_place("continue_story", Vector2(-150.0 * ui_scale, 22.0 * ui_scale), Vector2(112.0, 54.0) * ui_scale, 18)
	_place("pause_game", Vector2(-edge - 90.0 * ui_scale, 22.0 * ui_scale), Vector2(82.0, 54.0) * ui_scale, 14)

func _place(action: String, offset: Vector2, button_size: Vector2, font_size: int) -> void:
	var button: Button = action_buttons.get(action)
	if not is_instance_valid(button):
		return
	button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT if action in ["move_left", "move_right", "aim_up", "aim_down"] else Control.PRESET_BOTTOM_RIGHT)
	if action in ["continue_story", "pause_game"]:
		button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.position = offset
	button.size = button_size
	button.add_theme_font_size_override("font_size", int(round(font_size * clampf(button_size.x / 94.0, 0.78, 1.0))))
