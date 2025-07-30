




extends Control

@onready var panel = $Panel
@onready var debug_input = $Panel/TextEdit
@onready var submit_button = $Panel/SubmitButton
@onready var closed_button = $Panel/ClosedButton
@onready var skip_skill = $Panel/SkipButton
@onready var error_label = $Panel/ErrorLabel
@onready var error_timer = $Panel/ErrorTimer
@onready var to_view_expected_output = $Panel/ViewExpectedOutput

var player: Node = null
var showing_expected_output := false
var selected_challenge := {}
var current_door: Node = null  # ✅ Will hold the door that triggered this UI

# 🧩 Challenge pools
var medium_challenges = [
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

var hard_challenges = [
	{
		"buggy_code": 'a = 10\nb == "5"\nsum = a - b\nprint("Sum is " + sm)',
		"correct_fix": 'a = 10\nb = 5\nsum = a + b\nprint("Sum is " + str(sum))',
		"expected_output": 'Sum is 15'
	},
	{
		"buggy_code": 'x == 4\ny = "2\nz = x * y\nprint(Result: " + z)',
		"correct_fix": 'x = 4\ny = 2\nz = x * y\nprint("Result: " + str(z))',
		"expected_output": 'Result: 8'
	},
	{
		"buggy_code": 'temp_c = 100\ntemp_f = tempC * 9 / 5\nprint("Fahrenheit " + temp_f)',
		"correct_fix": 'temp_c = 100\ntemp_f = temp_c * 9 / 5 + 32\nprint("Fahrenheit: " + str(temp_f))',
		"expected_output": 'Fahrenheit: 212.0'
	},
	{
		"buggy_code": 'width = "5\nheigt = 3\narea = width + height\nprint("Area: " + area)',
		"correct_fix": 'width = 5\nheight = 3\narea = width * height\nprint("Area: " + str(area))',
		"expected_output": 'Area: 15'
	},
	{
		"buggy_code": 'radius = 7\npi = "3.14\ncircum = radius x pi x 2\nprint("Circumference " + circum)',
		"correct_fix": 'radius = 7\npi = 3.14\ncircum = radius * pi * 2\nprint("Circumference: " + str(circum))',
		"expected_output": 'Circumference: 43.96'
	}
]

# Challenge data
var buggy_code := ""
var correct_fix := ""
var expected_output := ""

func _ready():
	GameManager.difficulty_changed.connect(_on_difficulty_changed)
	set_random_challenge(GameManager.difficulty)

	submit_button.pressed.connect(_on_submit_pressed)
	closed_button.pressed.connect(_on_close_pressed)
	skip_skill.pressed.connect(_on_skip_pressed)
	to_view_expected_output.pressed.connect(_on_view_output_toggle)
	error_timer.timeout.connect(_hide_error_message)

	hide()
	error_label.hide()
	player = get_tree().current_scene.find_child("Player", true, false)

func _on_difficulty_changed(new_difficulty: String):
	set_random_challenge(new_difficulty)

func set_random_challenge(difficulty: String):
	var pool = medium_challenges if difficulty == "Medium" else hard_challenges
	selected_challenge = pool[randi() % pool.size()]
	buggy_code = selected_challenge["buggy_code"]
	correct_fix = selected_challenge["correct_fix"]
	expected_output = selected_challenge["expected_output"]

func show_debug_ui(door: Node, challenge: Dictionary):
	current_door = door
	selected_challenge = challenge
	buggy_code = selected_challenge["buggy_code"]
	correct_fix = selected_challenge["correct_fix"]
	expected_output = selected_challenge["expected_output"]

	showing_expected_output = false
	to_view_expected_output.text = "🔍 View Expected Output"
	debug_input.editable = true
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
		if current_door:
			current_door.solve_challenge()
		hide()
		_disable_player_input(false)
	else:
		print("❌ Incorrect fix submitted.")
		_show_error_message()

func _on_skip_pressed():
	if player and player.current_hints > 0:
		player.use_hint()
		print("🪄 Skip skill used! Auto-solve challenge.")
		if current_door:
			current_door.solve_challenge()
		hide()
		_disable_player_input(false)
	else:
		error_label.text = "❌ No more Skip Skills!"
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
		player.typing = state
		print("🔧 typing_cant_move set to:", state)
	else:
		print("❌ Player not found.")

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
