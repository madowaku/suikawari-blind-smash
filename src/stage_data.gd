class_name StageData
extends RefCounted

var id: int
var title: String
var start: Vector2i
var candidates: Array[Vector2i]
var par: int
var stick_enabled: bool
var intro: String


func _init(
	stage_id: int,
	stage_title: String,
	start_position: Vector2i,
	candidate_positions: Array,
	stage_par: int,
	stage_stick_enabled: bool,
	stage_intro: String
) -> void:
	id = stage_id
	title = stage_title
	start = start_position
	for position in candidate_positions:
		candidates.append(position)
	par = stage_par
	stick_enabled = stage_stick_enabled
	intro = stage_intro
