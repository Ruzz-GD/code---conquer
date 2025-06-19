extends CharacterBody2D

const SPEED = 100
const DASH_SPEED = 150
const DASH_TIME = 0.8

@onready var anim_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer

var last_idle = "idle_down"
var is_dashing = false
var dash_velocity = Vector2.ZERO
var can_move_game_started = true

func _ready():
	dash_timer.wait_time = DASH_TIME
	dash_timer.one_shot = true

	GameManager.disable_player_action.connect(_on_typing_started)
	GameManager.enable_player_action.connect(_on_typing_finished)
	GameManager.game_reset.connect(_on_game_reset) # 👈 Listen to game reset

	# Optional: Reset state at first load
	if not GameManager.is_game_started:
		reset_state(GameManager.reset_position())

func _physics_process(_delta):
	if not can_move_game_started or not GameManager.is_game_started:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_dashing:
		velocity = dash_velocity
		move_and_slide()
		if dash_timer.time_left <= 0:
			_stop_dash()
		return

	var direction = _get_movement_direction()

	if Input.is_action_just_pressed("dash_move") and can_move_game_started:
		if direction != Vector2.ZERO and _is_valid_dash_direction(direction):
			_dash(direction)
			return

	_handle_movement(direction)

func _get_movement_direction() -> Vector2:
	if not can_move_game_started or not GameManager.is_game_started:
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

func _handle_movement(direction: Vector2):
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		anim_sprite.play(last_idle.replace("idle", "walk"))
	else:
		velocity = Vector2.ZERO
		anim_sprite.play(last_idle)

	move_and_slide()

func _dash(dash_direction):
	is_dashing = true
	dash_velocity = dash_direction.normalized() * DASH_SPEED
	anim_sprite.play(_get_dash_animation(dash_direction))
	dash_timer.start()

func _on_DashTimer_timeout():
	_stop_dash()

func _stop_dash():
	is_dashing = false
	dash_velocity = Vector2.ZERO

func _is_valid_dash_direction(direction: Vector2) -> bool:
	return direction == Vector2.UP or direction == Vector2.DOWN or direction == Vector2.LEFT or direction == Vector2.RIGHT

func _get_dash_animation(direction: Vector2) -> String:
	if direction == Vector2.LEFT:
		return "dash_left"
	elif direction == Vector2.RIGHT:
		return "dash_right"
	elif direction == Vector2.UP:
		return "dash_up"
	elif direction == Vector2.DOWN:
		return "dash_down"
	return last_idle

func _on_typing_started():
	can_move_game_started = false

func _on_typing_finished():
	can_move_game_started = true

# ✅ Called when GameManager triggers a reset
func _on_game_reset():
	print("🔁 Reset received in Player")
	reset_state(GameManager.reset_position())

# ✅ Reset state and teleport
func reset_state(pos: Vector2):
	print("🚀 Teleporting player to:", pos)
	global_position = pos
	velocity = Vector2.ZERO
	dash_velocity = Vector2.ZERO
	is_dashing = false

	# Reset facing if game hasn't started
	if not GameManager.is_game_started:
		last_idle = "idle_down"
		print("↩️ Reset facing direction to:", last_idle)

	anim_sprite.play(last_idle)

	if not dash_timer.is_stopped():
		dash_timer.stop()
