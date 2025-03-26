extends CharacterBody2D  

@export var speed: float = 60  
@export var chase_speed: float = 100  
@export var stop_distance: float = 50  # Distance to stop chasing

var start_position: Vector2  
var target_position: Vector2  
var player: Node2D = null  
var chasing: bool = false  
var patrol_timer: float = 0.0  

var chase_area: Area2D = null
var patrol_area: Area2D = null

func _ready():
	start_position = global_position  
	pick_new_target()  

	# Access the parent (DroneMob) and find ChaseArea and PatrolArea
	var parent = get_parent()
	if parent:
		chase_area = parent.get_node_or_null("ChaseArea")
		patrol_area = parent.get_node_or_null("PatrolArea")
	else:
		print("⚠️ ERROR: Parent (DroneMob) not found!")

	# Ensure signals are connected
	if patrol_area and patrol_area is Area2D:
		patrol_area.body_entered.connect(_on_patrol_area_entered)
	else:
		print("⚠️ ERROR: PatrolArea is missing or not an Area2D!")

	if chase_area and chase_area is Area2D:
		chase_area.body_exited.connect(_on_chase_area_exited)
	else:
		print("⚠️ ERROR: ChaseArea is missing or not an Area2D!")

func _process(delta):
	if chasing and player:  
		chase_player(delta)  
	else:
		patrol(delta)  

func patrol(delta):
	if chasing:
		return  

	if patrol_timer > 0:
		patrol_timer -= delta  
		return  

	var direction = (target_position - global_position).normalized()
	velocity = direction * speed  
	move_and_slide()

	if global_position.distance_to(target_position) < 5:
		patrol_timer = randf_range(0.5, 1.5)  
		pick_new_target()

func chase_player(_delta):
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * chase_speed  
			move_and_slide()
			print("🚨 Chasing Player:", player.name)
		else:
			stop_movement()

func stop_movement():
	velocity = Vector2.ZERO
	move_and_slide()
	print("🛑 Stopped chasing.")

func pick_new_target():
	var angle = randf() * TAU  
	var patrol_radius = 100  

	if patrol_area and patrol_area.get_node_or_null("CollisionShape2D"):
		patrol_radius = patrol_area.get_node("CollisionShape2D").shape.radius  

	target_position = start_position + Vector2(cos(angle), sin(angle)) * patrol_radius
	print("🎯 New Patrol Target:", target_position)

# 🟢 Player enters PatrolArea → Start chasing
func _on_patrol_area_entered(body):
	if body.is_in_group("player"):  
		print("✅ Player detected in PatrolArea! Start chase.")
		chasing = true
		player = body

# 🔴 Player exits ChaseArea → Stop chasing
func _on_chase_area_exited(body):
	if body == player:
		print("❌ Player left ChaseArea! Stop chase.")
		chasing = false
		player = null  
		stop_movement()
		patrol_timer = 1.5  
		pick_new_target()
