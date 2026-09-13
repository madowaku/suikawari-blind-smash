extends Node

const UITheme = preload("res://src/ui_theme.gd")

var game: Control
var applied := false
var result_label: Label
var last_result_text := ""
var direction_buttons = {}
var step_buttons = {}
var stick_buttons = {}


func _ready() -> void:
	game = get_parent() as Control
	set_process(false)
	call_deferred("_apply_polish")


func _apply_polish() -> void:
	if game == null:
		return
	var header_label := game.get("header_label") as Label
	var rule_label := game.get("rule_label") as Label
	result_label = game.get("result_label") as Label
	var message_label := game.get("message_label") as Label
	var plan_label := game.get("plan_label") as Label
	var log_label := game.get("log_label") as Label
	var footer_label := game.get("footer_label") as Label
	var go_button := game.get("go_button") as Button
	var smash_button := game.get("smash_button") as Button
	var reset_button := game.get("reset_button") as Button
	if header_label == null or rule_label == null or result_label == null or log_label == null:
		return

	game.theme = UITheme.build_theme()
	_style_background()
	_style_title()
	_style_hud(header_label, rule_label)
	_style_plan(plan_label)
	_style_message(message_label)
	_style_log(log_label)
	_style_footer(footer_label)

	direction_buttons = game.get("direction_buttons")
	step_buttons = game.get("step_buttons")
	stick_buttons = game.get("stick_buttons")
	for button in direction_buttons.values():
		_style_choice_button(button as Button)
	for button in step_buttons.values():
		_style_choice_button(button as Button)
	for button in stick_buttons.values():
		_style_choice_button(button as Button)

	_style_primary_action(go_button)
	_style_smash_action(smash_button)
	_style_reset_action(reset_button)
	last_result_text = ""
	_update_result_card()
	applied = true
	set_process(true)


func _process(delta: float) -> void:
	if not applied:
		return
	_update_selected_motion(delta)
	if result_label != null and result_label.text != last_result_text:
		_update_result_card()


func _style_background() -> void:
	for child in game.get_children():
		if child is ColorRect:
			(child as ColorRect).color = UITheme.BACKGROUND
			return


func _style_title() -> void:
	var title := _find_label(game, "SUIKAWARI: BLIND SMASH")
	if title == null:
		return
	title.add_theme_color_override("font_color", UITheme.FOREGROUND)
	title.add_theme_font_size_override("font_size", 24)


func _style_hud(header_label: Label, rule_label: Label) -> void:
	header_label.custom_minimum_size = Vector2(0, 38)
	header_label.add_theme_color_override("font_color", UITheme.SURFACE)
	header_label.add_theme_font_size_override("font_size", 14)
	header_label.add_theme_stylebox_override("normal", UITheme.box(UITheme.FOREGROUND, UITheme.FOREGROUND, 14, 0, 9))

	rule_label.custom_minimum_size = Vector2(0, 58)
	rule_label.add_theme_color_override("font_color", UITheme.FOREGROUND)
	rule_label.add_theme_font_size_override("font_size", 13)
	rule_label.add_theme_constant_override("line_spacing", 2)
	rule_label.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE, UITheme.BORDER, 12, 1, 10))


func _style_plan(plan_label: Label) -> void:
	if plan_label == null:
		return
	plan_label.custom_minimum_size = Vector2(0, 36)
	plan_label.add_theme_color_override("font_color", UITheme.FOREGROUND)
	plan_label.add_theme_font_size_override("font_size", 14)
	plan_label.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE_MUTED, Color(0, 0, 0, 0), 10, 0, 7))


func _style_message(message_label: Label) -> void:
	if message_label == null:
		return
	message_label.custom_minimum_size = Vector2(0, 44)
	message_label.add_theme_color_override("font_color", UITheme.FOREGROUND_MUTED)
	message_label.add_theme_font_size_override("font_size", 13)


func _style_log(log_label: Label) -> void:
	var log_title := _find_label(game, "OBSERVATION LOG")
	if log_title != null:
		log_title.add_theme_color_override("font_color", UITheme.FOREGROUND_MUTED)
		log_title.add_theme_font_size_override("font_size", 12)
		log_title.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE_MUTED, UITheme.BORDER, 10, 1, 7))
	log_label.custom_minimum_size = Vector2(0, 102)
	log_label.add_theme_color_override("font_color", UITheme.FOREGROUND)
	log_label.add_theme_font_size_override("font_size", 14)
	log_label.add_theme_constant_override("line_spacing", 4)
	log_label.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE, UITheme.BORDER, 12, 1, 10))


func _style_footer(footer_label: Label) -> void:
	if footer_label == null:
		return
	footer_label.add_theme_color_override("font_color", UITheme.FOREGROUND_MUTED)
	footer_label.add_theme_font_size_override("font_size", 11)


func _style_choice_button(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE, UITheme.BORDER, 10, 1, 7))
	button.add_theme_stylebox_override("hover", UITheme.box(Color("fffdf6"), UITheme.PRIMARY, 10, 1, 7))
	button.add_theme_stylebox_override("pressed", UITheme.box(UITheme.PRIMARY, UITheme.PRIMARY_DARK, 10, 2, 7))
	button.add_theme_stylebox_override("disabled", UITheme.box(Color("e5ded1"), Color("c9bdab"), 10, 1, 7))
	button.add_theme_color_override("font_color", UITheme.FOREGROUND)
	button.add_theme_color_override("font_hover_color", UITheme.FOREGROUND)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.43, 0.41, 0.38, 0.58))


func _style_primary_action(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", UITheme.box(UITheme.PRIMARY, UITheme.PRIMARY_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("hover", UITheme.box(Color("4cadd4"), UITheme.PRIMARY_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("pressed", UITheme.box(UITheme.PRIMARY_DARK, UITheme.PRIMARY_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("disabled", UITheme.box(Color("d8d2c7"), Color("c0b6a5"), 12, 1, 9))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 20)


func _style_smash_action(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", UITheme.box(UITheme.ACCENT, UITheme.ACCENT_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("hover", UITheme.box(Color("ef7359"), UITheme.ACCENT_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("pressed", UITheme.box(UITheme.ACCENT_DARK, UITheme.ACCENT_DARK, 12, 1, 9))
	button.add_theme_stylebox_override("disabled", UITheme.box(Color("d8d2c7"), Color("c0b6a5"), 12, 1, 9))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 20)


func _style_reset_action(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", UITheme.box(UITheme.SURFACE_MUTED, UITheme.BORDER, 12, 1, 9))
	button.add_theme_stylebox_override("hover", UITheme.box(UITheme.SURFACE, UITheme.PRIMARY, 12, 1, 9))
	button.add_theme_color_override("font_color", UITheme.FOREGROUND)
	button.add_theme_color_override("font_hover_color", UITheme.FOREGROUND)


func _update_result_card() -> void:
	if result_label == null:
		return
	last_result_text = result_label.text
	var background := UITheme.SURFACE
	var foreground := UITheme.FOREGROUND
	var border := UITheme.BORDER
	if last_result_text.begins_with("HOTTER"):
		background = UITheme.HOTTER_BG
		foreground = UITheme.ACCENT_DARK
		border = UITheme.ACCENT
	elif last_result_text.begins_with("COLDER"):
		background = UITheme.COLDER_BG
		foreground = UITheme.PRIMARY_DARK
		border = UITheme.PRIMARY
	elif last_result_text.begins_with("SAME"):
		background = UITheme.SAME_BG
		foreground = UITheme.FOREGROUND_MUTED
	elif last_result_text.begins_with("KOTSU"):
		background = UITheme.KNOCK_BG
		foreground = Color("9d6508")
		border = UITheme.SECONDARY
	elif last_result_text.begins_with("SMASH"):
		background = UITheme.SUCCESS_BG
		foreground = Color("347a4a")
		border = Color("67a879")
	elif last_result_text.begins_with("MISS"):
		background = UITheme.FAIL_BG
		foreground = UITheme.ACCENT_DARK
		border = UITheme.ACCENT
	elif last_result_text.begins_with("MOVING"):
		background = UITheme.SURFACE_MUTED
		foreground = UITheme.FOREGROUND_MUTED
	result_label.custom_minimum_size = Vector2(0, 60)
	result_label.add_theme_font_size_override("font_size", 29)
	result_label.add_theme_color_override("font_color", foreground)
	result_label.add_theme_stylebox_override("normal", UITheme.box(background, border, 14, 1, 9))


func _update_selected_motion(delta: float) -> void:
	for collection in [direction_buttons, step_buttons, stick_buttons]:
		for value in collection.values():
			var button := value as Button
			if button == null:
				continue
			button.pivot_offset = button.size * 0.5
			var target_scale := 1.035 if button.button_pressed else 1.0
			button.scale = button.scale.lerp(Vector2.ONE * target_scale, minf(1.0, delta * 14.0))


func _find_label(root: Node, target_text: String) -> Label:
	for child in root.get_children():
		if child is Label and (child as Label).text == target_text:
			return child as Label
		var nested := _find_label(child, target_text)
		if nested != null:
			return nested
	return null
