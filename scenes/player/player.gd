extends CharacterBody2D

const SPEED = 100  # Normal speed
const DASH_SPEED = 150  # Dash speed
const DASH_TIME = 0.8  # Dash duration in seconds

@onready var anim_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer  # Reference to the timer node

var last_idle = "idle_down"  # Last idle animation
var is_dashing = false  # Dash state
var dash_velocity = Vector2.ZERO  # Dash movement direction
var can_move = true  # ✅ New flag to control movement

func _ready():
	dash_timer.wait_time = DASH_TIME
	dash_timer.one_shot = true  # Ensure it doesn't loop

	# ✅ Connect to GameManager signals to enable/disable movement
	GameManager.disable_player_action.connect(_on_typing_started)
	GameManager.enable_player_action.connect(_on_typing_finished)

func _physics_process(_delta):
	if not can_move:
		velocity = Vector2.ZERO  # ✅ Stop movement if typing
		move_and_slide()
		return

	if is_dashing:
		velocity = dash_velocity  # Keep applying dash velocity
		move_and_slide()

		# If dash timer expires, stop the dash
		if dash_timer.time_left <= 0:
			_stop_dash()
		return  # Prevent normal movement during dash

	var direction = _get_movement_direction()  # Get movement direction

	# Dash logic (Only W, A, S, D are allowed)
	if Input.is_action_just_pressed("dash_move") and can_move:  # ✅ Only allow dash if movement is enabled
		print("🟢 Dash Key Pressed!")
		if direction != Vector2.ZERO and _is_valid_dash_direction(direction):
			print("🔹 Dash Attempted! Move Direction:", direction)
			_dash(direction)
			return  # Stop normal movement when dashing
		else:
			print("🔴 Dash Pressed, but No Valid Direction!")

	# Handle movement
	_handle_movement(direction)

# Get movement direction
func _get_movement_direction() -> Vector2:
	if not can_move:  # ✅ Prevent movement when typing
		return Vector2.ZERO

	var direction = Vector2.ZERO

	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		direction = Vector2(1, -1)
		last_idle = "idle_right_up"
	elif Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		direction = Vector2(-1, -1)
		last_idle = "idle_left_up"
	elif Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		direction = Vector2(1, 1)
		last_idle = "idle_right_down"
	elif Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		direction = Vector2(-1, 1)
		last_idle = "idle_left_down"
	elif Input.is_action_pressed("move_up"):
		direction.y -= 1
		last_idle = "idle_up"
	elif Input.is_action_pressed("move_down"):
		direction.y += 1
		last_idle = "idle_down"
	elif Input.is_action_pressed("move_left"):
		direction.x -= 1
		last_idle = "idle_left"
	elif Input.is_action_pressed("move_right"):
		direction.x += 1
		last_idle = "idle_right"

	return direction.normalized() if direction != Vector2.ZERO else Vector2.ZERO

# Handles movement animations and physics
func _handle_movement(direction: Vector2):
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		anim_sprite.play(last_idle.replace("idle", "walk"))
	else:
		velocity = Vector2.ZERO
		anim_sprite.play(last_idle)
	
	move_and_slide()

# Dash function
func _dash(dash_direction):
	print("💨 Dash Called! Direction:", dash_direction)
	is_dashing = true  
	dash_velocity = dash_direction.normalized() * DASH_SPEED  
	var dash_anim = _get_dash_animation(dash_direction)

	# Debugging dash values
	print("Dash Velocity:", dash_velocity)
	print("Dash Animation:", dash_anim)

	anim_sprite.play(dash_anim)  
	dash_timer.start()

# Called when the dash timer ends
func _on_DashTimer_timeout():
	_stop_dash()

func _stop_dash():
	is_dashing = false  
	dash_velocity = Vector2.ZERO  

# Only allow dash for pure W, A, S, D (no diagonal dashes)
func _is_valid_dash_direction(direction: Vector2) -> bool:
	return direction == Vector2.UP or direction == Vector2.DOWN or direction == Vector2.LEFT or direction == Vector2.RIGHT

# Get correct dash animation for allowed directions
func _get_dash_animation(direction: Vector2) -> String:
	print("📽 Getting Dash Animation for:", direction)

	if direction == Vector2.LEFT:
		return "dash_left"
	elif direction == Vector2.RIGHT:
		return "dash_right"
	elif direction == Vector2.UP:
		return "dash_up"
	elif direction == Vector2.DOWN:
		return "dash_down"
	
	return last_idle

# ✅ Stop movement when player starts debugging
func _on_typing_started():
	print("🛑 Typing started! Disabling movement.")
	can_move = false

# ✅ Resume movement when debugging is finished
func _on_typing_finished():
	print("✅ Typing finished! Enabling movement.")
	can_move = true
