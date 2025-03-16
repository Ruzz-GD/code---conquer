extends Node2D

@onready var current_map = $current_map
@onready var player = $player

func _ready():
	load_map("res://assets/maps/map1.tscn", Vector2(100, 100))  # Example spawn position

func load_map(map_path, spawn_position):
	# Remove old map
	for child in current_map.get_children():
		child.queue_free()
	
	# Load new map
	var new_map = load(map_path).instantiate()
	current_map.add_child(new_map)

	# Move player to the correct spawn position
	player.position = spawn_position
