extends Node

const BoardCell = preload("res://src/board_cell.gd")

const DIRECTIONS := {
	"N": Vector2i(0, -1),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0),
	"E": Vector2i(1, 0),
}

const STICK_OFFSETS := {
	"N": {"L": Vector2i(-1, 0), "R": Vector2i(1, 0)},
	"S": {"L": Vector2i(1, 0), "R": Vector2i(-1, 0)},
	"E": {"L": Vector2i(0, -1), "R": Vector2i(0, 1)},
	"W": {"L": Vector2i(0, 1), "R": Vector2i(0, -1)},
}

var game: Control
var cells: Dictionary = {}
var last_facing := Vector2i(0, -1)
var attached := false
var base_style: StyleBoxFlat
var preview_style: StyleBoxFlat
var trail_style: StyleBoxFlat
var clear_style: StyleBoxFlat

func _ready() -> void:
	game = get_parent() as Control
	base_style = _make_cell_style(Color("f7e4ba"), Color("b79b69"))
	preview_style = _make_cell_style(Color("deeff5"), Color("70b5d0"))
	trail_style = _make_cell_style(Color("ecf0df"), Color("a9b99a"))
	clear_style = _make_cell_style(Color("e2f1dc"), Color("79a866"))
	set_process(false)
	call_deferred("_attach_cells")

func _attach_cells() -> void:
	if game == null:
		return
	cells = game.get("cell_buttons")
	if cells.is_empty():
		return
	for value in cells.values():
		var cell := value as Button
		if cell != null:
			cell.set_script(BoardCell)
	attached = true
	set_process(true)
	_sync_cells()

func _process(_delta: float) -> void:
	if attached:
		_sync_cells()

func _sync_cells() -> void:
	var current_stage = game.get("current_stage")
	if current_stage == null:
		return
	var player_position: Vector2i = game.get("player_position")
	var selected_direction: String = game.get("selected_direction")
	var selected_stick: String = game.get("selected_stick")
	var phase: String = game.get("phase")
	var trail: Array = game.get("movement_trail")
	var preview: Array = game.call("_get_preview_positions")

	if selected_direction != "" and DIRECTIONS.has(selected_direction):
		last_facing = DIRECTIONS[selected_direction]

	var show_stick := false
	var stick_direction := Vector2i.ZERO
	if bool(current_stage.stick_enabled) and selected_direction != "" and selected_stick != "":
		show_stick = true
		stick_direction = STICK_OFFSETS[selected_direction][selected_stick]

	var watermelon_position := Vector2i.ZERO
	if phase == "clear":
		watermelon_position = game.get("watermelon_position")

	for pos in cells:
		var cell = cells[pos]
		var is_player: bool = pos == player_position
		var is_candidate: bool = pos in current_stage.candidates
		var is_preview: bool = pos in preview
		var is_trail: bool = pos in trail
		var is_revealed: bool = phase == "clear" and pos == watermelon_position
		_apply_surface(cell as Button, is_preview, is_trail, is_revealed)
		cell.call(
			"set_visual_state",
			is_candidate,
			is_player,
			is_preview,
			is_trail,
			is_revealed,
			last_facing,
			stick_direction if is_player else Vector2i.ZERO,
			show_stick and is_player
		)

func _apply_surface(cell: Button, is_preview: bool, is_trail: bool, is_revealed: bool) -> void:
	if cell == null:
		return
	var style := base_style
	if is_trail:
		style = trail_style
	if is_preview:
		style = preview_style
	if is_revealed:
		style = clear_style
	for state in ["normal", "hover", "pressed", "focus"]:
		cell.add_theme_stylebox_override(state, style)
	cell.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	cell.add_theme_color_override("font_hover_color", Color(0, 0, 0, 0))
	cell.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 0))

func _make_cell_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style
