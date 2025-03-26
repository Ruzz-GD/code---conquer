extends Control

signal challenge_solved  # Signal to notify the door

@onready var panel = $Panel  # Modal box
@onready var answer_input = $Panel/TextEdit
@onready var submit_button = $Panel/SubmitButton
@onready var challenge_label = $Panel/Label
@onready var closed_button = $Panel/ClosedButton  # The "X" button to close the panel

var correct_answer = "Hello World"  # Example correct answer

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	closed_button.pressed.connect(_on_close_pressed)
	hide()  # Hide the whole UI at start

func show_debug_ui():
	print("📌 Showing Debug UI modal!")
	show()  # Show modal
	panel.visible = true  # Show the modal box
	answer_input.grab_focus()  # Auto-focus on input field

func _on_submit_pressed():
	if answer_input.text.strip_edges() == correct_answer:
		print("✅ Debugging success!")
		challenge_solved.emit()  # Notify door
		hide()  # Hide modal after solving
		GameManager.enable_player_action.emit()  # ✅ Allow movement again
	else:
		print("❌ Wrong answer! Try again.")

func _on_close_pressed():
	print("❌ Challenge skipped.")
	GameManager.enable_player_action.emit()  # ✅ Allow movement again
	hide()  # Hide the modal when the player clicks the close button
