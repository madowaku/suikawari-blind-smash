extends "res://src/main.gd"

const EXPECTED_GRANT_STAGE_COUNT := 12


func _ready() -> void:
	super._ready()
	assert(stages.size() == EXPECTED_GRANT_STAGE_COUNT)


func _update_header() -> void:
	header_label.text = "STAGE %d/%d   |   PAR %d   |   TURN %d   |   CANDIDATES %d" % [
		current_stage.id,
		stages.size(),
		current_stage.par,
		turn,
		current_stage.candidates.size(),
	]
