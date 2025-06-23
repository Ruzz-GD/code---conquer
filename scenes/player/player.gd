extends CharacterBody2D

const SPEED = 100
const DASH_SPEED = 150
const DASH_TIME = 0.8

@onready var anim_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var bullet_scene = preload("res://scenes/player/PlayerBullet.tscn")
@onready var shoot_timer = $ShootTimer

var last_idle = "idle_down"
var is_dashing = false
var dash_velocity = Vector2.ZERO
var is_shooting = false
var can_move_game_started = true

signal player_health_changed(current)
signal player_lives_changed(current)
signal player_hints_changed(current)

var max_health := 100
var current_health := 100
var max_lives := 3
var current_lives := 3
var max_hints := 0
var current_hints := 0

@export var attack_range := 100
@export var attack_damage := 10
@export var attack_speed := 4 

func _ready():
	dash_timer.wait_time = DASH_TIME
	dash_timer.one_shot = true

	shoot_timer.wait_time = 1.0 / attack_speed
	shoot_timer.timeout.connect(_on_ShootTimer_timeout)

	GameManager.disable_player_action.connect(_on_typing_started)
	GameManager.enable_player_action.connect(_on_typing_finished)
	GameManager.game_reset.connect(_on_game_reset)

	emit_signal("player_health_changed", current_health)
	emit_signal("player_lives_changed", current_lives)
	emit_signal("player_hints_changed", current_hints)

	if not GameManager.is_game_started:
		reset_state(GameManager.reset_position())

func _physics_process(_delta):
	if not can_move_game_started or not GameManager.is_game_started:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Check shooting input
	if Input.is_action_pressed("to_shoot") and not get_viewport().gui_get_hovered_control():
		if shoot_timer.is_stopped():
			shoot_timer.start()
			is_shooting = true
	else:
		if not shoot_timer.is_stopped():
			shoot_timer.stop()
		is_shooting = false

	# Stop all movement if dashing or shooting
	if is_dashing or is_shooting:
		if is_dashing:
			velocity = dash_velocity
			move_and_slide()
			if dash_timer.time_left <= 0:
				_stop_dash()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
		return
	# Normal movement
	var direction = _get_movement_direction()
	if Input.is_action_just_pressed("dash_move") and direction != Vector2.ZERO and _is_valid_dash_direction(direction):
		_dash(direction)
	else:
		_handle_movement(direction)

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.attack_range = attack_range
	bullet.attack_damage = attack_damage
	get_tree().current_scene.add_child(bullet)

func _on_ShootTimer_timeout():
	shoot()

func _get_movement_direction() -> Vector2:
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

	return direction.normalized()

func _handle_movement(direction: Vector2):
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		anim_sprite.play(last_idle.replace("idle", "walk"))
	else:
		velocity = Vector2.ZERO
		anim_sprite.play(last_idle)
	move_and_slide()

func _dash(dash_direction):
	if is_shooting:
		return # Prevent dashing while shooting
	is_dashing = true
	dash_velocity = dash_direction.normalized() * DASH_SPEED
	anim_sprite.play(_get_dash_animation(dash_direction))
	dash_timer.start()

func _stop_dash():
	is_dashing = false
	dash_velocity = Vector2.ZERO

func _is_valid_dash_direction(direction: Vector2) -> bool:
	return direction == Vector2.UP or direction == Vector2.DOWN or direction == Vector2.LEFT or direction == Vector2.RIGHT

func _get_dash_animation(direction: Vector2) -> String:
	match direction:
		Vector2.LEFT: return "dash_left"
		Vector2.RIGHT: return "dash_right"
		Vector2.UP: return "dash_up"
		Vector2.DOWN: return "dash_down"
		_: return last_idle

func _on_typing_started():
	can_move_game_started = false

func _on_typing_finished():
	can_move_game_started = true

func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("player_health_changed", current_health)
	if current_health == 0:
		lose_life()

func lose_life() -> void:
	if current_lives > 0:
		current_lives -= 1
		current_health = max_health
		emit_signal("player_lives_changed", current_lives)
		emit_signal("player_health_changed", current_health)
	else:
		GameManager.reset_game()

func use_hint():
	if current_hints > 0:
		current_hints -= 1
		emit_signal("player_hints_changed", current_hints)

func _on_game_reset():
	current_health = max_health
	current_lives = max_lives
	current_hints = max_hints
	emit_signal("player_health_changed", current_health)
	emit_signal("player_lives_changed", current_lives)
	emit_signal("player_hints_changed", current_hints)
	reset_state(GameManager.reset_position())

func reset_state(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO
	dash_velocity = Vector2.ZERO
	is_dashing = false
	is_shooting = false
	if not GameManager.is_game_started:
		last_idle = "idle_down"
	anim_sprite.play(last_idle)
	if not dash_timer.is_stopped():
		dash_timer.stop()
