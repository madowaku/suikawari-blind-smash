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

func _ready() -> void:
	game = get_parent() as Control
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
		var is_revealed: bool = phase == "clear" and pos == watermelon_position
		cell.call(
			"set_visual_state",
			is_candidate,
			is_player,
			pos in preview,
			pos in trail,
			is_revealed,
			last_facing,
			stick_direction if is_player else Vector2i.ZERO,
			show_stick and is_player
		)
