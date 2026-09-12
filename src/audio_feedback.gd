extends Node

# Temporary, asset-free audio/feel layer for the Stage 1 vertical slice.
# Replace these generated streams with Kenney/itch.io audio later without touching
# the puzzle rules in main.gd.

const MIX_RATE := 22050
const SMASH_WINDUP := 0.18
const SMASH_SWING_DELAY := 0.16
const SMASH_REVEAL_HOLD := 0.38

var game: Node
var step_player: AudioStreamPlayer
var feedback_player: AudioStreamPlayer
var smash_player: AudioStreamPlayer
var smash_overlay: Label

var streams: Dictionary = {}
var previous_position := Vector2i(-999, -999)
var previous_result_text := ""
var previous_phase := ""
var initialized := false
var smash_sequence_running := false


func _ready() -> void:
	game = get_parent()
	_build_audio_players()
	_build_overlay()
	_build_streams()


func _process(_delta: float) -> void:
	if not _game_is_ready():
		return

	var phase := str(game.get("phase"))
	var player_position: Vector2i = game.get("player_position")
	var result_label := game.get("result_label") as Label
	var result_text := result_label.text

	if not initialized:
		previous_position = player_position
		previous_result_text = result_text
		previous_phase = phase
		initialized = true
		return

	if phase == "moving" and player_position != previous_position:
		_play_stream(step_player, streams["step"], -4.0)
	previous_position = player_position

	if result_text != previous_result_text:
		match result_text:
			"HOTTER":
				_play_stream(feedback_player, streams["hotter"], -3.0)
			"COLDER":
				_play_stream(feedback_player, streams["colder"], -3.0)
			"SAME":
				_play_stream(feedback_player, streams["same"], -5.0)
	previous_result_text = result_text

	if phase != previous_phase:
		if (phase == "clear" or phase == "fail") and not smash_sequence_running:
			_play_smash_sequence.call_deferred(phase == "clear")
		previous_phase = phase


func _game_is_ready() -> bool:
	if game == null:
		return false
	if game.get("result_label") == null:
		return false
	if game.get("message_label") == null:
		return false
	return true


func _build_audio_players() -> void:
	step_player = AudioStreamPlayer.new()
	step_player.name = "StepSfx"
	add_child(step_player)

	feedback_player = AudioStreamPlayer.new()
	feedback_player.name = "FeedbackSfx"
	add_child(feedback_player)

	smash_player = AudioStreamPlayer.new()
	smash_player.name = "SmashSfx"
	add_child(smash_player)


func _build_overlay() -> void:
	var overlay_center := CenterContainer.new()
	overlay_center.name = "SmashOverlayLayer"
	overlay_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_center.z_index = 100
	game.add_child.call_deferred(overlay_center)

	smash_overlay = Label.new()
	smash_overlay.text = ""
	smash_overlay.visible = false
	smash_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	smash_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	smash_overlay.custom_minimum_size = Vector2(320, 84)
	smash_overlay.add_theme_font_size_override("font_size", 38)
	smash_overlay.add_theme_color_override("font_color", Color(0.16, 0.12, 0.08))
	smash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_center.add_child.call_deferred(smash_overlay)


func _build_streams() -> void:
	streams["step"] = _make_noise_stream(0.075, 0.34, 110.0, 101)
	streams["hotter"] = _make_tone_stream(0.18, 520.0, 820.0, 0.55)
	streams["colder"] = _make_tone_stream(0.20, 520.0, 300.0, 0.50)
	streams["same"] = _make_tone_stream(0.16, 440.0, 440.0, 0.34)
	streams["swing"] = _make_noise_stream(0.16, 0.28, 260.0, 202)
	streams["hit"] = _make_hit_stream(0.24, 303)
	streams["miss"] = _make_noise_stream(0.18, 0.22, 520.0, 404)


func _play_stream(player: AudioStreamPlayer, stream: AudioStream, volume_db: float = 0.0) -> void:
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func _play_smash_sequence(success: bool) -> void:
	if smash_sequence_running or not _game_is_ready():
		return
	smash_sequence_running = true

	var result_label := game.get("result_label") as Label
	var message_label := game.get("message_label") as Label
	var result_modulate := result_label.modulate
	var message_modulate := message_label.modulate

	result_label.modulate = Color(result_modulate.r, result_modulate.g, result_modulate.b, 0.0)
	message_label.modulate = Color(message_modulate.r, message_modulate.g, message_modulate.b, 0.0)

	smash_overlay.visible = true
	smash_overlay.modulate = Color.WHITE
	smash_overlay.scale = Vector2.ONE
	smash_overlay.text = "READY..."
	await get_tree().create_timer(SMASH_WINDUP).timeout

	smash_overlay.text = "SWING!"
	_play_stream(smash_player, streams["swing"], -3.0)
	var windup_tween := create_tween()
	windup_tween.tween_property(smash_overlay, "scale", Vector2(1.08, 1.08), SMASH_SWING_DELAY).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(SMASH_SWING_DELAY).timeout

	if success:
		smash_overlay.text = "SMASH!"
		smash_overlay.add_theme_color_override("font_color", Color(0.12, 0.58, 0.24))
		_play_stream(smash_player, streams["hit"], -1.0)
	else:
		smash_overlay.text = "SWISH..."
		smash_overlay.add_theme_color_override("font_color", Color(0.58, 0.18, 0.18))
		_play_stream(smash_player, streams["miss"], -3.0)

	var reveal_tween := create_tween()
	smash_overlay.scale = Vector2(0.90, 0.90)
	reveal_tween.tween_property(smash_overlay, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(SMASH_REVEAL_HOLD).timeout

	smash_overlay.visible = false
	smash_overlay.add_theme_color_override("font_color", Color(0.16, 0.12, 0.08))
	result_label.modulate = result_modulate
	message_label.modulate = message_modulate
	smash_sequence_running = false


func _make_tone_stream(duration: float, start_hz: float, end_hz: float, amplitude: float) -> AudioStreamWAV:
	var sample_count := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(sample_count)

	for i in range(sample_count):
		var progress := float(i) / maxf(1.0, float(sample_count - 1))
		var time := float(i) / float(MIX_RATE)
		var frequency := lerpf(start_hz, end_hz, progress)
		var attack := minf(1.0, progress * 18.0)
		var release := pow(1.0 - progress, 1.6)
		var envelope := attack * release
		var sample := sin(TAU * frequency * time) * amplitude * envelope
		data[i] = _sample_to_byte(sample)

	return _make_wav(data)


func _make_noise_stream(duration: float, amplitude: float, body_hz: float, seed_value: int) -> AudioStreamWAV:
	var sample_count := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(sample_count)
	var noise_rng := RandomNumberGenerator.new()
	noise_rng.seed = seed_value

	for i in range(sample_count):
		var progress := float(i) / maxf(1.0, float(sample_count - 1))
		var time := float(i) / float(MIX_RATE)
		var envelope := pow(1.0 - progress, 2.2)
		var noise := noise_rng.randf_range(-1.0, 1.0) * 0.72
		var body := sin(TAU * body_hz * time) * 0.28
		var sample := (noise + body) * amplitude * envelope
		data[i] = _sample_to_byte(sample)

	return _make_wav(data)


func _make_hit_stream(duration: float, seed_value: int) -> AudioStreamWAV:
	var sample_count := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(sample_count)
	var noise_rng := RandomNumberGenerator.new()
	noise_rng.seed = seed_value

	for i in range(sample_count):
		var progress := float(i) / maxf(1.0, float(sample_count - 1))
		var time := float(i) / float(MIX_RATE)
		var envelope := pow(1.0 - progress, 2.8)
		var low_body := sin(TAU * 115.0 * time) * 0.48
		var crack := noise_rng.randf_range(-1.0, 1.0) * 0.62
		var bright := sin(TAU * 620.0 * time) * 0.16
		var sample := (low_body + crack + bright) * 0.72 * envelope
		data[i] = _sample_to_byte(sample)

	return _make_wav(data)


func _sample_to_byte(sample: float) -> int:
	var clamped := clampf(sample, -1.0, 1.0)
	var signed_sample := int(round(clamped * 127.0))
	return signed_sample & 0xFF


func _make_wav(data: PackedByteArray) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav
