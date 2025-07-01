extends Control

signal challenge_solved

# UI Nodes
@onready var panel = $Panel
@onready var debug_input = $Panel/TextEdit
@onready var submit_button = $Panel/SubmitButton
@onready var closed_button = $Panel/ClosedButton
@onready var skip_skill = $Panel/SkipButton
@onready var error_label = $Panel/ErrorLabel
@onready var error_timer = $Panel/ErrorTimer
@onready var to_view_expected_output = $Panel/ViewExpectedOutput

# Player reference
var player: Node = null
var showing_expected_output := false

# 🧩 Challenge pool
var buggy_code_problem = [
	{
		"buggy_code": 'username = "ECHO-7\nprint("Welcome " + usernme)',
		"correct_fix": 'username = "ECHO-7"\nprint("Welcome " + username)',
		"expected_output": 'Welcome ECHO-7'
	},
	{
		"buggy_code": 'code = "ACCESS-GRANTED\nprint("Code: " + c0de)',
		"correct_fix": 'code = "ACCESS-GRANTED"\nprint("Code: " + code)',
		"expected_output": 'Code: ACCESS-GRANTED'
	},
	{
		"buggy_code": 'print("Battery level: " + battery)',
		"correct_fix": 'battery = "90%"\nprint("Battery level: " + battery)',
		"expected_output": 'Battery level: 90%'
	},
	{
		"buggy_code": 'wepon = "Laser"\nprint("Weapon: Sword")',
		"correct_fix": 'weapon = "Laser"\nprint("Weapon: " + weapon)',
		"expected_output": 'Weapon: Laser'
	},
	{
		"buggy_code": 'status = "Online"\nprint "Status: " + stat',
		"correct_fix": 'status = "Online"\nprint("Status: " + status)',
		"expected_output": 'Status: Online'
	}
]

# Current challenge data
var buggy_code := ""
var correct_fix := ""
var expected_output := ""

func _ready():
	submit_button.pressed.connect(_on_submit_pressed)
	closed_button.pressed.connect(_on_close_pressed)
	skip_skill.pressed.connect(_on_skip_pressed)
	to_view_expected_output.pressed.connect(_on_view_output_toggle)
	error_timer.timeout.connect(_hide_error_message)

	hide()
	error_label.hide()

	player = get_tree().current_scene.find_child("Player", true, false)

func show_debug_ui():
	showing_expected_output = false
	to_view_expected_output.text = "🔍 View Expected Output"
	debug_input.editable = true

	# 👇 Pick a random challenge from the pool when shown
	var challenge = buggy_code_problem.pick_random()
	buggy_code = challenge["buggy_code"]
	correct_fix = challenge["correct_fix"]
	expected_output = challenge["expected_output"]
	debug_input.text = buggy_code

	show()
	panel.visible = true
	error_label.text = "🛠️ I Need To Fix This Buggy Code"
	error_label.show()

	if player:
		skip_skill.disabled = player.current_hints <= 0

	_disable_player_input(true)

func _normalize_code(code: String) -> String:
	var lines := code.split("\n")
	var cleaned := []
	for line in lines:
		cleaned.append(line.strip_edges())
	return "\n".join(cleaned)

func _on_submit_pressed():
	var answer := _normalize_code(debug_input.text.strip_edges())
	var expected := _normalize_code(correct_fix)

	if answer == expected:
		print("✅ Debugging success!")
		challenge_solved.emit()
		hide()
		_disable_player_input(false)
	else:
		print("❌ Incorrect fix submitted.")
		_show_error_message()

func _on_skip_pressed():
	if player and player.current_hints > 0:
		player.use_hint()
		print("🪄 Used a skip skill! Bug fixed automatically.")
		challenge_solved.emit()
		hide()
		_disable_player_input(false)
	else:
		error_label.text = "❌ No more Skip Skills available!"
		error_label.show()
		error_timer.start(5)

func _show_error_message():
	error_label.text = "❌ Debugging failed! Try again."
	error_label.show()
	error_timer.start(5)

func _hide_error_message():
	error_label.hide()

func _on_close_pressed():
	hide()
	_disable_player_input(false)

func _disable_player_input(state: bool):
	if player == null:
		player = get_tree().current_scene.find_child("Player", true, false)

	if player:
		player.typing_cant_move = state
		print("🔧 typing_cant_move set to:", state)
	else:
		print("❌ Player not found when trying to set typing_cant_move.")

func _on_view_output_toggle():
	showing_expected_output = !showing_expected_output

	if showing_expected_output:
		debug_input.editable = false
		debug_input.text = expected_output
		to_view_expected_output.text = "🔁 Back to Debug Code"
	else:
		debug_input.editable = true
		debug_input.text = buggy_code
		to_view_expected_output.text = "🔍 View Expected Output"
