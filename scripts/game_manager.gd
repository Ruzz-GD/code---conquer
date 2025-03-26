extends Node2D

signal disable_player_action
signal enable_player_action

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
