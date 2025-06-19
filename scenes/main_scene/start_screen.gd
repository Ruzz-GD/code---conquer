extends Control

@onready var difficulty_btn = $"difficulty-btn"
@onready var play_btn = $"play-btn"
@onready var exit_btn = $"exit-btn"

func _ready():
	# Populate OptionButton
	difficulty_btn.clear()
	difficulty_btn.add_item("Difficulty: Medium")
	difficulty_btn.add_item("Difficulty: Hard")
	difficulty_btn.selected = 0  # Default to Medium

	# Resize all buttons
	difficulty_btn.custom_minimum_size = Vector2(260, 50)
	play_btn.custom_minimum_size = Vector2(260, 50)
	exit_btn.custom_minimum_size = Vector2(260, 50)
	
	# Connect to game reset
	GameManager.connect("game_reset", Callable(self, "_on_game_reset"))

func _on_game_reset():
	if not GameManager.is_game_started:
		print("🔁 Game Reset - Resetting difficulty to Medium")
		difficulty_btn.selected = 0  # Set OptionButton to "Medium"
		GameManager.difficulty = "Medium"  # Reset the actual game state
		self.show()

func _on_playbtn_pressed() -> void:
	var selected_index = difficulty_btn.selected
	match selected_index:
		0:
			GameManager.difficulty = "Medium"
		1:
			GameManager.difficulty = "Hard"

	GameManager.is_game_started = true
	hide()
	print("🟢 Game Started on Difficulty:", GameManager.difficulty)

func _on_exitbtn_pressed() -> void:
	get_tree().quit()
