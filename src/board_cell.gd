extends Button

const INK := Color("2b3038")
const OCEAN := Color("3b9bc3")
const MELON_GREEN := Color("6f9f53")
const MELON_DARK := Color("456d3a")
const CANDIDATE_GOLD := Color("f2c14e")
const CANDIDATE_DARK := Color("9d731b")
const SKIN := Color("efc89a")
const SHIRT := Color("e85d3f")
const BLINDFOLD := Color("343840")
const BAMBOO := Color("c69b52")
const BAMBOO_DARK := Color("72552f")

var candidate := false
var player := false
var preview := false
var trail := false
var revealed_watermelon := false
var facing := Vector2i(0, -1)
var stick_offset := Vector2i.ZERO
var stick_visible := false

func set_visual_state(
	is_candidate: bool,
	is_player: bool,
	is_preview: bool,
	is_trail: bool,
	is_revealed_watermelon: bool,
	facing_direction: Vector2i,
	stick_direction: Vector2i,
	show_stick: bool
) -> void:
	candidate = is_candidate
	player = is_player
	preview = is_preview
	trail = is_trail
	revealed_watermelon = is_revealed_watermelon
	if facing_direction != Vector2i.ZERO:
		facing = facing_direction
	stick_offset = stick_direction
	stick_visible = show_stick and stick_direction != Vector2i.ZERO
	text = ""
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	if trail:
		_draw_footprints(center, Color(OCEAN, 0.28))
	if preview:
		_draw_footprints(center, Color(OCEAN, 0.78))
	if candidate and not revealed_watermelon:
		_draw_candidate(center, player)
	if revealed_watermelon:
		_draw_watermelon(center)
	if player:
		_draw_player(center)
	if player and stick_visible:
		_draw_stick(center)

func _draw_candidate(center: Vector2, occupied: bool) -> void:
	if occupied:
		draw_arc(center, 23.0, 0.0, TAU, 36, CANDIDATE_GOLD, 3.0, true)
		draw_arc(center, 19.0, 0.0, TAU, 36, Color(CANDIDATE_GOLD, 0.45), 1.5, true)
		return
	draw_circle(center, 11.0, Color(CANDIDATE_GOLD, 0.92))
	draw_arc(center, 11.0, 0.0, TAU, 28, CANDIDATE_DARK, 1.5, true)
	draw_arc(center + Vector2(-3.0, 0.0), 7.0, -1.15, 1.15, 12, Color(CANDIDATE_DARK, 0.72), 1.2, true)
	draw_arc(center + Vector2(3.0, 0.0), 7.0, 1.99, 4.29, 12, Color(CANDIDATE_DARK, 0.72), 1.2, true)
	var leaf := PackedVector2Array([
		center + Vector2(5.0, -10.0),
		center + Vector2(12.0, -14.0),
		center + Vector2(10.0, -7.0),
	])
	draw_colored_polygon(leaf, MELON_GREEN)

func _draw_watermelon(center: Vector2) -> void:
	draw_circle(center, 14.0, MELON_GREEN)
	draw_arc(center, 14.0, 0.0, TAU, 32, MELON_DARK, 2.0, true)
	draw_arc(center + Vector2(-4.0, 0.0), 9.0, -1.15, 1.15, 14, Color(MELON_DARK, 0.82), 1.7, true)
	draw_arc(center + Vector2(4.0, 0.0), 9.0, 1.99, 4.29, 14, Color(MELON_DARK, 0.82), 1.7, true)
	var leaf := PackedVector2Array([
		center + Vector2(5.0, -13.0),
		center + Vector2(14.0, -17.0),
		center + Vector2(11.0, -8.0),
	])
	draw_colored_polygon(leaf, Color("7eaa5f"))

func _draw_player(center: Vector2) -> void:
	var head := center + Vector2(0.0, -7.0)
	var body := center + Vector2(0.0, 11.0)
	draw_circle(body, 9.5, SHIRT)
	draw_circle(head, 10.5, SKIN)
	draw_arc(head, 10.5, 0.0, TAU, 28, Color(INK, 0.72), 1.2, true)
	var band_rect := Rect2(head + Vector2(-11.0, -3.2), Vector2(22.0, 6.4))
	draw_rect(band_rect, BLINDFOLD, true)
	draw_line(head + Vector2(-8.0, 0.0), head + Vector2(8.0, 0.0), Color("20242b"), 1.2, true)
	var knot := PackedVector2Array([
		head + Vector2(-10.0, -2.0),
		head + Vector2(-17.0, -5.0),
		head + Vector2(-14.0, 2.0),
	])
	draw_colored_polygon(knot, BLINDFOLD)
	var direction := Vector2(facing)
	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		var marker_start := head + direction * 12.0
		var side := Vector2(-direction.y, direction.x)
		draw_line(marker_start - side * 3.0, marker_start + direction * 4.0, Color(OCEAN, 0.86), 2.0, true)
		draw_line(marker_start + side * 3.0, marker_start + direction * 4.0, Color(OCEAN, 0.86), 2.0, true)

func _draw_stick(center: Vector2) -> void:
	var side := Vector2(stick_offset)
	if side.length_squared() <= 0.0:
		return
	side = side.normalized()
	var start := center + side * 8.0 + Vector2(0.0, 5.0)
	var finish := center + side * 28.0 + Vector2(0.0, 5.0)
	draw_line(start, finish, BAMBOO_DARK, 5.0, true)
	draw_line(start, finish, BAMBOO, 3.0, true)
	var cross := Vector2(-side.y, side.x)
	draw_line(start + side * 10.0 - cross * 2.5, start + side * 10.0 + cross * 2.5, BAMBOO_DARK, 1.0, true)

func _draw_footprints(center: Vector2, color: Color) -> void:
	var direction := Vector2(facing)
	if direction.length_squared() <= 0.0:
		direction = Vector2(0.0, -1.0)
	direction = direction.normalized()
	var side := Vector2(-direction.y, direction.x)
	var left := center - side * 5.0 - direction * 2.5
	var right := center + side * 5.0 + direction * 4.0
	draw_circle(left, 3.1, color)
	draw_circle(left - direction * 4.0, 1.7, Color(color, color.a * 0.82))
	draw_circle(right, 3.1, color)
	draw_circle(right - direction * 4.0, 1.7, Color(color, color.a * 0.82))
