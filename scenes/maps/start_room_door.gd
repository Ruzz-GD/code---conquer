extends StaticBody2D

@export var closed_texture: Texture
@export var open_texture: Texture
@export var lock_button_icon : Texture
@export var unlock_button_icon : Texture

@onready var close_door_collision = $"close-door-collision"
@onready var indicator = $"start-room-button/Sprite2D"
@onready var door_detector = $"door-detector"

var is_open = false
var can_open = false  # ✅ Tracks if the door is unlocked
var debug_ui_start_room = null  # ✅ Store Debug UI reference

func _ready():
	update_door_texture()
	indicator.texture = lock_button_icon
	debug_ui_start_room = GameManager.start_map_start_room
	
	if debug_ui_start_room:
		debug_ui_start_room.hide()
		debug_ui_start_room.challenge_solved.connect(solve_challenge)
	else:
		print("❌ Debug UI not found in GameManager!")
		
func solve_challenge():
	can_open = true
	indicator.texture = unlock_button_icon
	
	if debug_ui_start_room:
		debug_ui_start_room.hide()
		GameManager.enable_player_action.emit()

func _on_startroombutton_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if debug_ui_start_room:
			GameManager.disable_player_action
			debug_ui_start_room.show()
		else:
			print("error")

func _on_doordetector_body_entered(body):
	if can_open and body.is_in_group("player"):  # ✅ Only open if unlocked
		if not is_open:  # Avoid unnecessary updates
			print("🚪 Player entered! Opening door.")
			is_open = true
			update_door_texture()
			
func _on_doordetector_body_exited(body):
	if can_open and body.is_in_group("player"):  # ✅ Close when player leaves
		if is_open:  # Avoid unnecessary updates
			print("🚪 Player exited! Closing door.")
			is_open = false
			update_door_texture()
			
func update_door_texture():
	$Sprite2D.texture = open_texture if is_open else closed_texture
	close_door_collision.set_deferred("disabled",is_open)
	
