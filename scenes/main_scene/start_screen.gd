extends Control

@onready var difficulty_btn = $"difficulty-btn"
@onready var new_game_btn = $"new-game-btn"
@onready var exit_btn = $"exit-btn"
@onready var info_router = $"../info-route"
@onready var setting_modal = $"setting-modal"
@onready var to_addusername_con = $"to-addusername-container"
@onready var player_username = $"to-addusername-container/TextEdit"
@onready var welcome_message = $welcome_player
@onready var saved_game_container = $view_saved_game_container
@onready var saved_game_list = $view_saved_game_container/saved_game_list

var player

func _ready():
	await get_tree().process_frame
	GameManager.connect("username_changed", Callable(self, "_on_username_changed"))

	_on_username_changed(GameManager.player_username)
	saved_game_container.hide()
	to_addusername_con.hide()
	if saved_game_list.get_child_count() > 0:
		saved_game_list.get_child(0).visible = false
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
	info_router.visible = true

func _on_settingbtn_pressed() -> void:
	setting_modal.visible = true

func _on_closebtn_pressed() -> void:
	to_addusername_con.hide()

func _on_submitbtn_addusername_pressed() -> void:
	var name = player_username.text.strip_edges()
	GameManager.player_username = name
	to_addusername_con.hide()
	setting_modal.hide()

func _on_exitbtn_pressed() -> void:
	get_tree().quit()

func _on_closesavecon_pressed() -> void:
	saved_game_container.hide()

func _on_open_saved_game_pressed() -> void:
	saved_game_container.show()
	_populate_saved_game_list()

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

	# ✅ Stop menu music before starting game
	$"../../MenuMusic".stop()

	hide()
	print("🟢 Game Started on Difficulty:", GameManager.difficulty)

# Main method to populate save list using your template row
func _populate_saved_game_list() -> void:
	# Keep the first child as template, remove all others
	for i in range(saved_game_list.get_child_count() - 1, 0, -1):
		saved_game_list.get_child(i).queue_free()

	var dir = DirAccess.open("user://code_conquer_saves_gameplay")
	if not dir:
		print("❌ Failed to open save directory.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file_path = "user://code_conquer_saves_gameplay/%s" % file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				var parsed = JSON.parse_string(content)
				if typeof(parsed) == TYPE_DICTIONARY:
					var username = parsed.get("player_username", "Unknown")
					_add_save_row(file_name, username)
				file.close()
		file_name = dir.get_next()
	dir.list_dir_end()

func _add_save_row(file_name: String, username: String) -> void:
	var template_panel = saved_game_list.get_child(0)
	var new_row = template_panel.duplicate()
	new_row.visible = true

	# Load the save file content to read the save_station_map
	var file_path = "user://code_conquer_saves_gameplay/%s" % file_name
	var save_station_map = "Unknown"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_DICTIONARY:
				save_station_map = parsed.get("save_station_map", "Unknown")

	var label = new_row.get_node("Label")
	if label:
		label.text = "👤 %s | 📂 %s | 🏷️ Floor: %s" % [username, file_name, save_station_map]

	var delete_btn = new_row.get_node("delete-btn")
	if delete_btn:
		delete_btn.pressed.connect(func():
			var full_path = "user://code_conquer_saves_gameplay/%s" % file_name
			if FileAccess.file_exists(full_path):
				DirAccess.remove_absolute(full_path)
				print("🗑️ Deleted:", file_name)
				_populate_saved_game_list()
		)

	var load_btn = new_row.get_node("load-game-btn")
	if load_btn:
		load_btn.pressed.connect(func():
			print("📂 Loading save:", file_name)

			# ✅ Stop menu music before loading save
			$"../../MenuMusic".stop()

			SaveSystem.load_game(file_name)
			hide()
		)

	saved_game_list.add_child(new_row)
