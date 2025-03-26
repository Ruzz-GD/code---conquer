extends StaticBody2D

@export var closed_texture: Texture
@export var open_texture: Texture
@export var locked_icon: Texture  # Small red button
@export var unlocked_icon: Texture  # Small green button

var is_open = false
var can_open = false  # ✅ Tracks if the door is unlocked
var debug_ui_main_door = null  # ✅ Store Debug UI reference

@onready var close_door_collision = $"closed-door-collision"
@onready var button_click_area = $"button-click-area"
@onready var indicator = $"button-click-area/Sprite2D"  # Lock/unlock indicator
@onready var door_detector = $"door-detector"  # ✅ Area2D that detects the player

func _ready():
	update_door_texture()
	button_click_area.input_event.connect(_on_area_clicked)
	indicator.texture = locked_icon  # Default to red (locked)

	# ✅ Get Debug UI from GameManager
	debug_ui_main_door = GameManager.start_map_main_door_debug_ui

	# ✅ If found, connect signals
	if debug_ui_main_door:
		debug_ui_main_door.hide()  # Hide at start
		debug_ui_main_door.challenge_solved.connect(solve_challenge)
	else:
		print("❌ Debug UI not found in GameManager!")

func _on_area_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("📌 Area2D clicked! Showing Debug UI")
		if debug_ui_main_door:
			GameManager.disable_player_action.emit()  # ✅ Disable player movement
			debug_ui_main_door.show()  # ✅ Show Debug UI
		else:
			print("❌ Debug UI is NULL! Cannot show.")

func solve_challenge():
	print("✅ Debugging success! Door is now permanently unlocked!")
	can_open = true  # ✅ Unlock the door
	indicator.texture = unlocked_icon  # Change to green (unlocked)

	# ✅ Hide Debug UI & Re-enable player movement
	if debug_ui_main_door:
		debug_ui_main_door.hide()
		GameManager.enable_player_action.emit()  # ✅ Re-enable movement

	# ✅ Check if the player is inside the door detector and open the door immediately
	var player_inside = false
	for body in door_detector.get_overlapping_bodies():
		print("🔍 Found body inside detector:", body.name)
		if body.is_in_group("player"):  # Use group instead of checking name
			print("✅ Player detected inside! Opening door immediately.")
			_on_doordetector_body_entered(body)
			player_inside = true
	
	if not player_inside:
		print("❌ No player detected inside door detector.")

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
	close_door_collision.set_deferred("disabled", is_open)  # ✅ Disable collision when open
	print("🎨 Door texture updated:", "Open" if is_open else "Closed")
