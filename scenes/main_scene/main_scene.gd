extends Node2D

@onready var current_map = $current_map
@onready var player_container = $player_container

func _ready():
	GameManager.map_updated.connect(load_map)

	load_player()
	load_map(GameManager.current_map_path, GameManager.spawn_marker_name)

func load_player():
	if player_container.get_child_count() == 0:
		var player_scene = load("res://scenes/player/player.tscn")
		var player = player_scene.instantiate()
		player.name = "Player"
		player_container.add_child(player)
		print("✅ Player successfully loaded into player_container!")
	else:
		print("⚠️ Player already exists in player_container!")

func load_map(map_path: String, spawn_marker: String):
	print("🔄 Changing map to:", map_path)

	for child in current_map.get_children():
		child.queue_free()

	var new_map = load(map_path).instantiate()
	current_map.add_child(new_map)
	print("✅ Map loaded successfully:", map_path)

	await get_tree().process_frame

	var marker = new_map.get_node_or_null(spawn_marker)
	if marker:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = marker.global_position
			print("📍 Player spawned at:", marker.name)
	else:
		print("❌ Spawn marker not found:", spawn_marker)
