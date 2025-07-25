extends StaticBody2D

var door_id: String = "first_floor_second_door"

@export var closed_texture: Texture
@export var open_texture: Texture
@export var lock_button_icon: Texture
@export var unlock_button_icon: Texture

@onready var door_sprite = $Sprite2D
@onready var door_collision = $"close-door-collision"
@onready var door_button = $"start-room-button"
@onready var button_icon = $"start-room-button/Sprite2D"
@onready var door_detector = $"door-detector"

var door_already_open: bool = false
var is_open: bool = false
var can_open: bool = false
var player_near_door: bool = false
var debug_ui: Node = null
var player: Node = null

var has_set_challenge = false
var challenge_difficulty = ""
var selected_challenge = {}

func _ready():
	update_door_texture()
	button_icon.texture = lock_button_icon

	debug_ui = get_tree().current_scene.find_child("DebugUI-first-floor-all-doors", true, false)
	player = get_tree().current_scene.find_child("Player", true, false)

	if SaveSystem.loaded:
		_check_if_door_should_be_open()
	else:
		SaveSystem.save_loaded.connect(_check_if_door_should_be_open)

	if debug_ui:
		debug_ui.hide()
	else:
		print("❌ Debug UI not found in scene!")

	door_button.input_event.connect(_on_door_button_input)

func _check_if_door_should_be_open():
	if SaveSystem.is_door_open(door_id):
		door_already_open = true
		setup_unlocked_door()

func _on_door_button_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not player_near_door or can_open:
		print("❌ Button inactive (already solved or player too far).")
		return

	if event is InputEventMouseButton and event.pressed:
		if debug_ui:
			if debug_ui.visible:
				print("⚠️ Debug UI already open.")
				return

			# 🟢 Assign random challenge only once
			if not has_set_challenge:
				debug_ui.set_random_challenge(GameManager.difficulty)
				selected_challenge = debug_ui.selected_challenge
				has_set_challenge = true
				challenge_difficulty = GameManager.difficulty

			# ✅ Pass self and selected_challenge to shared debug UI
			debug_ui.show_debug_ui(self, selected_challenge)
			_disable_player_input(true)
		else:
			print("❌ Could not show debug UI")

func solve_challenge():
	print("✅ Debugging complete! Door can now open.")
	SaveSystem.opened_doors[door_id] = true 
	can_open = true
	button_icon.texture = unlock_button_icon
	door_button.input_pickable = false

	if debug_ui:
		debug_ui.hide()

	_disable_player_input(false)
	check_player_in_area()

func check_player_in_area():
	for body in door_detector.get_overlapping_bodies():
		if body.is_in_group("player"):
			if not is_open:
				print("🚪 Player already inside. Opening door.")
				open_door()
			return
	print("❌ No player inside door detector.")

func _on_doordetector_body_entered(body):
	if body.is_in_group("player"):
		player_near_door = true
		if can_open and not is_open:
			print("🚪 Player entered! Opening door.")
			open_door()

func _on_doordetector_body_exited(body):
	if body.is_in_group("player"):
		player_near_door = false
		if can_open and is_open:
			print("🚪 Player exited! Closing door.")
			close_door()

func open_door():
	is_open = true
	update_door_texture()

func close_door():
	is_open = false
	update_door_texture()

func update_door_texture():
	door_sprite.texture = open_texture if is_open else closed_texture
	door_collision.set_deferred("disabled", is_open)
	print("🎨 Door state updated:", "Open" if is_open else "Closed")

func _disable_player_input(state: bool):
	if player:
		player.typing_cant_move = state
		print("🔧 Player typing_cant_move set to:", state)

func setup_unlocked_door():
	can_open = true
	update_door_texture()
	door_button.input_pickable = false
	button_icon.texture = unlock_button_icon
