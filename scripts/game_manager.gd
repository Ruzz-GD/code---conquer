extends Node

var current_map = "res://scenes/maps/start-map.tscn"
var spawn_position = Vector2(100, 100)

func change_map(map_path, spawn_pos):
	current_map = map_path
	spawn_position = spawn_pos
	load_map(map_path, spawn_pos)

func load_map(map_path, spawn_pos):
	var main_scene = get_tree().get_first_node_in_group("game")  # Find main scene
	if main_scene:
		main_scene.load_map(map_path, spawn_pos)  # Tell main_scene to load new map
