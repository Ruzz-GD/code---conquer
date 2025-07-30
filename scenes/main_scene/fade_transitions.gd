extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready() -> void:
	# Ensure it's invisible and transparent at game start
	visible = false
	color_rect.modulate.a = 0.0

# Fades in, calls a function, waits, then fades out
func fade_to_black_then(func_to_call: Callable, wait_time: float = 2.5) -> void:
	color_rect.modulate.a = 0
	show()

	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func_to_call)
	tween.tween_interval(wait_time)  # ⏱ wait before fading out
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)
