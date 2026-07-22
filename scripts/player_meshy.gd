extends CharacterBody3D

const LOOK_ANGLE = deg_to_rad(90.0)
const LOOK_SPEED = 6.0

# ── Flight Model ──────────────────────────────────────────────
@export var forward_speed: float = 0.0 # Start at 0 for takeoff
@export var roll_speed: float = 2.5
@export var pitch_speed: float = 2.0
@export var max_health: float = 100.0
@export var invert_pitch: bool = true
@export var convergence_distance: float = 150.0
@export var fire_rate: float = 0.08

# ── Aim Assist (Soft Lock) ───────────────────────────────────
@export var aim_assist_degrees: float = 14.0
@export var aim_assist_max_dist: float = 220.0

# ── Speed ────────────────────────────────────────────────────
@export var min_speed: float = 0.0 # 0 for takeoff from standstill
@export var max_speed: float = 65.0
@export var acceleration_rate: float = 12.0 # Reduced for more realistic takeoff

# ── Takeoff ──────────────────────────────────────────────────
@export var takeoff_rotation_speed: float = 35.0 # Min speed to rotate (m/s)
@export var takeoff_climb_speed: float = 42.0 # Speed where lift overcomes weight
@export var ground_friction: float = 3.0 # Deceleration on ground
@export var ground_pitch_rate: float = 0.8 # Slower pitch on ground
@export var wheel_height: float = 1.5 # Pivot-to-ground distance

var wing_span: float = 4.0
var wing_offset_z: float = 0.0

var health: float = 100.0
var is_dead: bool = false
var fire_cooldown: float = 0.0
var locked_target: Node3D = null
var shake_amount: float = 0.0
var shake_decay: float = 5.0
var camera_base_transform: Transform3D

# ── Takeoff State ─────────────────────────────────────────────
var takeoff_mode: bool = true # Set by mission script
var ground_level: float = 0.0 # Y level of the runway
var is_on_ground: bool = true # Currently touching the ground
var has_rotated: bool = false # Nose has been pulled up
var takeoff_roll_timer: float = 0.0 # Time spent in rotation before liftoff
var crash_grace_timer: float = 0.0 # Brief immunity after takeoff

# --- Look sideways -----
var camera_pivot: Node3D = null

@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	health = max_health
	if camera:
		camera_base_transform = camera.transform

	# Find camera pivot (may have been added after script load)
	camera_pivot = get_node_or_null("CameraPivot")
	print("[Player] camera_pivot = ", camera_pivot, "  camera = ", camera)

	var model = $P47Model
	if model:
		model.rotation_degrees = Vector3(0, -90, 0)
		model.scale = Vector3(5, 5, 5)


# ═══════════════════════════════════════════════════════════════
# ── Physics ───────────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if takeoff_mode and is_on_ground:
		_takeoff_physics(delta)
	else:
		_flight_physics(delta)

	move_and_slide()

	# ── Ground detection (for transition) ────────────────────
	_check_ground_contact()

	# ── Crash grace timer ────────────────────────────────────
	if crash_grace_timer > 0:
		crash_grace_timer -= delta

	# ── Crash detection (skip during ground roll + grace period) ────
	if crash_grace_timer <= 0 and not (takeoff_mode and is_on_ground):
		if get_slide_collision_count() > 0:
			var collider = get_slide_collision(0).get_collider()
			if collider and collider.has_method("take_damage"):
				collider.take_damage(100.0)
			crash()
			return

	# ── Fire cooldown ────────────────────────────────────────
	if fire_cooldown > 0:
		fire_cooldown -= delta

	# ── Shooting (disabled during takeoff ground roll) ───────
	if not (takeoff_mode and is_on_ground):
		_update_aim_assist(delta)
		if Input.is_action_pressed("ui_accept") and fire_cooldown <= 0:
			shoot()
			fire_cooldown = fire_rate

	# ── Camera shake ─────────────────────────────────────────
	_update_camera_shake(delta)

	# ── Look sideways ───────────────────────────────────────
	_look_to_the_side(delta)


# ── Called by mission script ──────────────────────────────────
func set_takeoff_mode(ground_y: float) -> void:
	takeoff_mode = true
	is_on_ground = true
	has_rotated = false
	ground_level = ground_y
	forward_speed = 0.0


func is_airborne() -> bool:
	return not is_on_ground


# ═══════════════════════════════════════════════════════════════
# ── Combat ────────────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
func shoot() -> void:
	var forward_dir = -global_transform.basis.z
	var convergence_point: Vector3

	if locked_target and is_instance_valid(locked_target):
		convergence_point = locked_target.global_position
	else:
		convergence_point = global_position + forward_dir * convergence_distance

	var left_pos = global_position + global_transform.basis * Vector3(-wing_span, 0, wing_offset_z)
	var right_pos = global_position + global_transform.basis * Vector3(wing_span, 0, wing_offset_z)

	var dir_left = (convergence_point - left_pos).normalized()
	var dir_right = (convergence_point - right_pos).normalized()

	var bl = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bl)
	bl.global_position = left_pos
	bl.direction = dir_left

	var br = bullet_scene.instantiate()
	get_tree().current_scene.add_child(br)
	br.global_position = right_pos
	br.direction = dir_right

	shake_amount = clamp(shake_amount + 0.05, 0.0, 0.15)


# ═══════════════════════════════════════════════════════════════
# ── Damage & Death ────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
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

	var model = $P47Model
	if model:
		model.visible = false

	if GameManager:
		GameManager.checkpoint_death()

	await get_tree().create_timer(1.5).timeout

	if GameManager and GameManager.is_campaign_over():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		get_tree().reload_current_scene()


# ── Takeoff (Ground Roll) ─────────────────────────────────────
func _takeoff_physics(delta: float) -> void:
	# ── Throttle ──────────────────────────────────────────────
	if Input.is_key_pressed(KEY_W):
		forward_speed = min(forward_speed + acceleration_rate * delta, max_speed)
	if Input.is_key_pressed(KEY_S):
		forward_speed = max(forward_speed - acceleration_rate * delta, 0.0)

	# ── Apply ground friction ─────────────────────────────────
	if not Input.is_key_pressed(KEY_W):
		forward_speed = max(forward_speed - ground_friction * delta, 0.0)

	# ── Forward movement only (constrained to ground) ─────────
	var forward_dir = -global_transform.basis.z
	velocity = forward_dir * forward_speed
	velocity.y = 0 # No vertical movement on ground

	# ── Rotation ──────────────────────────────────────────────
	# Only allow pitch rotation above takeoff rotation speed
	if forward_speed >= takeoff_rotation_speed:
		var pitch_input = Input.get_axis("ui_up", "ui_down") if invert_pitch else Input.get_axis(
			"ui_down",
			"ui_up",
		)
		# Pull back = negative pitch (nose up) in Godot's convention
		rotate_object_local(Vector3.RIGHT, pitch_input * pitch_speed * ground_pitch_rate * delta)

	# ── Check for liftoff ─────────────────────────────────────
	# Nose is up AND speed is high enough
	var nose_up = -global_transform.basis.z.y # How much we're pointing up
	if forward_speed >= takeoff_climb_speed and nose_up > 0.05:
		has_rotated = true
		takeoff_roll_timer += delta

		# After a short moment of rotation, transition to flight
		_transition_to_flight()

	# ── Constrain to ground ───────────────────────────────────
	global_position.y = ground_level + wheel_height # Keep plane at wheel height


func _transition_to_flight() -> void:
	is_on_ground = false
	takeoff_mode = false
	takeoff_roll_timer = 0.0
	crash_grace_timer = 2.5 # 2.5 second immunity after takeoff
	print("[Player] Decolagem! Transição para voo.")


# ── Flight Physics ────────────────────────────────────────────
func _flight_physics(delta: float) -> void:
	# ── Throttle ──────────────────────────────────────────────
	if Input.is_key_pressed(KEY_W):
		forward_speed = min(forward_speed + acceleration_rate * delta, max_speed)
	if Input.is_key_pressed(KEY_S):
		forward_speed = max(forward_speed - acceleration_rate * delta, min_speed)

	# ── Rotation ──────────────────────────────────────────────
	var roll_input = Input.get_axis("ui_left", "ui_right")
	var pitch_input = Input.get_axis("ui_up", "ui_down")

	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)
	rotate_object_local(Vector3.RIGHT, pitch_input * pitch_speed * delta)

	# ── Flight physics ────────────────────────────────────────
	var forward_direction = -global_transform.basis.z
	var forward_flat = forward_direction
	forward_flat.y = 0
	forward_flat = forward_flat.normalized()
	var engine_velocity = forward_flat * forward_speed
	var gravity_vector = Vector3(0, -9.8, 0)
	var speed_ratio = forward_speed / 40.0
	# use global Y (lift always upwards, regardless of the inclination)
	var nose_up = -global_transform.basis.z.y
	nose_up = clamp(nose_up, -0.3, 1.0)
	var lift_factor = max(0.0, nose_up) * 2.5
	var lift_vector = Vector3.UP * 9.8 * speed_ratio * lift_factor
	velocity = engine_velocity + (gravity_vector + lift_vector)


# ── Ground Contact ────────────────────────────────────────────
func _check_ground_contact() -> void:
	# Raycast down to detect ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3(0, -3.0, 0),
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		# Nothing below — we're airborne
		if is_on_ground and forward_speed > takeoff_climb_speed:
			_transition_to_flight()
		return

	# Something below — check distance
	var dist_to_ground = global_position.y - result.position.y

	if dist_to_ground < 2.0:
		if not is_on_ground and takeoff_mode:
			# Touched down again — still in takeoff mode, back to ground
			is_on_ground = true
			global_position.y = ground_level + wheel_height
			velocity.y = 0
	else:
		if is_on_ground and forward_speed > takeoff_climb_speed:
			_transition_to_flight()


# ── Camera ────────────────────────────────────────────────────
func _update_camera_shake(delta: float) -> void:
	if shake_amount > 0:
		shake_amount = move_toward(shake_amount, 0.0, shake_decay * delta)
		if camera:
			camera.transform.origin = camera_base_transform.origin + Vector3(
				randf_range(-1.0, 1.0) * shake_amount,
				randf_range(-1.0, 1.0) * shake_amount,
				0.0,
			)
	elif camera:
		camera.transform.origin = camera_base_transform.origin


func _look_to_the_side(delta: float) -> void:
	var target_y = 0.0
	if Input.is_key_pressed(KEY_Q):
		print("pressed Q")
		target_y = LOOK_ANGLE
	if Input.is_key_pressed(KEY_E):
		print("pressed E")
		target_y = -LOOK_ANGLE

	if camera:
		camera.rotation.y = move_toward(camera.rotation.y, target_y, LOOK_SPEED * delta)


func _update_aim_assist(_delta: float) -> void:
	locked_target = null
	var best_angle = deg_to_rad(aim_assist_degrees)
	var forward = -global_transform.basis.z

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var to_enemy = (enemy.global_position - global_position).normalized()
		var angle = forward.angle_to(to_enemy)
		var dist = global_position.distance_to(enemy.global_position)
		if angle < best_angle and dist < aim_assist_max_dist:
			best_angle = angle
			locked_target = enemy
