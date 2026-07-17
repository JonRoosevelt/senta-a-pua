extends Area3D

@export var speed: float = 150.0
@export var magnetism_radius: float = 8.0     # Capture radius around bullet
@export var magnetism_strength: float = 0.25  # Steering force per frame (0-1)

var direction: Vector3 = Vector3.ZERO
var homing_target: Node3D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# Find nearest enemy within capture radius to gently curve toward
	var best_dist = magnetism_radius
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			homing_target = enemy

	await get_tree().create_timer(3.0).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if homing_target and is_instance_valid(homing_target):
		var to_target = (homing_target.global_position - global_position).normalized()
		direction = direction.slerp(to_target, magnetism_strength).normalized()
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name == "Player":
		return

	if body.has_method("take_damage"):
		body.take_damage(10)

	queue_free()
