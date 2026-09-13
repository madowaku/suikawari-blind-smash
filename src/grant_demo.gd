extends "res://src/main.gd"

const EXPECTED_GRANT_STAGE_COUNT := 12


func _ready() -> void:
	super._ready()
	_validate_grant_catalog()


func _update_header() -> void:
	header_label.text = "STAGE %d/%d   |   PAR %d   |   TURN %d   |   CANDIDATES %d" % [
		current_stage.id,
		stages.size(),
		current_stage.par,
		turn,
		current_stage.candidates.size(),
	]


func _validate_grant_catalog() -> void:
	assert(stages.size() == EXPECTED_GRANT_STAGE_COUNT)
	for index in range(stages.size()):
		var stage = stages[index]
		assert(stage.id == index + 1)
		assert(stage.start == Vector2i(2, 4))
		assert(not stage.candidates.is_empty())
		assert(stage.par > 0)
		if stage.id <= 4:
			assert(not stage.stick_enabled)
		else:
			assert(stage.stick_enabled)
	assert(stages[11].par == 4)
