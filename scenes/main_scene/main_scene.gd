extends Node2D

@onready var current_map = $current_map  # Must be an empty Node2D in the scene
@onready var player_container = $player_container  # Must exist in the scene

var current_map_path = "res://scenes/maps/start-map.tscn"
var spawn_marker_name = "start-map-spawn-point"  # Default spawn marker name

func _ready():
	load_player()
	load_map(current_map_path, spawn_marker_name)  # Load the initial map

func load_player():
	if player_container.get_child_count() == 0:
		var player_scene = load("res://scenes/player/player.tscn")  # Adjust path
		var player = player_scene.instantiate()
		player_container.add_child(player)

		# ✅ Add player to a group for easy access later
		player.add_to_group("player")
		print("✅ Player successfully loaded into player_container!")
	else:
		print("⚠️ Player already exists in player_container!")


func load_map(map_path, spawn_marker):
	print("Changing map to:", map_path)

	# Remove old map
	for child in current_map.get_children():
		child.queue_free()

	# Load and instantiate the new map
	var new_map = load(map_path)
	if new_map:
		var instance = new_map.instantiate()
		current_map.add_child(instance)
		current_map_path = map_path
		print("Map loaded successfully:", map_path)

		# Find the spawn marker in the new map
		var spawn_position = Vector2(100, 100)  # Default position in case marker is not found
		var spawn_marker_node = instance.get_node_or_null(spawn_marker)
		if spawn_marker_node:
			spawn_position = spawn_marker_node.global_position
			print("Spawn point found:", spawn_position)
		else:
			print("⚠️ WARNING: Spawn marker not found! Using default position.")

		# Move player to the new spawn position
		if player_container.get_child_count() > 0:
			var player = player_container.get_child(0)
			player_container.remove_child(player)  # Remove from old map
			instance.add_child(player)  # Add to new map
			player.global_position = spawn_position  # Set position inside the new map

			# ✅ Re-add the player to the group in case it got lost
			player.remove_from_group("player")  
			player.add_to_group("player")  

			print("✅ Player placed at:", player.global_position, "and re-added to 'player' group.")
		else:
			print("❌ ERROR: No player found in player_container!")
