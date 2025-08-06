extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label_container = $LabelContainer
@onready var transition_label = $TransitionLabel

var wave_phase := 0.0
var wave_timer: Timer
var letter_labels: Array[Label] = []
const TEXT := "Loading..."
const FONT_SIZE := 38
const FONT_COLOR := Color(0, 1, 1)  # Cyan

func _ready() -> void:
	visible = false
	color_rect.modulate.a = 0.0
	label_container.visible = false

	GameManager.map_updated.connect(_on_map_changed)
	GameManager.game_loaded.connect(_on_game_loaded)
	GameManager.game_reset.connect(_on_game_reset)

	wave_timer = Timer.new()
	wave_timer.wait_time = 0.05
	wave_timer.timeout.connect(_on_wave_update)
	wave_timer.one_shot = false
	add_child(wave_timer)

	_create_wave_labels(TEXT)

func set_transition_message(message: String) -> void:
	transition_label.text = message
	transition_label.visible = true

func _create_wave_labels(text: String) -> void:
	for child in label_container.get_children():
		child.queue_free()  # Remove old letters

	letter_labels.clear()

	for char in text:
		var label = Label.new()
		label.text = char
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# Set custom font size and color
		var settings = LabelSettings.new()
		settings.font_size = FONT_SIZE
		label.label_settings = settings

		label.add_theme_color_override("font_color", FONT_COLOR)

		label_container.add_child(label)
		letter_labels.append(label)

func fade_to_black_then(func_to_call: Callable, wait_time: float = 5.0) -> void:
	color_rect.modulate.a = 1.0
	show()

	label_container.visible = true
	start_wave_animation()

	var tween = get_tree().create_tween()
	tween.tween_interval(wait_time)
	tween.tween_callback(func_to_call)
	tween.tween_callback(_hide_label_container) # Hides the text BEFORE fadeout
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_on_fade_out_complete)

func _hide_label_container() -> void:
	label_container.visible = false
	transition_label.visible = false
	stop_wave_animation()

func _on_fade_out_complete() -> void:
	label_container.visible = false
	transition_label.visible = false
	stop_wave_animation()
	hide()

func _on_map_changed(new_map_path: String, new_spawn_marker: String) -> void:
	var readable_name = _get_readable_map_name(new_map_path)
	set_transition_message("Entering: %s" % readable_name)
	fade_to_black_then(_on_transition_complete)

func _on_game_loaded() -> void:
	var readable_name = _get_readable_map_name(GameManager.current_map_path)
	set_transition_message("Entering: %s" % readable_name)
	fade_to_black_then(_on_transition_complete)

func _on_transition_complete() -> void:
	print("🎬 FadeLayer: Transition complete.")

func start_wave_animation() -> void:
	wave_phase = 0.0
	wave_timer.start()

func stop_wave_animation() -> void:
	wave_timer.stop()
	for label in letter_labels:
		label.position.y = 0  # Reset Y offset

func _on_wave_update() -> void:
	wave_phase += 0.2
	for i in letter_labels.size():
		var label = letter_labels[i]
		var offset = sin(wave_phase + i * 0.4) * 5.0
		label.position.y = offset

func _on_game_reset():
	if GameManager.last_reset_reason == GameManager.ResetReason.DEATH:
		set_transition_message("You Died!!")
	elif GameManager.last_reset_reason == GameManager.ResetReason.QUIT:
		set_transition_message("Goodbye!")  # Optional or leave empty
	else:
		set_transition_message("")  # Clear message if unknown

	fade_to_black_then(_on_transition_complete)

func _get_readable_map_name(map_path: String) -> String:
	if map_path == GameManager.first_floor_map:
		return "First-Floor"
	elif map_path == GameManager.second_floor_underground_map:
		return "Second-Floor-Underground"
	elif map_path == GameManager.third_floor_underground_map:
		return "Third-Floor-Underground"
	else:
		return "Unknown Area"
