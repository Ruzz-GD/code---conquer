extends CharacterBody2D

@export var speed := 60  
@export var chase_speed := 100  
@export var drone_range := 70  
@export var drone_damage := 10
@export var attack_speed := 3.0  # Shots per second
@export var min_safe_distance := 30  # distance to maintain from player

@onready var attack_timer = $attack_timer
@onready var bullet_scene = preload("res://scenes/mobs/DroneBullet.tscn")
@onready var chase_area = $"../ChaseArea"
@onready var patrol_area = $"../PatrolArea"
@onready var area_to_detect = $AreaToDetect
@onready var drone_hp = $"drone-hp"

var start_position: Vector2  
var target_position: Vector2  
var player: Node2D = null  
var chasing: bool = false  
var patrol_timer: float = 0.0  
var drone_max_hp := 100
var drone_current_hp := 100

# Relocating state
var relocating: bool = false
var relocation_target: Vector2 = Vector2.ZERO

# 🛑 Anti-stuck variables
var stuck_timer := 0.0
var last_position := Vector2.ZERO
var stuck_check_interval := 1.0

func _ready():
	drone_hp.visible = false
	start_position = global_position  
	pick_new_target()  
	drone_hp.max_value = drone_max_hp
	drone_hp.value = drone_current_hp

	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.timeout.connect(drone_shooting)

	area_to_detect.body_entered.connect(_on_area_to_detect_entered)
	area_to_detect.body_exited.connect(_on_area_to_detect_exited)
	chase_area.body_exited.connect(_on_chase_area_exited)

func _process(delta):
	check_if_stuck(delta)

	if chasing and player:
		if relocating:
			move_to_relocation(delta)
		else:
			handle_combat_positioning()
	else:
		patrol(delta)

func patrol(delta):
	if patrol_timer > 0:
		patrol_timer -= delta
		return

	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(target_position) < 5:
		patrol_timer = randf_range(0.5, 1.5)
		pick_new_target()

func handle_combat_positioning():
	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player > drone_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * chase_speed
		move_and_slide()
		attack_timer.stop()
	elif distance_to_player < min_safe_distance:
		start_relocation()
	else:
		stop_movement()
		if attack_timer.is_stopped():
			attack_timer.start()

func start_relocation():
	var attempts = 10
	while attempts > 0:
		var angle = randf() * TAU
		var patrol_radius = 100
		if patrol_area and patrol_area.get_node_or_null("CollisionShape2D"):
			var shape = patrol_area.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				patrol_radius = shape.radius

		var new_pos = start_position + Vector2(cos(angle), sin(angle)) * patrol_radius
		if new_pos.distance_to(player.global_position) > min_safe_distance:
			relocation_target = new_pos
			relocating = true
			print("🚶‍♂️ Drone started relocating")
			break
		attempts -= 1

func move_to_relocation(delta):
	var direction = (relocation_target - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(relocation_target) < 5:
		stop_movement()
		relocating = false
		print("✅ Drone finished relocating")

		if player and chasing:
			handle_combat_positioning()

func stop_movement():
	velocity = Vector2.ZERO
	move_and_slide()

func pick_new_target():
	var angle = randf() * TAU
	var patrol_radius = 100

	if patrol_area and patrol_area.get_node_or_null("CollisionShape2D"):
		var shape = patrol_area.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			patrol_radius = shape.radius

	target_position = start_position + Vector2(cos(angle), sin(angle)) * patrol_radius
	print("📍 New patrol target:", target_position)

# 🆘 Anti-stuck check
func check_if_stuck(delta):
	stuck_timer += delta
	if stuck_timer >= stuck_check_interval:
		var moved_distance = global_position.distance_to(last_position)
		if moved_distance < 2:
			print("⚠️ Drone is stuck! Picking new target")
			if chasing:
				start_relocation()
			else:
				pick_new_target()
			patrol_timer = 0.0
		last_position = global_position
		stuck_timer = 0.0

func _on_area_to_detect_entered(body):
	if body.is_in_group("player"):
		print("👁️ Drone sees the player!")
		chasing = true
		player = body

func _on_area_to_detect_exited(body):
	if body == player:
		print("👋 Player left detection area!")
		chasing = false
		player = null
		relocating = false
		attack_timer.stop()
		patrol_timer = 1.5
		pick_new_target()

func _on_chase_area_exited(body):
	if body == player:
		print("🚧 Player out of chase area.")
		chasing = false
		player = null
		relocating = false
		attack_timer.stop()
		stop_movement()
		patrol_timer = 1.5
		pick_new_target()

func drone_shooting():
	if player and global_position.distance_to(player.global_position) <= drone_range:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (player.global_position - global_position).normalized()
		bullet.attack_range = drone_range
		bullet.attack_damage = drone_damage
		get_tree().current_scene.add_child(bullet)
		print("💥 Drone fired a bullet!")

func take_damage(amount: int) -> void:
	drone_current_hp = clamp(drone_current_hp - amount, 0, drone_max_hp)
	drone_hp.value = drone_current_hp
	drone_hp.visible = true
	print("💢 Drone took", amount, "damage! HP:", drone_current_hp)
	
	if drone_current_hp <= 0:
		die()

func die():
	print("☠️ Drone destroyed!")
	queue_free()
