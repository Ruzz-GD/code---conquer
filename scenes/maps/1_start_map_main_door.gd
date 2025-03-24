extends StaticBody2D

@export var closed_texture: Texture
@export var open_texture: Texture
@export var locked_icon: Texture  # Small red button
@export var unlocked_icon: Texture  # Small green button

var is_open = false
var can_open = false  

@onready var close_door_collision = $"closed-door-collision"
@onready var area = $Area2D
@onready var indicator = $Area2D/Sprite2D  # Small red/green indicator
@onready var debug_ui_main_door = $"DebugUI-main-door"  # ✅ Reference the Debug UI

func _ready():
	update_door_texture()
	area.input_event.connect(_on_area_clicked)
	indicator.texture = locked_icon  # Default to red (locked)
	indicator.scale = Vector2(1,1)  # Adjust size if needed
	debug_ui_main_door.hide()  # ✅ Hide Debug UI at start
	debug_ui_main_door.challenge_solved.connect(solve_challenge)  # ✅ Connect challenge solved signal

func _on_area_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("📌 Area2D clicked! Showing Debug UI")
		debug_ui_main_door.show()  # ✅ Show Debug UI when button is clicked

func solve_challenge():
	print("✅ Debugging success!")
	can_open = true
	indicator.texture = unlocked_icon  # Change to green (unlocked)
	toggle_door()
	debug_ui_main_door.hide()  # ✅ Hide UI after solving

func toggle_door():
	if can_open:
		is_open = true
		update_door_texture()
		print("🚪 Door is now Open!")

func update_door_texture():
	$Sprite2D.texture = open_texture if is_open else closed_texture
	close_door_collision.set_deferred("disabled", is_open)  # Disable collision when open
