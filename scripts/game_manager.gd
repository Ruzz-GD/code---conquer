extends Node2D

signal disable_player_action
signal enable_player_action
signal map_updated(new_map_path, new_spawn_marker)  # 🔄 New signal

var current_map_path: String = "res://scenes/maps/start-map.tscn"
var spawn_marker_name: String = "start-map-spawn-point"

@onready var start_map_main_door_debug_ui = null
@onready var start_map_start_room = null

func _ready():
	# Get the current active main scene
	start_map_main_door_debug_ui = get_tree().current_scene.find_child("DebugUI-main-door-start-map", true)
	start_map_start_room = get_tree().current_scene.find_child("DebugUI-start-map-start-room")

	# Debug check
	if start_map_main_door_debug_ui:
		print("✅ Found Debug UI:", start_map_main_door_debug_ui.name)
	else:
		print("❌ Debug UI not found! Check your scene structure.")

	# Dummy emission to avoid "unused signal" warnings
	disable_player_action.emit()
	enable_player_action.emit()

func update_map(new_map_path: String, new_spawn_marker: String):
	current_map_path = new_map_path
	spawn_marker_name = new_spawn_marker

	print("🔄 Map state updated: ", current_map_path, " Spawn marker: ", spawn_marker_name)
	map_updated.emit(current_map_path, spawn_marker_name)  # Emit signal
