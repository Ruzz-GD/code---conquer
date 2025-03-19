extends Node2D

@onready var current_map = $current_map
@onready var player_container = $player_container

func _ready():
	load_player()
	GameManager.load_map(GameManager.current_map, GameManager.spawn_position)  # Load last saved map

func load_player():
	if player_container.get_child_count() == 0:
		var player_scene = load("res://scenes/player/player.tscn")  # Adjust path
		var player = player_scene.instantiate()
		player_container.add_child(player)
		player.position = GameManager.spawn_position  # Spawn player at saved position

func load_map(map_path, spawn_position):
	for child in current_map.get_children():
		child.queue_free()  # Remove old map

	var new_map = load(map_path).instantiate()
	current_map.add_child(new_map)

	var player = player_container.get_child(0)  # Get player from container
	if player:
		player.position = spawn_position  # Move player to new spawn position
