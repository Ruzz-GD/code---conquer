extends Control

@onready var gametime = $Panel/gametime
@onready var deathcount = $Panel/deathcount
@onready var openeddoor = $Panel/openeddoor
@onready var openedchest = $Panel/openedchest
@onready var killeddrone = $Panel/killeddrone
@onready var killedrobot = $Panel/killedrobot

func _ready():
	hide() # Hide by default
	if GameManager.has_signal("game_finish_changed"):
		GameManager.game_finish_changed.connect(_on_game_finish_changed)

func _on_game_finish_changed(is_finished: bool):
	if is_finished:
		_load_stats()
		show()

func _load_stats():
	var total_seconds = int(GameManager.game_timer)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	gametime.text = "Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

	deathcount.text = "Deaths: " + str(GameManager.death_count)

	openeddoor.text = "Doors: " + str(GameManager.opened_doors_count)
	openedchest.text = "Chests: " + str(GameManager.opened_chests_count)
	killeddrone.text = "Drones: " + str(GameManager.killed_drones_count)
	killedrobot.text = "Robots: " + str(GameManager.killed_robots_count)
