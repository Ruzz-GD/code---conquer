extends Control

@onready var difficulty_btn = $"difficulty-btn"
@onready var new_game_btn = $"new-game-btn"
@onready var exit_btn = $"exit-btn"
@onready var info_router = $"../info-route"
@onready var setting_modal = $"setting-modal"

var player

func _ready():
	await get_tree().process_frame

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("✅ Player found via group:", player)
	else:
		print("❌ No player found in group 'player'")

	info_router.visible = false
	setting_modal.visible = false

	difficulty_btn.clear()
	difficulty_btn.add_item("Difficulty: Medium")
	difficulty_btn.add_item("Difficulty: Hard")
	difficulty_btn.selected = 0

	difficulty_btn.custom_minimum_size = Vector2(260, 50)
	new_game_btn.custom_minimum_size = Vector2(260, 50)
	exit_btn.custom_minimum_size = Vector2(260, 50)

	GameManager.connect("game_reset", Callable(self, "_on_game_reset"))

func _on_game_reset():
	if not GameManager.is_game_started:
		difficulty_btn.selected = 0
		show()


func _on_back_pressed() -> void:
	setting_modal.visible = false

func _on_infobtn_pressed() -> void:
	info_router.visible = true

func _on_settingbtn_pressed() -> void:
	setting_modal.visible = true

func _on_exitbtn_pressed() -> void:
	get_tree().quit()


func _on_newgamebtn_pressed() -> void:
	var selected_index = difficulty_btn.selected
	match selected_index:
		0:
			GameManager.difficulty = "Medium"
			if player:
				player.max_hints = 3
				player.current_hints = 1
		1:
			GameManager.difficulty = "Hard"
			if player:
				player.max_hints = 0
				player.current_hints = 0

	GameManager.is_game_started = true

	if player:
		player.emit_signal("player_hints_changed", player.current_hints)

	hide()
	print("🟢 Game Started on Difficulty:", GameManager.difficulty)
