extends Node2D

signal map_updated(new_map_path, new_spawn_marker)
signal difficulty_changed(new_difficulty: String)
signal username_changed(new_username)
signal game_reset
signal is_game_start
signal save_file_loaded(file_name: String) # ✅ new signal

var player_username: String:
	set(value):
		player_username = value
		emit_signal("username_changed", value)
	get:
		return player_username

# TIMER
var game_timer := 0.0
var is_timer_running := false

# MAPS
var first_floor_map: String = "res://scenes/maps/first-floor-map.tscn"
var first_floor_spawn_marker_name: String = "first_floor_spawn_marker"
var first_floor_save_station_marker: String = "first_floor_save_station_pos"

var second_floor_underground_map: String = "res://scenes/maps/second-floor-underground-map.tscn"
var second_floor_underground_spawn_marker_name: String = "second_floor_spawn_marker"
var second_floor_underground_save_station_marker: String = "second_floor_underground_save_station_pos"

var third_floor_underground_map: String = "res://scenes/maps/third-floor-underground-map.tscn"
var third_floor_underground_spawn_marker_name: String = "third_floor_spawn_marker"
var third_floor_underground_save_station_marker: String = "third_floor_underground_save_station_pos"

var current_map_path := first_floor_map
var spawn_marker_name := first_floor_spawn_marker_name
var current_save_station_marker := ""

# STATE FLAGS
var _is_game_started: bool = false
var is_game_started: bool:
	get: return _is_game_started
	set(value):
		_is_game_started = value
		is_game_start.emit(value)

		if value:
			start_timer()
		else:
			stop_timer()

var _difficulty := "Medium"
var difficulty: String:
	get: return _difficulty
	set(value):
		if _difficulty != value:
			_difficulty = value
			difficulty_changed.emit(_difficulty)

func _ready():
	var cursor_texture = preload("res://assets/img/my_cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(0, 0))

# Runs every frame to update the timer
func _process(delta):
	if is_timer_running:
		game_timer += delta

# Starts the timer
func start_timer():
	game_timer = 0.0
	is_timer_running = true
	print("⏱️ Timer started")

# Stops the timer
func stop_timer():
	is_timer_running = false
	print("🛑 Timer stopped at ", game_timer, " seconds")

# Get the elapsed time
func get_elapsed_time() -> float:
	return game_timer

# --- Map Logic ---
func update_map(new_map_path: String, new_spawn_marker: String):
	current_map_path = new_map_path
	spawn_marker_name = new_spawn_marker
	update_current_save_station_marker()

	print("🔄 Map state updated: ", current_map_path, " Spawn marker: ", spawn_marker_name)
	map_updated.emit(current_map_path, spawn_marker_name)

func update_current_save_station_marker():
	match current_map_path:
		first_floor_map:
			current_save_station_marker = first_floor_save_station_marker
		second_floor_underground_map:
			current_save_station_marker = second_floor_underground_save_station_marker
		third_floor_underground_map:
			current_save_station_marker = third_floor_underground_save_station_marker
		_:
			current_save_station_marker = first_floor_save_station_marker

	print("📍 Updated current_save_station_marker:", current_save_station_marker)

# --- Game Reset Logic ---
func reset_game():
	print("🔄 Game reset triggered")

	player_username = ""
	SaveSystem.reset_save()

	is_game_started = false
	current_map_path = first_floor_map
	spawn_marker_name = first_floor_spawn_marker_name
	update_current_save_station_marker()

	set_meta("current_save_file", null)

	call_deferred("emit_signal", "map_updated", current_map_path, spawn_marker_name)
	call_deferred("emit_signal", "game_reset")

# --- Save File Tracking ---
func set_save_file(file_name: String):
	set_meta("current_save_file", file_name)
	emit_signal("save_file_loaded", file_name) # ✅ emit signal

func get_save_file() -> String:
	if has_meta("current_save_file"):
		return get_meta("current_save_file")
	return ""
