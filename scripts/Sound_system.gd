extends Node

signal background_volume_changed(new_volume: float)
signal player_volume_changed(new_volume: float)
signal mob_volume_changed(new_volume: float)

var background_volume := 1.0
var player_volume := 1.0
var mob_volume := 1.0

func set_background_volume(value: float):
	background_volume = clamp(value, 0.0, 1.0)
	emit_signal("background_volume_changed", background_volume)

func set_player_volume(value: float):
	player_volume = clamp(value, 0.0, 1.0)
	emit_signal("player_volume_changed", player_volume)

func set_mob_volume(value: float):
	mob_volume = clamp(value, 0.0, 1.0)
	emit_signal("mob_volume_changed", mob_volume)
