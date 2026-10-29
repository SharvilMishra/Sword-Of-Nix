extends Node
## The supplied source keeps Chinese text as stable keys; this remix pins all live UI to English.
signal language_changed(locale: String)

var locale := "en"
var messages: Dictionary = {}
var _english := Translation.new()
var _chinese := Translation.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/i18n.json"))
	if parsed is Dictionary:
		messages = parsed
	_english.locale = "en"
	_chinese.locale = "zh_CN"
	for source in messages:
		_english.add_message(source, String(messages[source]))
		_chinese.add_message(source, source)
	TranslationServer.add_translation(_english)
	TranslationServer.add_translation(_chinese)
	set_language("en")

func set_language(value: String = "en", _save_preference: bool = false) -> void:
	if value != "en":
		return
	locale = "en"
	TranslationServer.set_locale(locale)
	_refresh_formatted(get_tree().root)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("(() => { document.documentElement.lang = 'en'; document.title = 'Sword Of Nix'; })()")
	language_changed.emit(locale)

func set_formatted(label: Label, source: String, values: Variant) -> void:
	label.set_meta("i18n_format", [source, values])
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.text = String(TranslationServer.translate(source)) % values

func _refresh_formatted(node: Node) -> void:
	if node is Label and node.has_meta("i18n_format"):
		var data: Array = node.get_meta("i18n_format")
		node.text = String(TranslationServer.translate(data[0])) % data[1]
	for child in node.get_children():
		_refresh_formatted(child)
