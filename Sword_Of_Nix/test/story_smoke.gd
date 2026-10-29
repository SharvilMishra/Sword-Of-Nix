extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_english_only()
	var story = load("res://scripts/story_store.gd")
	assert(FileAccess.file_exists(story.STORY_PATH))
	assert(story.reload())
	assert(story.get_last_error().is_empty())
	assert(story.get_version() == 1)
	assert(story.validate_xml_text("<story version=\"1\"><scene id=\"ok\"></scene></story>"))
	assert(not story.validate_xml_text("<story version=\"1\"><scene id=\"truncated\">"))

	var briefing: Array[Dictionary] = story.get_scene("opening_briefing")
	assert(briefing.size() >= 4)
	for entry in briefing:
		_assert_english_text(String(entry["text"]))
	var arrival: Array[Dictionary] = story.get_scene("tutorial_arrival")
	assert(arrival.size() >= 1)
	assert(arrival[0]["target"] == "blade")
	_assert_english_text(String(arrival[0]["text"]))
	var materialize: Array[Dictionary] = story.get_scene("tutorial_materialize")
	assert(materialize.size() == 1)
	assert(materialize[0]["target"] == "blade")
	assert("lightning" in String(materialize[0]["text"]).to_lower())
	var alarm: Array[Dictionary] = story.get_scene("tutorial_gunner_alarm")
	assert(alarm.size() >= 1 and alarm[0]["target"] == "gunner")
	var reinforcements: Array[Dictionary] = story.get_scene("tutorial_reinforcements")
	assert(reinforcements.size() >= 1 and reinforcements[0]["target"] == "reinforcement_lead")
	var boss_arrival: Array[Dictionary] = story.get_scene("boss_arrival")
	assert(boss_arrival.size() >= 1)
	assert(boss_arrival[0]["target"] == "boss" and boss_arrival[0]["speaker"] == "The Warden")
	for entry in boss_arrival:
		assert(String(entry["target"]) in ["boss", "player"])
		_assert_english_text(String(entry["text"]))
	var boss_passed: Array[Dictionary] = story.get_scene("boss_passed")
	assert(boss_passed.size() >= 1 and boss_passed[0]["target"] == "boss")
	for entry in boss_passed:
		assert(String(entry["target"]) in ["boss", "player"])
		_assert_english_text(String(entry["text"]))
	var epilogue: Array[Dictionary] = story.get_scene("post_boss_epilogue")
	assert(epilogue.size() >= 5)
	var epilogue_targets: Array[String] = []
	for entry in epilogue:
		var target := String(entry["target"])
		assert(target in ["warehouse", "crate", "blade", "blade_hold", "cat"])
		_assert_english_text(String(entry["text"]))
		epilogue_targets.append(target)
	for required_target in ["warehouse", "crate", "blade", "blade_hold", "cat"]:
		assert(required_target in epilogue_targets)
	var blade_barks: Array[Dictionary] = story.get_barks("blade")
	var gunner_barks: Array[Dictionary] = story.get_barks("gunner")
	assert(not blade_barks.is_empty() and not gunner_barks.is_empty())
	for entry in blade_barks + gunner_barks:
		_assert_english_text(String(entry["text"]))
		assert(is_equal_approx(float(entry["duration"]), 3.0))

	var tutorial_scene := load("res://scenes/tutorial.tscn") as PackedScene
	var tutorial = tutorial_scene.instantiate()
	tutorial.skip_story_intro = true
	tutorial.auto_scene_change = false
	root.add_child(tutorial)
	for _index in range(6):
		await physics_frame
	for grounded_actor in [tutorial.player, tutorial.blade_enemy, tutorial.gunner_enemy]:
		assert(absf(grounded_actor.get_hurtbox_rect_world().end.y - tutorial.FLOOR_Y) <= 1.5)
	assert(is_instance_valid(tutorial.phone_briefing))
	assert(tutorial.phone_briefing.overlay.name == "PhoneBriefingOverlay")
	assert(tutorial.phone_briefing.background.name == "BriefingPhoneBackground")
	assert(tutorial.phone_briefing.background.texture.resource_path == "res://assets/story/briefing_flip_phone.webp")
	assert(tutorial.phone_briefing.background.texture.get_size().is_equal_approx(Vector2(1280.0, 720.0)))
	assert(tutorial.phone_briefing.background.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	assert(tutorial.phone_briefing.text_column.name == "BriefingTextColumn")
	assert(tutorial.phone_briefing.text_column.get_parent() == tutorial.phone_briefing.overlay)
	assert(tutorial.phone_briefing.message_label.get_parent() == tutorial.phone_briefing.text_column)
	assert(tutorial.phone_briefing.overlay.find_child("RetroFlipPhone", true, false) == null)
	assert(tutorial.phone_briefing.overlay.find_child("BriefingScreen", true, false) == null)
	tutorial.phone_briefing.visible = true
	tutorial.phone_briefing.present_line(briefing[3], 3, briefing.size())
	assert(tutorial.phone_briefing.message_label.visible_characters == 0)
	assert(not tutorial.phone_briefing.hint_label.visible)
	tutorial.phone_briefing.typing = false
	assert(tutorial.phone_briefing.message_label.visible_characters == -1)
	assert(tutorial.phone_briefing.hint_label.visible)
	assert(tutorial.phone_briefing.hint_label.text == "F  //  Continue")
	assert(tutorial.phone_briefing.typewriter.TYPE_TICK.resource_path == "res://assets/audio/dialogue_type_tick.ogg")
	assert("Akai gang" in tutorial.phone_briefing.message_label.text)
	var game_font: Font = tutorial.phone_briefing.message_label.get_theme_font("font")
	assert(is_instance_valid(game_font) and game_font.has_char("U".unicode_at(0)))
	assert(tutorial.phone_briefing.progress_label.text == "04 / 06")
	assert(is_instance_valid(tutorial.tv_transition.top_bar))
	tutorial.tv_transition.set_closed(true)
	assert(is_equal_approx(tutorial.tv_transition.top_bar.size.y, 360.0))
	assert(is_equal_approx(tutorial.tv_transition.bottom_bar.position.y, 360.0))
	tutorial.tv_transition.set_closed(false)
	assert(is_zero_approx(tutorial.tv_transition.top_bar.size.y))
	tutorial.phone_briefing.visible = false
	tutorial._show_world_bubble(tutorial.blade_enemy, arrival[0])
	assert(is_instance_valid(tutorial.active_story_bubble))
	assert(tutorial.active_story_bubble.get_parent() == tutorial.blade_enemy)
	assert("Akai Blade Guard" in tutorial.active_story_bubble.text)
	assert(not _contains_cjk(tutorial.active_story_bubble.text))
	assert(tutorial.active_story_bubble.position.y + tutorial.active_story_bubble.size.y <= -170.0)
	tutorial.story_typewriter.begin_line(tutorial.active_story_bubble, tutorial.active_story_hint, tutorial.active_story_bubble.text, 34.0)
	assert(not tutorial.active_story_hint.visible)
	tutorial.story_typewriter.reveal_immediately()
	assert(tutorial.active_story_hint.visible and tutorial.active_story_hint.text == "F  //  Continue")
	assert(tutorial.active_story_bubble.get_theme_font("font") == game_font)
	var bubble_color: Color = tutorial.active_story_bubble.get_theme_color("font_color")
	assert(bubble_color.r > 0.9 and bubble_color.g > 0.9 and bubble_color.b > 0.9)
	tutorial._clear_world_bubble()
	tutorial._prepare_tutorial_scene(false)
	assert(tutorial.player.global_position.is_equal_approx(tutorial.TUTORIAL_PLAYER_POSITION))
	assert(not tutorial.player.visible)
	assert(tutorial.player.force_idle_visual)
	tutorial.tutorial_phase = tutorial.TutorialPhase.ARRIVAL_MATERIALIZE
	tutorial._trigger_shadow_materialization()
	assert(tutorial.materialization_effect.visible and tutorial.materialization_effect.intensity > 0.99)
	assert(tutorial.lightning_flash == 1.0 and tutorial.shake_strength >= 8.5)
	tutorial.player.visible = true
	tutorial._show_world_bubble(tutorial.blade_enemy, materialize[0])
	assert(String(materialize[0]["text"]) in tutorial.active_story_bubble.text)
	assert(tutorial.player.global_position.is_equal_approx(tutorial.TUTORIAL_PLAYER_POSITION))
	assert(tutorial.player.force_idle_visual)
	assert(tutorial.player._resolve_visual_state()["texture"] == load("res://scripts/animation_frames.gd").HERO_IDLE[0])
	tutorial._clear_world_bubble()

	for child in tutorial.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	await create_timer(0.12).timeout
	tutorial.free()
	await process_frame
	await create_timer(0.12).timeout
	print("[STORY_SMOKE_PASS] English-only locale, complete translated story, tutorial dialogue, font, layout and source scene wiring verified")
	quit(0)

func _check_english_only() -> void:
	var i18n := root.get_node("I18n")
	assert(i18n.locale == "en")
	i18n.set_language("zh_CN", false)
	assert(i18n.locale == "en")
	i18n.set_language("en", false)
	assert(i18n.locale == "en")

	var save_store = load("res://scripts/save_store.gd")
	var best_before: float = save_store.get_best_time()
	var tutorial_before: bool = save_store.has_completed_tutorial()
	var title := (load("res://scenes/title_screen.tscn") as PackedScene).instantiate()
	root.add_child(title)
	await process_frame
	title.fade_layer.modulate.a = 0.0
	var heading := title.get_node("TitleContent/GameTitle") as Label
	assert(heading.text == "SWORD")
	assert(title.find_child("LanguageButton", true, false) == null)
	assert(title.get_node("TitleContent/StoryPrologueButton").text == "02   /   STORY PROLOGUE")

	var count := Label.new()
	root.add_child(count)
	i18n.set_formatted(count, "Enemies  %02d", 7)
	assert(count.text == "Enemies  07")
	var pause = load("res://scripts/pause_menu.gd").new()
	root.add_child(pause)
	pause.show_menu()
	await process_frame
	assert(paused and pause.is_open())
	assert(pause.resume_button.text == "Resume")
	assert(pause.find_child("LanguageButton", true, false) == null)
	pause.resume_game()
	assert(not paused)
	assert(save_store.get_best_time() == best_before)
	assert(save_store.has_completed_tutorial() == tutorial_before)
	assert(i18n.locale == "en")
	pause.free()
	count.free()
	title.free()

func _assert_english_text(value: String) -> void:
	assert(not value.strip_edges().is_empty())
	assert(not _contains_cjk(value), "Unexpected CJK story text: " + value)

func _contains_cjk(value: String) -> bool:
	for index in range(value.length()):
		var codepoint: int = value.unicode_at(index)
		if (codepoint >= 0x3400 and codepoint <= 0x4DBF) or (codepoint >= 0x4E00 and codepoint <= 0x9FFF) or (codepoint >= 0xF900 and codepoint <= 0xFAFF):
			return true
	return false
