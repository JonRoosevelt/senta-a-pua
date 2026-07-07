extends CharacterBody3D

@export var forward_speed: float = 40.0
@export var roll_speed: float = 2.5
@export var pitch_speed: float = 2.0
@export var max_health: float = 100.0
@export var invert_pitch: bool = true
@export var convergence_distance: float = 150.0
@export var fire_rate: float = 0.08
@export var min_speed: float = 20.0
@export var max_speed: float = 65.0
@export var acceleration_rate: float = 18.0

@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var camera: Camera3D = $Camera3D

# Wing tip markers for bullet spawn
var wing_span: float = 4.0   # will be ~12m after 3x scale
var wing_offset_z: float = 0.0  # wing root position

var health: float = 100.0
var is_dead: bool = false
var fire_cooldown: float = 0.0
var shake_amount: float = 0.0
var shake_decay: float = 5.0
var camera_base_transform: Transform3D

func _ready() -> void:
	health = max_health
	if camera:
		camera_base_transform = camera.transform
	
	# Fix Meshy model orientation (it comes rotated 90° on Z axis, face pointing up instead of forward)
	# And scale up (Meshy models are typically small)
	var model = $P47Model
	if model:
		model.rotation_degrees = Vector3(0, -90, 0)  # face forward (-Z)
		model.scale = Vector3(8, 8, 8)  # Scale up to proper aircraft size

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Throttle
	if Input.is_key_pressed(KEY_W):
		forward_speed = min(forward_speed + acceleration_rate * delta, max_speed)
	if Input.is_key_pressed(KEY_S):
		forward_speed = max(forward_speed - acceleration_rate * delta, min_speed)
	
	# Rotation
	var roll_input = Input.get_axis("ui_left", "ui_right")
	var pitch_input = Input.get_axis("ui_up", "ui_down") if invert_pitch else Input.get_axis("ui_down", "ui_up")
	
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)
	rotate_object_local(Vector3.RIGHT, pitch_input * pitch_speed * delta)
	
	# Flight physics
	var forward_direction = -global_transform.basis.z
	var engine_velocity = forward_direction * forward_speed
	var gravity_vector = Vector3(0, -9.8, 0)
	var speed_ratio = forward_speed / 40.0
	var lift_vector = global_transform.basis.y * 9.8 * speed_ratio
	velocity = engine_velocity + (gravity_vector + lift_vector)
	
	move_and_slide()
	
	# Crash detection
	if get_slide_collision_count() > 0:
		var collider = get_slide_collision(0).get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(100.0)
		crash()
		return
	
	# Fire cooldown
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	# Shooting
	if Input.is_action_pressed("ui_accept") and fire_cooldown <= 0:
		shoot()
		fire_cooldown = fire_rate
	
	# Camera shake
	if shake_amount > 0:
		shake_amount = move_toward(shake_amount, 0.0, shake_decay * delta)
		if camera:
			camera.transform.origin = camera_base_transform.origin + Vector3(
				randf_range(-1.0, 1.0) * shake_amount,
				randf_range(-1.0, 1.0) * shake_amount,
				0.0
			)
	elif camera:
		camera.transform.origin = camera_base_transform.origin
	
	# HUD update would go here if we had HUD nodes
	# For now, skip - we'll add HUD back later

func shoot() -> void:
	var forward_dir = -global_transform.basis.z
	var convergence_point = global_position + forward_dir * convergence_distance
	
	# Left wing tip position (calculated, no Marker3D needed)
	var left_pos = global_position + global_transform.basis * Vector3(-wing_span, 0, wing_offset_z)
	var right_pos = global_position + global_transform.basis * Vector3(wing_span, 0, wing_offset_z)
	
	var dir_left = (convergence_point - left_pos).normalized()
	var dir_right = (convergence_point - right_pos).normalized()
	
	# Left bullet
	var bl = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bl)
	bl.global_position = left_pos
	bl.direction = dir_left
	
	# Right bullet
	var br = bullet_scene.instantiate()
	get_tree().current_scene.add_child(br)
	br.global_position = right_pos
	br.direction = dir_right
	
	shake_amount = clamp(shake_amount + 0.05, 0.0, 0.15)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	shake_amount = clamp(shake_amount + 0.25, 0.0, 0.5)
	if health <= 0:
		crash()

func crash() -> void:
	if is_dead:
		return
	is_dead = true
	
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	if GameManager:
		GameManager.checkpoint_death()
	
	await get_tree().create_timer(1.5).timeout
	
	if GameManager and GameManager.is_campaign_over():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		get_tree().reload_current_scene()
