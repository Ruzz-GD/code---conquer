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
var current_chest: Node = null  # ✅ Track the chest using this UI
var used_medium := []
var used_hard := []


var medium_challenges = [
	{
		"buggy_code": 'status = "Ready"\nif staus == "Ready":\n    print("System ready")',
		"correct_fix": 'status = "Ready"\nif status == "Ready":\n    print("System ready")',
		"expected_output": 'System ready'
	},
	{
		"buggy_code": 'temp = 35\nif temp > 30\n    print("Overheat!")',
		"correct_fix": 'temp = 35\nif temp > 30:\n    print("Overheat!")',
		"expected_output": 'Overheat!'
	},
	{
		"buggy_code": 'access = True\nif acess == True:\n    print("Access granted")',
		"correct_fix": 'access = True\nif access == True:\n    print("Access granted")',
		"expected_output": 'Access granted'
	},
	{
		"buggy_code": 'mode = "safe"\nif mode = "safe":\n    print("Safe mode active")',
		"correct_fix": 'mode = "safe"\nif mode == "safe":\n    print("Safe mode active")',
		"expected_output": 'Safe mode active'
	},
	{
		"buggy_code": 'power = 0\nif power:\nprint("Powered")',
		"correct_fix": 'power = 0\nif power:\n    print("Powered")',
		"expected_output": ''
	},
	{
		"buggy_code": 'level = 2\nif level => 2:\n    print("Level 2 ready")',
		"correct_fix": 'level = 2\nif level >= 2:\n    print("Level 2 ready")',
		"expected_output": 'Level 2 ready'
	},
	{
		"buggy_code": 'signal = "lost"\nif signal != lost:\n    print("Signal OK")',
		"correct_fix": 'signal = "lost"\nif signal != "lost":\n    print("Signal OK")',
		"expected_output": ''
	},
	{
		"buggy_code": 'x = 5\nif x = 5:\n    print("X is five")',
		"correct_fix": 'x = 5\nif x == 5:\n    print("X is five")',
		"expected_output": 'X is five'
	},
	{
		"buggy_code": 'flag = Ture\nif flag:\n    print("OK")',
		"correct_fix": 'flag = True\nif flag:\n    print("OK")',
		"expected_output": 'OK'
	},
	{
		"buggy_code": 'status = "error"\nif status = "error":\n    print("Error!")',
		"correct_fix": 'status = "error"\nif status == "error":\n    print("Error!")',
		"expected_output": 'Error!'
	},
	{
		"buggy_code": 'value = 10\nif (value > 5)\n    print("Valid")',
		"correct_fix": 'value = 10\nif value > 5:\n    print("Valid")',
		"expected_output": 'Valid'
	},
	{
		"buggy_code": 'battery = "Low"\nif battery == low:\n    print("Charge now")',
		"correct_fix": 'battery = "Low"\nif battery == "Low":\n    print("Charge now")',
		"expected_output": 'Charge now'
	},
	{
		"buggy_code": 'speed = 100\nif speed => 100:\n    print("Full speed")',
		"correct_fix": 'speed = 100\nif speed >= 100:\n    print("Full speed")',
		"expected_output": 'Full speed'
	},
	{
		"buggy_code": 'mode = auto\nif mode == "auto":\n    print("Autonomous")',
		"correct_fix": 'mode = "auto"\nif mode == "auto":\n    print("Autonomous")',
		"expected_output": 'Autonomous'
	},
	{
		"buggy_code": 'enabled = True\nif enabled == true:\n    print("Enabled")',
		"correct_fix": 'enabled = True\nif enabled == True:\n    print("Enabled")',
		"expected_output": 'Enabled'
	}
]

var hard_challenges = [
	{
		"buggy_code": 'temp = "high\nif temp == high:\nprint("Warning")',
		"correct_fix": 'temp = "high"\nif temp == "high":\n    print("Warning")',
		"expected_output": 'Warning'
	},
	{
		"buggy_code": 'battery = 30\nif battery => 20\nprint("Battery OK")\nelse:\nprint("Low")',
		"correct_fix": 'battery = 30\nif battery >= 20:\n    print("Battery OK")\nelse:\n    print("Low")',
		"expected_output": 'Battery OK'
	},
	{
		"buggy_code": 'signal = lost\nif signal = "lost":\nprint("Searching...")',
		"correct_fix": 'signal = "lost"\nif signal == "lost":\n    print("Searching...")',
		"expected_output": 'Searching...'
	},
	{
		"buggy_code": 'x = 5\ny = 10\nif y > x print("Y wins")',
		"correct_fix": 'x = 5\ny = 10\nif y > x:\n    print("Y wins")',
		"expected_output": 'Y wins'
	},
	{
		"buggy_code": 'val = "42\nif val == 42:\nprint(Valid)',
		"correct_fix": 'val = 42\nif val == 42:\n    print("Valid")',
		"expected_output": 'Valid'
	},
	{
		"buggy_code": 'active = "True"\nif active = True:\nprint("Yes")',
		"correct_fix": 'active = True\nif active == True:\n    print("Yes")',
		"expected_output": 'Yes'
	},
	{
		"buggy_code": 'temp = "cold"\nif temp != warm:\nprint("Too cold")',
		"correct_fix": 'temp = "cold"\nif temp != "warm":\n    print("Too cold")',
		"expected_output": 'Too cold'
	},
	{
		"buggy_code": 'danger = 1\nif danger => 1:\nprint(Alert!)',
		"correct_fix": 'danger = 1\nif danger >= 1:\n    print("Alert!")',
		"expected_output": 'Alert!'
	},
	{
		"buggy_code": 'robot_mode = "manual"\nif robot_mode = "auto":\nprint("Auto mode")\nelse\nprint("Manual mode")',
		"correct_fix": 'robot_mode = "manual"\nif robot_mode == "auto":\n    print("Auto mode")\nelse:\n    print("Manual mode")',
		"expected_output": 'Manual mode'
	},
	{
		"buggy_code": 'val = "10"\nif val > 5:\nprint("Valid")',
		"correct_fix": 'val = 10\nif val > 5:\n    print("Valid")',
		"expected_output": 'Valid'
	},
	{
		"buggy_code": 'status = "offline"\nif status == "online"\nprint("Online")',
		"correct_fix": 'status = "offline"\nif status == "online":\n    print("Online")',
		"expected_output": ''
	},
	{
		"buggy_code": 'weapon = "Laser\nif weapon == "Laser":\nprint("Equipped Laser")',
		"correct_fix": 'weapon = "Laser"\nif weapon == "Laser":\n    print("Equipped Laser")',
		"expected_output": 'Equipped Laser'
	},
	{
		"buggy_code": 'on = ture\nif on:\nprint("Power on")',
		"correct_fix": 'on = True\nif on:\n    print("Power on")',
		"expected_output": 'Power on'
	},
	{
		"buggy_code": 'code = 1234\nif code = 1234:\nprint("Unlocked")',
		"correct_fix": 'code = 1234\nif code == 1234:\n    print("Unlocked")',
		"expected_output": 'Unlocked'
	},
	{
		"buggy_code": 'signal = 0\nif signal == 1:\nprint("Signal On")\nelse\nprint("Off")',
		"correct_fix": 'signal = 0\nif signal == 1:\n    print("Signal On")\nelse:\n    print("Off")',
		"expected_output": 'Off'
	}
]

# Active challenge data
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
	var used = used_medium if difficulty == "Medium" else used_hard

	# Remove already-used challenges
	var available := pool.filter(func(ch): return not used.has(ch))

	# If all have been used, reset
	if available.is_empty():
		used.clear()
		available = pool.duplicate()

	selected_challenge = available[randi() % available.size()]
	used.append(selected_challenge)

	buggy_code = selected_challenge["buggy_code"]
	correct_fix = selected_challenge["correct_fix"]
	expected_output = selected_challenge["expected_output"]
func show_debug_ui(caller_node: Node, challenge: Dictionary):
	current_chest = caller_node
	selected_challenge = challenge

	# 🔧 Apply challenge data from the passed challenge dictionary
	buggy_code = challenge["buggy_code"]
	correct_fix = challenge["correct_fix"]
	expected_output = challenge["expected_output"]

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
		if current_chest:
			current_chest._on_challenge_solved()
		hide()
		_disable_player_input(false)
	else:
		print("❌ Incorrect fix submitted.")
		_show_error_message()

func _on_skip_pressed():
	if player and player.current_hints > 0:
		player.use_hint()
		print("🪄 Used a skip skill! Bug fixed automatically.")
		if current_chest:
			current_chest._on_challenge_solved()
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
		player.typing = state
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
