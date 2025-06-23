extends Node2D


signal disable_player_action
signal enable_player_action
signal map_updated(new_map_path, new_spawn_marker)  # 🔄 New signal
signal game_reset

var current_map_path: String = "res://scenes/maps/start-map.tscn"
var spawn_marker_name: String = "start-map-spawn-point"
var is_game_started: bool = false  # ✅ Track if the game has officially started
var difficulty: String = "Medium"
@onready var start_map_main_door_debug_ui = null
@onready var start_map_start_room = null

func _ready():
	var cursor_texture = preload("res://assets/img/my_cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture ,Input.CURSOR_ARROW ,Vector2(0,0))

	# Get the current active main scene
	start_map_main_door_debug_ui = get_tree().current_scene.find_child("DebugUI-main-door-start-map", true)
	start_map_start_room = get_tree().current_scene.find_child("DebugUI-start-map-start-room")
	
	# Dummy emission to avoid "unused signal" warnings
	disable_player_action.emit()
	enable_player_action.emit()

func update_map(new_map_path: String, new_spawn_marker: String):
	current_map_path = new_map_path
	spawn_marker_name = new_spawn_marker

	print("🔄 Map state updated: ", current_map_path, " Spawn marker: ", spawn_marker_name)
	map_updated.emit(current_map_path, spawn_marker_name)

func reset_position() -> Vector2:
	var map_scene = load(current_map_path).instantiate()
	var marker = map_scene.get_node_or_null(spawn_marker_name)
	return marker.global_position if marker else Vector2(100, 100)
	
func reset_game():
	print("🔄 Game reset triggered")
	is_game_started = false
	current_map_path = "res://scenes/maps/start-map.tscn"
	spawn_marker_name = "start-map-spawn-point"
	
	call_deferred("emit_signal", "map_updated", current_map_path, spawn_marker_name)
	call_deferred("emit_signal", "game_reset")
