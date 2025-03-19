extends Area2D

@export var target_map: String = "res://scenes/maps/ug-2nd-floor.tscn"
@export var spawn_position: Vector2 = Vector2(100, 100)

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.change_map(target_map, spawn_position)
