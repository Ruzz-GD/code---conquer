extends Panel

@onready var code_input = $TextEdit
@onready var result_label = $ResultLabel
@onready var skip_skill_btn = $"skip-skill"

var broken_code1 := "if score = 50:\n    print(\"Passed\")"
var last_visibility_state := false

func _ready():
	code_input.text = broken_code1
	skip_skill_btn.visible = false
	hide()

func _process(_delta: float) -> void:
	# Check for changes to visibility flag in GameManager
	if GameManager.is_drone_debug_modal_visible != last_visibility_state:
		last_visibility_state = GameManager.is_drone_debug_modal_visible
		
		if last_visibility_state:
			code_input.text = broken_code1
			skip_skill_btn.visible = GameManager.difficulty == "Medium"
			show()
		else:
			hide()

func _on_submit_pressed() -> void:
	var player_code = code_input.text.strip_edges()
	if "if score == 50:" in player_code and "print(\"Passed\")" in player_code:
		result_label.text = "✅ Correct! You fixed the bug."
		
		# 💥 Kill the drone
		if GameManager.current_debug_drone and GameManager.current_debug_drone.has_method("die"):
			GameManager.current_debug_drone.die()
			GameManager.current_debug_drone = null  # Clear reference
		
		GameManager.is_drone_debug_modal_visible = false
	else:
		result_label.text = "❌ Still buggy. Try again."

func _on_abort_pressed() -> void:
	GameManager.is_drone_debug_modal_visible = false

func _on_skipskill_pressed() -> void:
	result_label.text = "⏭️ Skill skipped!"
	GameManager.is_drone_debug_modal_visible = false
