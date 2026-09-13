extends RefCounted

const StageDataScript = preload("res://src/stage_data.gd")


static func build() -> Array:
	var stages: Array = []
	stages.append(StageDataScript.new(
		1,
		"Which side?",
		Vector2i(2, 4),
		[Vector2i(0, 4), Vector2i(4, 4)],
		2,
		false,
		"Move, compare the distance, then SMASH the candidate you believe is correct."
	))
	stages.append(StageDataScript.new(
		2,
		"SAME matters",
		Vector2i(2, 4),
		[Vector2i(0, 0), Vector2i(2, 3), Vector2i(4, 4)],
		3,
		false,
		"HOTTER, SAME, and COLDER are all useful answers."
	))
	stages.append(StageDataScript.new(
		3,
		"How many steps?",
		Vector2i(2, 4),
		[Vector2i(0, 0), Vector2i(0, 3), Vector2i(2, 1), Vector2i(3, 4)],
		3,
		false,
		"The direction is only half the question. Choose the distance carefully."
	))
	stages.append(StageDataScript.new(
		4,
		"Not always north",
		Vector2i(2, 4),
		[Vector2i(0, 1), Vector2i(3, 1), Vector2i(3, 2)],
		3,
		false,
		"Do not turn this into a vertical scan. Sometimes the best question is sideways."
	))
	stages.append(StageDataScript.new(
		5,
		"KOTSU!",
		Vector2i(2, 4),
		[Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 2), Vector2i(4, 3)],
		3,
		true,
		"The stick is now active. Choose LEFT or RIGHT. If it brushes the watermelon mid-move, you hear KOTSU and record K1-K4."
	))
	return stages
