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
	stages.append(StageDataScript.new(
		6,
		"Switch sides",
		Vector2i(2, 4),
		[Vector2i(0, 3), Vector2i(1, 2), Vector2i(3, 3), Vector2i(4, 3)],
		3,
		true,
		"Same sensor, different shape. Read the board before choosing which side to probe."
	))
	stages.append(StageDataScript.new(
		7,
		"Three choices",
		Vector2i(2, 4),
		[Vector2i(0, 3), Vector2i(1, 2), Vector2i(2, 1), Vector2i(3, 4)],
		3,
		true,
		"Direction, distance, and stick side now work together as one question."
	))
	stages.append(StageDataScript.new(
		8,
		"Measure twice",
		Vector2i(2, 4),
		[Vector2i(0, 1), Vector2i(1, 3), Vector2i(4, 1), Vector2i(4, 4)],
		3,
		true,
		"Four candidates, one commitment. Read the geometry before moving."
	))
	stages.append(StageDataScript.new(
		9,
		"Commit",
		Vector2i(2, 4),
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 2)],
		3,
		true,
		"The candidates are tightly clustered. Choose your question carefully."
	))
	stages.append(StageDataScript.new(
		10,
		"Crossroads",
		Vector2i(2, 4),
		[Vector2i(0, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 2)],
		3,
		true,
		"Five candidates now. Keep the whole board in mind."
	))
	stages.append(StageDataScript.new(
		11,
		"Five marks",
		Vector2i(2, 4),
		[Vector2i(1, 0), Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, 2), Vector2i(4, 0)],
		3,
		true,
		"Another five-candidate board. Trust the rules, not a habit."
	))
	stages.append(StageDataScript.new(
		12,
		"Blind Smash",
		Vector2i(2, 4),
		[
			Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(2, 1),
			Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 0), Vector2i(4, 0)
		],
		4,
		true,
		"Final exam. Use every answer, every step, and every stopping position."
	))
	return stages
