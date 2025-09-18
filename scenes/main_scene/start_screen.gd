extends Control

@onready var difficulty_btn = $"difficulty-btn"
@onready var new_game_btn = $"new-game-btn"
@onready var exit_btn = $"exit-btn"
@onready var info_router = $"../info-route"
@onready var setting_modal = $"setting-modal"
@onready var to_addusername_con = $"to-addusername-container"
@onready var player_added_username = $"to-addusername-container/TextEdit"
@onready var welcome_message = $welcome_player
@onready var history_modal = $view_history
@onready var saved_game_modal = $saved_game_modal
@onready var SoundSystemPanel = $"../SoundSystemPanel"
var player

func _ready():
	show()
	await get_tree().process_frame
	GameManager.connect("username_changed", Callable(self, "_on_username_changed"))

	_on_username_changed(GameManager.player_username)
	to_addusername_con.hide()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("✅ Player found via group:", player)
	else:
		print("❌ No player found in group 'player'")

	info_router.visible = false
	setting_modal.visible = false
	history_modal.hide()
	difficulty_btn.clear()
	difficulty_btn.add_item("Difficulty: Medium")
	difficulty_btn.add_item("Difficulty: Hard")
	difficulty_btn.selected = 0

	difficulty_btn.custom_minimum_size = Vector2(260, 50)
	new_game_btn.custom_minimum_size = Vector2(260, 50)
	exit_btn.custom_minimum_size = Vector2(260, 50)

	GameManager.connect("game_reset", Callable(self, "_on_game_reset"))

func clear_history_files():
	var folder_path = "user://code_conquer_saves_gameplay"
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot access folder: %s" % folder_path)
		return

	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with("_game_history.txt"):
			var file_path = "%s/%s" % [folder_path, filename]
			var err = dir.remove(filename)  # remove by filename in this folder
			if err == OK:
				print("Deleted history file: ", file_path)
			else:
				push_error("Failed to delete file: %s" % file_path)
		filename = dir.get_next()
	dir.list_dir_end()

func _on_game_reset():
	if not GameManager.is_game_started:
		difficulty_btn.selected = 0
		show()

func _on_username_changed(new_username: String) -> void:
	if new_username.strip_edges() == "":
		welcome_message.text = "❗ Please input a username"
	else:
		welcome_message.text = "Welcome %s To!" % new_username

func _on_back_pressed() -> void:
	setting_modal.visible = false

func _on_addusername_pressed() -> void:
	to_addusername_con.show()

func _on_infobtn_pressed() -> void:
	info_router.show()
	setting_modal.hide()

func _on_settingbtn_pressed() -> void:
	setting_modal.show()
	saved_game_modal.hide()
	history_modal.hide()

func _on_closebtn_pressed() -> void:
	to_addusername_con.hide()

func _on_submitbtn_addusername_pressed() -> void:
	var name = player_added_username.text.strip_edges()
	GameManager.player_username = name
	to_addusername_con.hide()
	setting_modal.hide()

func _on_exitbtn_pressed() -> void:
	get_tree().quit()

func _on_closesavecon_pressed() -> void:
	saved_game_modal.hide()

func _on_open_saved_game_pressed() -> void:
	saved_game_modal.show()
	history_modal.hide()
	setting_modal.hide()


func _on_newgamebtn_pressed() -> void:
	if GameManager.player_username.strip_edges() == "":
		welcome_message.text = "❗ Please input a username"
		return

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
	GameManager.update_map(GameManager.current_map_path, GameManager.spawn_marker_name)

	if player:
		player.emit_signal("player_hints_changed", player.current_hints)


	hide()
	print("🟢 Game Started on Difficulty:", GameManager.difficulty)


func _on_audio_pressed() -> void:
	SoundSystemPanel.show()


func _on_historybtn_pressed() -> void:
	history_modal.show()
	history_modal._populate_history_list()
	saved_game_modal.hide()
	setting_modal.hide()


func _on_closehistorymodal_pressed() -> void:
	history_modal.hide()
