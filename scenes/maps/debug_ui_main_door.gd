extends Control

signal challenge_solved  # Signal to notify the door

@onready var panel = $Panel  # Modal box
@onready var answer_input = $Panel/TextEdit
@onready var submit_button = $Panel/SubmitButton
@onready var challenge_label = $Panel/Label
@onready var closed_button = $Panel/ClosedButton  # The "X" button to close the panel
@onready var error_label = $Panel/ErrorLabel  # Label to show error message
@onready var error_timer = $Panel/ErrorTimer  # Timer to hide the error message

var correct_answer = "5"  # Example correct answer

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	closed_button.pressed.connect(_on_close_pressed)
	error_timer.timeout.connect(_hide_error_message)  # Connect timer to function
	hide()  # Hide the whole UI at start
	error_label.hide()  # Hide error message at start

func show_debug_ui():
	print("📌 Showing Debug UI modal!")
	show()  # Show modal
	panel.visible = true  # Show the modal box
	answer_input.grab_focus()  # Auto-focus on input field

func _on_submit_pressed():
	var user_input = answer_input.text.strip_edges()
	
	if user_input == correct_answer:
		print("✅ Debugging success!")
		challenge_solved.emit()  # Notify door
		hide()  # Hide modal after solving
		GameManager.enable_player_action.emit()  # ✅ Allow movement again
	else:
		print("❌ Wrong answer! Debugging failed!")
		_show_error_message()  # Show error message
		answer_input.text = ""  # Clear input field

func _show_error_message():
	error_label.text = "❌ Debugging failed! Try again."
	error_label.show()  # Show error message
	error_timer.start(5)  # Start timer for 5 seconds

func _hide_error_message():
	error_label.hide()  # Hide error message after timeout

func _on_close_pressed():
	print("❌ Challenge skipped.")
	GameManager.enable_player_action.emit()  # ✅ Allow movement again
	hide()  # Hide the modal when the player clicks the close button
