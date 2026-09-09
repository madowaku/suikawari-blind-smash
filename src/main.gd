extends Control

const GRID_SIZE := 5
const START_POS := Vector2i(2, 4) # C5
const CANDIDATES := [Vector2i(0, 4), Vector2i(4, 4)] # A5 / E5
const PAR := 2

const DIRECTIONS := {
	"N": Vector2i(0, -1),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0),
	"E": Vector2i(1, 0),
}

var rng := RandomNumberGenerator.new()
var player_position := START_POS
var watermelon_position := Vector2i.ZERO
var selected_direction := ""
var selected_steps := 0
var turn := 0
var phase := "input"

var cell_buttons: Dictionary = {}
var direction_buttons: Dictionary = {}
var step_buttons: Dictionary = {}

var header_label: Label
var result_label: Label
var message_label: Label
var plan_label: Label
var go_button: Button
var smash_button: Button
var reset_button: Button


func _ready() -> void:
	rng.randomize()
	_build_ui()
	_start_stage()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.95, 0.92, 0.84)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var title := Label.new()
	title.text = "SUIKAWARI: BLIND SMASH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	header_label = Label.new()
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_font_size_override("font_size", 18)
	root.add_child(header_label)

	var rule := Label.new()
	rule.text = "Stage 1: The watermelon is hidden at A5 or E5.\nMove, read HOTTER/COLDER, then stand on the right candidate and SMASH."
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rule.add_theme_font_size_override("font_size", 15)
	root.add_child(rule)

	result_label = Label.new()
	result_label.text = "READY"
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.custom_minimum_size = Vector2(0, 48)
	result_label.add_theme_font_size_override("font_size", 32)
	root.add_child(result_label)

	var board_center := CenterContainer.new()
	board_center.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	root.add_child(board_center)

	var board := GridContainer.new()
	board.columns = GRID_SIZE + 1
	board.add_theme_constant_override("h_separation", 4)
	board.add_theme_constant_override("v_separation", 4)
	board_center.add_child(board)

	var corner := Label.new()
	corner.custom_minimum_size = Vector2(28, 28)
	board.add_child(corner)

	for x in range(GRID_SIZE):
		var column := Label.new()
		column.text = char(65 + x)
		column.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		column.custom_minimum_size = Vector2(68, 28)
		column.add_theme_font_size_override("font_size", 16)
		board.add_child(column)

	for y in range(GRID_SIZE):
		var row := Label.new()
		row.text = str(y + 1)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.custom_minimum_size = Vector2(28, 68)
		row.add_theme_font_size_override("font_size", 16)
		board.add_child(row)

		for x in range(GRID_SIZE):
			var pos := Vector2i(x, y)
			var cell := Button.new()
			cell.custom_minimum_size = Vector2(68, 68)
			cell.focus_mode = Control.FOCUS_NONE
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.add_theme_font_size_override("font_size", 20)
			cell_buttons[pos] = cell
			board.add_child(cell)

	plan_label = Label.new()
	plan_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plan_label.custom_minimum_size = Vector2(0, 28)
	plan_label.add_theme_font_size_override("font_size", 16)
	root.add_child(plan_label)

	var direction_title := Label.new()
	direction_title.text = "1. Direction"
	direction_title.add_theme_font_size_override("font_size", 16)
	root.add_child(direction_title)

	var direction_row := HBoxContainer.new()
	direction_row.alignment = BoxContainer.ALIGNMENT_CENTER
	direction_row.add_theme_constant_override("separation", 8)
	root.add_child(direction_row)

	for code in ["N", "W", "S", "E"]:
		var button := _make_choice_button(code)
		direction_buttons[code] = button
		button.pressed.connect(_on_direction_pressed.bind(code))
		direction_row.add_child(button)

	var steps_title := Label.new()
	steps_title.text = "2. Steps"
	steps_title.add_theme_font_size_override("font_size", 16)
	root.add_child(steps_title)

	var steps_row := HBoxContainer.new()
	steps_row.alignment = BoxContainer.ALIGNMENT_CENTER
	steps_row.add_theme_constant_override("separation", 8)
	root.add_child(steps_row)

	for steps in range(1, 5):
		var button := _make_choice_button(str(steps))
		step_buttons[steps] = button
		button.pressed.connect(_on_steps_pressed.bind(steps))
		steps_row.add_child(button)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	root.add_child(actions)

	go_button = Button.new()
	go_button.text = "GO!"
	go_button.custom_minimum_size = Vector2(150, 54)
	go_button.add_theme_font_size_override("font_size", 22)
	go_button.pressed.connect(_on_go_pressed)
	actions.add_child(go_button)

	smash_button = Button.new()
	smash_button.text = "SMASH"
	smash_button.custom_minimum_size = Vector2(150, 54)
	smash_button.add_theme_font_size_override("font_size", 22)
	smash_button.pressed.connect(_on_smash_pressed)
	actions.add_child(smash_button)

	reset_button = Button.new()
	reset_button.text = "RESET"
	reset_button.custom_minimum_size = Vector2(100, 54)
	reset_button.pressed.connect(_start_stage)
	actions.add_child(reset_button)

	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(0, 58)
	message_label.add_theme_font_size_override("font_size", 16)
	root.add_child(message_label)

	var footer := Label.new()
	footer.text = "Prototype slice: Stage 1 / no stick sensor yet"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	root.add_child(footer)


func _make_choice_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(70, 46)
	button.add_theme_font_size_override("font_size", 18)
	return button


func _start_stage() -> void:
	player_position = START_POS
	watermelon_position = CANDIDATES[rng.randi_range(0, CANDIDATES.size() - 1)]
	selected_direction = ""
	selected_steps = 0
	turn = 0
	phase = "input"
	result_label.text = "READY"
	result_label.add_theme_color_override("font_color", Color(0.18, 0.20, 0.24))
	message_label.text = "Choose a direction and 1-4 steps. The real watermelon stays hidden."
	_set_input_enabled(true)
	_refresh_ui()


func _on_direction_pressed(code: String) -> void:
	if phase != "input":
		return
	selected_direction = code
	_refresh_ui()


func _on_steps_pressed(steps: int) -> void:
	if phase != "input":
		return
	selected_steps = steps
	_refresh_ui()


func _on_go_pressed() -> void:
	if phase != "input" or not _selection_is_valid():
		return

	phase = "moving"
	_set_input_enabled(false)

	var start := player_position
	var start_distance := _manhattan(start, watermelon_position)
	player_position = _get_end_position(start, selected_direction, selected_steps)
	var end_distance := _manhattan(player_position, watermelon_position)
	turn += 1

	if end_distance < start_distance:
		result_label.text = "HOTTER"
		result_label.add_theme_color_override("font_color", Color(0.86, 0.22, 0.12))
		message_label.text = "You are closer than before. Use that information before your next commitment."
	elif end_distance > start_distance:
		result_label.text = "COLDER"
		result_label.add_theme_color_override("font_color", Color(0.10, 0.42, 0.80))
		message_label.text = "You are farther away than before. COLDER is still useful information."
	else:
		result_label.text = "SAME"
		result_label.add_theme_color_override("font_color", Color(0.40, 0.40, 0.40))
		message_label.text = "Same distance. Stage 1 does not require SAME, but the rule already supports it."

	selected_direction = ""
	selected_steps = 0
	phase = "input"
	_set_input_enabled(true)
	_refresh_ui()


func _on_smash_pressed() -> void:
	if phase != "input" or not _is_candidate(player_position):
		return

	phase = "smashing"
	_set_input_enabled(false)

	if player_position == watermelon_position:
		phase = "clear"
		result_label.text = "SMASH! CLEAR"
		result_label.add_theme_color_override("font_color", Color(0.10, 0.55, 0.24))
		if turn <= PAR:
			message_label.text = "Direct hit in %d turn(s). PAR %d cleared!" % [turn, PAR]
		else:
			message_label.text = "Direct hit in %d turn(s). Try again for PAR %d." % [turn, PAR]
	else:
		phase = "fail"
		result_label.text = "MISS"
		result_label.add_theme_color_override("font_color", Color(0.58, 0.18, 0.18))
		message_label.text = "No watermelon here. RESET and use the temperature result to try again."

	_refresh_ui()


func _refresh_ui() -> void:
	_update_header()
	_update_choice_buttons()
	_update_plan()
	_update_board()
	_update_action_buttons()


func _update_header() -> void:
	header_label.text = "STAGE 1   |   PAR %d   |   TURN %d   |   CANDIDATES 2" % [PAR, turn]


func _update_choice_buttons() -> void:
	for code in direction_buttons:
		direction_buttons[code].button_pressed = code == selected_direction
	for steps in step_buttons:
		step_buttons[steps].button_pressed = steps == selected_steps


func _update_plan() -> void:
	if phase == "clear":
		plan_label.text = "Stage 1 complete."
		return
	if phase == "fail":
		plan_label.text = "Missed. Reset to reshuffle the hidden watermelon."
		return
	if selected_direction == "" or selected_steps == 0:
		plan_label.text = "Plan: choose direction + steps"
		return
	if _selection_is_valid():
		plan_label.text = "Plan: %s%d  →  %s" % [selected_direction, selected_steps, _coord_name(_get_end_position(player_position, selected_direction, selected_steps))]
	else:
		plan_label.text = "That move would leave the 5×5 beach."


func _update_board() -> void:
	var preview := _get_preview_positions()
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var pos := Vector2i(x, y)
			var cell: Button = cell_buttons[pos]
			var is_candidate := _is_candidate(pos)
			var is_player := pos == player_position
			var text_value := ""

			if is_candidate:
				text_value = "?"
			if is_player:
				text_value = "P ?" if is_candidate else "P"
			if phase == "clear" and pos == watermelon_position:
				text_value = "P / W" if is_player else "W"

			cell.text = text_value

			var color := Color(0.96, 0.88, 0.68)
			if is_candidate:
				color = Color(1.00, 0.82, 0.38)
			if pos in preview:
				color = Color(0.68, 0.84, 0.98)
			if is_player:
				color = Color(0.36, 0.67, 0.90)
			if phase == "clear" and pos == watermelon_position:
				color = Color(0.42, 0.82, 0.48)

			_apply_cell_style(cell, color)


func _apply_cell_style(cell: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.55, 0.49, 0.39)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	cell.add_theme_stylebox_override("normal", style)
	cell.add_theme_stylebox_override("hover", style)
	cell.add_theme_stylebox_override("pressed", style)
	cell.add_theme_stylebox_override("focus", style)
	cell.add_theme_color_override("font_color", Color(0.12, 0.14, 0.17))
	cell.add_theme_color_override("font_hover_color", Color(0.12, 0.14, 0.17))
	cell.add_theme_color_override("font_pressed_color", Color(0.12, 0.14, 0.17))


func _update_action_buttons() -> void:
	if phase != "input":
		go_button.disabled = true
		smash_button.disabled = true
		return
	go_button.disabled = not _selection_is_valid()
	smash_button.disabled = not _is_candidate(player_position)


func _set_input_enabled(enabled: bool) -> void:
	for button in direction_buttons.values():
		button.disabled = not enabled
	for button in step_buttons.values():
		button.disabled = not enabled
	go_button.disabled = not enabled
	smash_button.disabled = not enabled


func _selection_is_valid() -> bool:
	if selected_direction == "" or selected_steps <= 0:
		return false
	var pos := player_position
	var delta: Vector2i = DIRECTIONS[selected_direction]
	for _i in range(selected_steps):
		pos += delta
		if not _inside_board(pos):
			return false
	return true


func _get_preview_positions() -> Array:
	var positions: Array = []
	if phase != "input" or selected_direction == "" or selected_steps <= 0:
		return positions
	var pos := player_position
	var delta: Vector2i = DIRECTIONS[selected_direction]
	for _i in range(selected_steps):
		pos += delta
		if not _inside_board(pos):
			return []
		positions.append(pos)
	return positions


func _get_end_position(start: Vector2i, direction: String, steps: int) -> Vector2i:
	return start + DIRECTIONS[direction] * steps


func _inside_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE


func _is_candidate(pos: Vector2i) -> bool:
	return pos in CANDIDATES


func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _coord_name(pos: Vector2i) -> String:
	return "%s%d" % [char(65 + pos.x), pos.y + 1]
