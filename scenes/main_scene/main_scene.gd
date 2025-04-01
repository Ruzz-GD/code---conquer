extends Node2D

@onready var current_map = $current_map  # Empty Node2D where the map is loaded
@onready var player_container = $player_container  # Where the player is stored

func _ready():
	# Connect to GameManager's signal so it automatically updates the map
	GameManager.map_updated.connect(load_map)

	# Load the initial map from GameManager
	load_player()
	load_map(GameManager.current_map_path, GameManager.spawn_marker_name)

func load_player():
	if player_container.get_child_count() == 0:
		var player_scene = load("res://scenes/player/player.tscn")  # Adjust path
		var player = player_scene.instantiate()
		player_container.add_child(player)
		player.add_to_group("player")
		print("✅ Player successfully loaded into player_container!")
	else:
		print("⚠️ Player already exists in player_container!")

func load_map(map_path, spawn_marker):
	print("🔄 Changing map to:", map_path)

	# Remove old map
	for child in current_map.get_children():
		child.queue_free()

	# Load and instantiate the new map
	var new_map = load(map_path).instantiate()
	current_map.add_child(new_map)
	print("✅ Map loaded successfully:", map_path)

	# Find spawn point in the new map
	var spawn_position = Vector2(100, 100)  # Default position
	var spawn_marker_node = new_map.get_node_or_null(spawn_marker)
	if spawn_marker_node:
		spawn_position = spawn_marker_node.global_position
		print("📌 Spawn point found:", spawn_position)
	else:
		print("⚠️ WARNING: Spawn marker not found! Using default position.")

	# Move player to the new spawn position
	if player_container.get_child_count() > 0:
		var player = player_container.get_child(0)
		player_container.remove_child(player)  # Remove from old map
		new_map.add_child(player)  # Add to new map
		player.global_position = spawn_position  # Set new position

		# ✅ Ensure player is still in the correct group
		player.remove_from_group("player")
		player.add_to_group("player")

		print("✅ Player placed at:", player.global_position, "and re-added to 'player' group.")
	else:
		print("❌ ERROR: No player found in player_container!")
