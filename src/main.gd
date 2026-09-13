extends Control

signal knock_detected(step_number: int)

const GRID_SIZE := 5
const START_POS := Vector2i(2, 4) # C5
const CANDIDATES := [Vector2i(0, 4), Vector2i(4, 4)] # A5 / E5
const PAR := 2
const STEP_DURATION := 0.20
const RESULT_HOLD := 0.45

const DIRECTIONS := {
	"N": Vector2i(0, -1),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0),
	"E": Vector2i(1, 0),
}

# Stick direction is relative to travel direction.
const STICK_OFFSETS := {
	"N": {"L": Vector2i(-1, 0), "R": Vector2i(1, 0)},
	"S": {"L": Vector2i(1, 0), "R": Vector2i(-1, 0)},
	"E": {"L": Vector2i(0, -1), "R": Vector2i(0, 1)},
	"W": {"L": Vector2i(0, 1), "R": Vector2i(0, -1)},
}

var rng := RandomNumberGenerator.new()
var player_position := START_POS
var watermelon_position := Vector2i.ZERO
var selected_direction := ""
var selected_steps := 0
var selected_stick := ""
var turn := 0
var phase := "input"

var cell_buttons: Dictionary = {}
var direction_buttons: Dictionary = {}
var step_buttons: Dictionary = {}
var stick_buttons: Dictionary = {}
var movement_trail: Array[Vector2i] = []
var turn_log: Array[String] = []

var header_label: Label
var result_label: Label
var message_label: Label
var plan_label: Label
var log_label: Label
var go_button: Button
var smash_button: Button
var reset_button: Button


func _ready() -> void:
	rng.randomize()
	_run_stick_self_check()
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
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	var title := Label.new()
	title.text = "SUIKAWARI: BLIND SMASH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	root.add_child(title)

	header_label = Label.new()
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_font_size_override("font_size", 16)
	root.add_child(header_label)

	var rule := Label.new()
	rule.text = "Stage 1: the watermelon is hidden at A5 or E5.\nCommit direction + steps + stick side, read the result, then SMASH."
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rule.add_theme_font_size_override("font_size", 13)
	root.add_child(rule)

	result_label = Label.new()
	result_label.text = "READY"
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.custom_minimum_size = Vector2(0, 40)
	result_label.add_theme_font_size_override("font_size", 29)
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
	corner.custom_minimum_size = Vector2(28, 22)
	board.add_child(corner)

	for x in range(GRID_SIZE):
		var column := Label.new()
		column.text = char(65 + x)
		column.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		column.custom_minimum_size = Vector2(62, 22)
		column.add_theme_font_size_override("font_size", 14)
		board.add_child(column)

	for y in range(GRID_SIZE):
		var row := Label.new()
		row.text = str(y + 1)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.custom_minimum_size = Vector2(28, 62)
		row.add_theme_font_size_override("font_size", 14)
		board.add_child(row)

		for x in range(GRID_SIZE):
			var pos := Vector2i(x, y)
			var cell := Button.new()
			cell.custom_minimum_size = Vector2(62, 62)
			cell.focus_mode = Control.FOCUS_NONE
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.add_theme_font_size_override("font_size", 18)
			cell_buttons[pos] = cell
			board.add_child(cell)

	plan_label = Label.new()
	plan_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plan_label.custom_minimum_size = Vector2(0, 22)
	plan_label.add_theme_font_size_override("font_size", 14)
	root.add_child(plan_label)

	var choice_row := HBoxContainer.new()
	choice_row.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_row.add_theme_constant_override("separation", 14)
	root.add_child(choice_row)

	var direction_group := VBoxContainer.new()
	direction_group.add_theme_constant_override("separation", 3)
	choice_row.add_child(direction_group)

	var direction_title := Label.new()
	direction_title.text = "1. Direction"
	direction_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	direction_title.add_theme_font_size_override("font_size", 14)
	direction_group.add_child(direction_title)

	var direction_row := HBoxContainer.new()
	direction_row.alignment = BoxContainer.ALIGNMENT_CENTER
	direction_row.add_theme_constant_override("separation", 4)
	direction_group.add_child(direction_row)

	for code in ["N", "W", "S", "E"]:
		var button := _make_choice_button(code, Vector2(50, 40))
		direction_buttons[code] = button
		button.pressed.connect(_on_direction_pressed.bind(code))
		direction_row.add_child(button)

	var steps_group := VBoxContainer.new()
	steps_group.add_theme_constant_override("separation", 3)
	choice_row.add_child(steps_group)

	var steps_title := Label.new()
	steps_title.text = "2. Steps"
	steps_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	steps_title.add_theme_font_size_override("font_size", 14)
	steps_group.add_child(steps_title)

	var steps_row := HBoxContainer.new()
	steps_row.alignment = BoxContainer.ALIGNMENT_CENTER
	steps_row.add_theme_constant_override("separation", 4)
	steps_group.add_child(steps_row)

	for steps in range(1, 5):
		var button := _make_choice_button(str(steps), Vector2(43, 40))
		step_buttons[steps] = button
		button.pressed.connect(_on_steps_pressed.bind(steps))
		steps_row.add_child(button)

	var stick_group := HBoxContainer.new()
	stick_group.alignment = BoxContainer.ALIGNMENT_CENTER
	stick_group.add_theme_constant_override("separation", 8)
	root.add_child(stick_group)

	var stick_title := Label.new()
	stick_title.text = "3. Stick side"
	stick_title.add_theme_font_size_override("font_size", 14)
	stick_group.add_child(stick_title)

	for side in ["L", "R"]:
		var button := _make_choice_button(side, Vector2(76, 38))
		button.text = "LEFT" if side == "L" else "RIGHT"
		stick_buttons[side] = button
		button.pressed.connect(_on_stick_pressed.bind(side))
		stick_group.add_child(button)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)

	go_button = Button.new()
	go_button.text = "GO!"
	go_button.custom_minimum_size = Vector2(136, 46)
	go_button.add_theme_font_size_override("font_size", 20)
	go_button.pressed.connect(_on_go_pressed)
	actions.add_child(go_button)

	smash_button = Button.new()
	smash_button.text = "SMASH"
	smash_button.custom_minimum_size = Vector2(136, 46)
	smash_button.add_theme_font_size_override("font_size", 20)
	smash_button.pressed.connect(_on_smash_pressed)
	actions.add_child(smash_button)

	reset_button = Button.new()
	reset_button.text = "RESET"
	reset_button.custom_minimum_size = Vector2(86, 46)
	reset_button.pressed.connect(_start_stage)
	actions.add_child(reset_button)

	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(0, 40)
	message_label.add_theme_font_size_override("font_size", 13)
	root.add_child(message_label)

	var log_title := Label.new()
	log_title.text = "OBSERVATION LOG"
	log_title.add_theme_font_size_override("font_size", 13)
	root.add_child(log_title)

	log_label = Label.new()
	log_label.text = "No observations yet."
	log_label.custom_minimum_size = Vector2(0, 60)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_font_size_override("font_size", 13)
	root.add_child(log_label)

	var footer := Label.new()
	footer.text = "Stick sensor active: K1-K4 records the contact step"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 11)
	root.add_child(footer)


func _make_choice_button(text_value: String, minimum_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.toggle_mode = true
	button.custom_minimum_size = minimum_size
	button.add_theme_font_size_override("font_size", 16)
	return button


func _start_stage() -> void:
	player_position = START_POS
	watermelon_position = CANDIDATES[rng.randi_range(0, CANDIDATES.size() - 1)]
	selected_direction = ""
	selected_steps = 0
	selected_stick = ""
	turn = 0
	phase = "input"
	movement_trail.clear()
	turn_log.clear()
	result_label.text = "READY"
	result_label.modulate = Color.WHITE
	result_label.scale = Vector2.ONE
	result_label.add_theme_color_override("font_color", Color(0.18, 0.20, 0.24))
	message_label.text = "Choose direction, 1-4 steps, and LEFT/RIGHT stick side."
	_update_log_label()
	_refresh_ui()


func _on_direction_pressed(code: String) -> void:
	if phase != "input":
		return
	movement_trail.clear()
	selected_direction = code
	_refresh_ui()


func _on_steps_pressed(steps: int) -> void:
	if phase != "input":
		return
	movement_trail.clear()
	selected_steps = steps
	_refresh_ui()


func _on_stick_pressed(side: String) -> void:
	if phase != "input":
		return
	selected_stick = side
	_refresh_ui()


func _on_go_pressed() -> void:
	if phase != "input" or not _selection_is_valid():
		return

	var input_direction := selected_direction
	var input_steps := selected_steps
	var input_stick := selected_stick
	var start := player_position
	var start_distance := _manhattan(start, watermelon_position)
	var delta: Vector2i = DIRECTIONS[input_direction]
	var knock_step := -1

	phase = "moving"
	movement_trail.clear()
	result_label.text = "MOVING..."
	result_label.add_theme_color_override("font_color", Color(0.24, 0.31, 0.38))
	message_label.text = "Committed %s%d%s. You cannot stop mid-move." % [input_direction, input_steps, input_stick]
	_refresh_ui()

	await get_tree().create_timer(0.08).timeout

	for step_index in range(input_steps):
		player_position += delta
		movement_trail.append(player_position)
		var current_step := step_index + 1

		if knock_step < 0 and _stick_touches_watermelon(player_position, input_direction, input_stick):
			knock_step = current_step
			result_label.text = "KOTSU!  K%d" % knock_step
			result_label.add_theme_color_override("font_color", Color(0.86, 0.48, 0.08))
			message_label.text = "KOTSU! The stick touched something on step %d. Keep moving." % knock_step
			knock_detected.emit(knock_step)
		else:
			message_label.text = "Step %d / %d" % [current_step, input_steps]

		_update_board()
		await get_tree().create_timer(STEP_DURATION).timeout

	var end_distance := _manhattan(player_position, watermelon_position)
	turn += 1
	var temperature := _temperature_from_distances(start_distance, end_distance)
	_append_log(turn, input_direction, input_steps, input_stick, temperature, knock_step)
	_show_temperature(temperature, knock_step)

	phase = "showing_result"
	selected_direction = ""
	selected_steps = 0
	selected_stick = ""
	_refresh_ui()
	await _play_result_pop()

	phase = "input"
	_refresh_ui()


func _on_smash_pressed() -> void:
	if phase != "input" or not _is_candidate(player_position):
		return

	phase = "smashing"
	_refresh_ui()

	if player_position == watermelon_position:
		phase = "clear"
		result_label.text = "SMASH! CLEAR"
		result_label.modulate = Color.WHITE
		result_label.scale = Vector2.ONE
		result_label.add_theme_color_override("font_color", Color(0.10, 0.55, 0.24))
		if turn <= PAR:
			message_label.text = "Direct hit in %d turn(s). PAR %d cleared!" % [turn, PAR]
		else:
			message_label.text = "Direct hit in %d turn(s). Try again for PAR %d." % [turn, PAR]
	else:
		phase = "fail"
		result_label.text = "MISS"
		result_label.modulate = Color.WHITE
		result_label.scale = Vector2.ONE
		result_label.add_theme_color_override("font_color", Color(0.58, 0.18, 0.18))
		message_label.text = "No watermelon here. RESET and use the observations to try again."

	_refresh_ui()


func _temperature_from_distances(start_distance: int, end_distance: int) -> String:
	if end_distance < start_distance:
		return "HOTTER"
	if end_distance > start_distance:
		return "COLDER"
	return "SAME"


func _show_temperature(temperature: String, knock_step: int) -> void:
	result_label.text = temperature if knock_step < 0 else "%s + K%d" % [temperature, knock_step]
	match temperature:
		"HOTTER":
			result_label.add_theme_color_override("font_color", Color(0.86, 0.22, 0.12))
			message_label.text = "HOTTER: you are closer than before."
		"COLDER":
			result_label.add_theme_color_override("font_color", Color(0.10, 0.42, 0.80))
			message_label.text = "COLDER: you are farther away. That is still useful information."
		_:
			result_label.add_theme_color_override("font_color", Color(0.40, 0.40, 0.40))
			message_label.text = "SAME: your distance to the watermelon did not change."

	if knock_step >= 0:
		message_label.text += " Stick contact: K%d." % knock_step


func _play_result_pop() -> void:
	result_label.modulate = Color(1, 1, 1, 0)
	result_label.scale = Vector2(0.96, 0.96)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(result_label, "modulate", Color.WHITE, 0.12)
	tween.tween_property(result_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(RESULT_HOLD).timeout


func _append_log(turn_number: int, direction: String, steps: int, stick: String, temperature: String, knock_step: int) -> void:
	var knock_text := "" if knock_step < 0 else " + K%d" % knock_step
	turn_log.append("T%d   %s%d%s  ->  %s%s" % [turn_number, direction, steps, stick, temperature, knock_text])
	if turn_log.size() > 4:
		turn_log.pop_front()
	_update_log_label()


func _update_log_label() -> void:
	if turn_log.is_empty():
		log_label.text = "No observations yet."
		return
	var text := ""
	for index in range(turn_log.size()):
		if index > 0:
			text += "\n"
		text += turn_log[index]
	log_label.text = text


func _refresh_ui() -> void:
	_update_header()
	_update_choice_buttons()
	_update_plan()
	_update_board()
	_update_action_buttons()


func _update_header() -> void:
	header_label.text = "STAGE 1   |   PAR %d   |   TURN %d   |   CANDIDATES 2" % [PAR, turn]


func _update_choice_buttons() -> void:
	var input_enabled := phase == "input"
	for code in direction_buttons:
		direction_buttons[code].button_pressed = code == selected_direction
		direction_buttons[code].disabled = not input_enabled
	for steps in step_buttons:
		step_buttons[steps].button_pressed = steps == selected_steps
		step_buttons[steps].disabled = not input_enabled
	for side in stick_buttons:
		stick_buttons[side].button_pressed = side == selected_stick
		stick_buttons[side].disabled = not input_enabled


func _update_plan() -> void:
	if phase == "moving":
		plan_label.text = "Committed move in progress..."
		return
	if phase == "showing_result":
		plan_label.text = "Read the result, then choose your next commitment."
		return
	if phase == "clear":
		plan_label.text = "Stage 1 complete."
		return
	if phase == "fail":
		plan_label.text = "Missed. Reset to reshuffle the hidden watermelon."
		return
	if selected_direction == "" or selected_steps == 0 or selected_stick == "":
		plan_label.text = "Plan: choose direction + steps + stick side"
		return
	if _selection_is_valid():
		plan_label.text = "Plan: %s%d%s  ->  %s" % [selected_direction, selected_steps, selected_stick, _coord_name(_get_end_position(player_position, selected_direction, selected_steps))]
	else:
		plan_label.text = "That move would leave the 5x5 beach."


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
			if pos in movement_trail:
				color = Color(0.82, 0.89, 0.96)
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
	var busy := phase == "moving" or phase == "showing_result" or phase == "smashing"
	reset_button.disabled = busy

	if phase != "input":
		go_button.disabled = true
		smash_button.disabled = true
		return

	go_button.disabled = not _selection_is_valid()
	smash_button.disabled = not _is_candidate(player_position)


func _selection_is_valid() -> bool:
	if selected_direction == "" or selected_steps <= 0 or selected_stick == "":
		return false
	var pos := player_position
	var delta: Vector2i = DIRECTIONS[selected_direction]
	for _i in range(selected_steps):
		pos += delta
		if not _inside_board(pos):
			return false
	return true


func _get_preview_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
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


func _get_stick_probe_position(position: Vector2i, direction: String, stick: String) -> Vector2i:
	var offset: Vector2i = STICK_OFFSETS[direction][stick]
	return position + offset


func _stick_touches_watermelon(position: Vector2i, direction: String, stick: String) -> bool:
	return _get_stick_probe_position(position, direction, stick) == watermelon_position


func _run_stick_self_check() -> void:
	assert(_get_stick_probe_position(Vector2i(2, 2), "N", "L") == Vector2i(1, 2))
	assert(_get_stick_probe_position(Vector2i(2, 2), "N", "R") == Vector2i(3, 2))
	assert(_get_stick_probe_position(Vector2i(2, 2), "S", "L") == Vector2i(3, 2))
	assert(_get_stick_probe_position(Vector2i(2, 2), "S", "R") == Vector2i(1, 2))
	assert(_get_stick_probe_position(Vector2i(2, 2), "E", "L") == Vector2i(2, 1))
	assert(_get_stick_probe_position(Vector2i(2, 2), "E", "R") == Vector2i(2, 3))
	assert(_get_stick_probe_position(Vector2i(2, 2), "W", "L") == Vector2i(2, 3))
	assert(_get_stick_probe_position(Vector2i(2, 2), "W", "R") == Vector2i(2, 1))


func _inside_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE


func _is_candidate(pos: Vector2i) -> bool:
	return pos in CANDIDATES


func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _coord_name(pos: Vector2i) -> String:
	return "%s%d" % [char(65 + pos.x), pos.y + 1]
