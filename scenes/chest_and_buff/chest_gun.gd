extends Area2D

var player_near = false
var debug_ui_first_floor_all_chest: Node = null
var chest_already_opened = false

var has_set_challenge = false
var challenge_difficulty = ""

@onready var gun = $Gun
var selected_challenge = {}
var chest_id: String = "chest_gun"
func _ready():
	if SaveSystem.loaded:
		_check_if_chest_should_be_open()
	else:
		SaveSystem.save_loaded.connect(_check_if_chest_should_be_open)

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	debug_ui_first_floor_all_chest = get_tree().current_scene.find_child("DebugUI-first-floor-all-chest", true, false)

	# 🔒 Fully hide gun and disable collision
	gun.visible = false
	gun.monitoring = false
	gun.set_deferred("monitorable", false)

	gun.visible = false
	gun.monitoring = false
	gun.set_deferred("monitorable", true)
	
	if chest_already_opened:
		$chest_sprite.frame = $chest_sprite.sprite_frames.get_frame_count("chest_anim") - 1

func _check_if_chest_should_be_open():
	if SaveSystem.is_chest_opened(chest_id):
		chest_already_opened = true
		$chest_sprite.frame = $chest_sprite.sprite_frames.get_frame_count("chest_anim") - 1

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false

func _on_button_pressed():
	if player_near and not chest_already_opened:
		start_debug_challenge()

func start_debug_challenge():
	if debug_ui_first_floor_all_chest:
		if not has_set_challenge:
			debug_ui_first_floor_all_chest.set_random_challenge(GameManager.difficulty)
			selected_challenge = debug_ui_first_floor_all_chest.selected_challenge  # Store copy
			has_set_challenge = true
			challenge_difficulty = GameManager.difficulty

		debug_ui_first_floor_all_chest.show_debug_ui(self, selected_challenge) 
		
func _on_challenge_solved():
	if not chest_already_opened:
		open_chest()

func open_chest():
	print("✅ Chest opened!")
	chest_already_opened = true
	SaveSystem.opened_chests[chest_id] = true

	$chest_sprite.play("chest_anim")

	await $chest_sprite.animation_finished
	$chest_sprite.stop()
	$chest_sprite.frame = $chest_sprite.sprite_frames.get_frame_count("chest_anim") - 1

	# 🎉 Now show and enable gun after animation
	gun.visible = true
	gun.monitoring = true
	gun.set_deferred("monitorable", true)
