extends CharacterBody3D

# ── Movement & Combat ──────────────────────────────────────────
@export var speed: float = 36.0
@export var turn_speed: float = 1.6
@export var max_health: float = 30.0
@export var shoot_range: float = 140.0
@export var fire_rate: float = 0.55

# ── Boom & Zoom state-machine ──────────────────────────────────
enum State { CHASE, EXTEND, RETURN }

@export var close_range: float = 38.0        # Distance to trigger merge → extend
@export var extend_duration: float = 3.2      # Seconds to fly straight away
@export var extend_speed: float = 55.0        # 1.5× during extension
@export var return_turn_factor: float = 0.55  # Wider turns feel cinematic
@export var reacquire_dot: float = 0.82       # ~35° cone to confirm re-acquired

# ── Internals ──────────────────────────────────────────────────
var state: State = State.CHASE
var state_timer: float = 0.0
var player: Node3D = null
var health: float = 30.0
var is_dead: bool = false
var fire_timer: float = 0.0

@onready var enemy_bullet_scene = preload("res://scenes/enemy_bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var smoke_scene = preload("res://scenes/smoke_pillar.tscn")


func _ready() -> void:
	health = max_health
	add_to_group("enemy")
	player = get_tree().current_scene.get_node_or_null("Player")

	var model = $Bf109Model
	if model:
		model.rotation_degrees = Vector3(0, -90, 0)
		model.scale = Vector3(5, 5, 5)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not player or player.is_dead:
		velocity = -global_transform.basis.z * speed
		move_and_slide()
		return

	state_timer += delta
	var dist = global_position.distance_to(player.global_position)
	var to_player = (player.global_position - global_position).normalized()
	var dot_fwd = (-global_transform.basis.z).dot(to_player)   # 1→straight at player, -1→facing away

	match state:
		State.CHASE:
			_turn_toward(player.global_position, turn_speed, delta)
			velocity = -global_transform.basis.z * speed

			# Shoot when pointing roughly at player & within range
			var angle = (-global_transform.basis.z).angle_to(to_player)
			if dist <= shoot_range and angle < 0.26:   # ~15°
				fire_timer += delta
				if fire_timer >= fire_rate:
					fire_timer = 0.0
					shoot()
			else:
				fire_timer = 0.0

			# Merge → extend when very close (and we've been chasing >1.5s)
			if dist < close_range and state_timer > 1.5:
				state = State.EXTEND
				state_timer = 0.0
				fire_timer = 0.0

		State.EXTEND:
			# Fly straight ahead at high speed — no shooting
			velocity = -global_transform.basis.z * extend_speed
			fire_timer = 0.0

			if state_timer >= extend_duration:
				state = State.RETURN
				state_timer = 0.0

		State.RETURN:
			# Wide cinematic turn back toward the player
			_turn_toward(player.global_position, turn_speed * return_turn_factor, delta)
			velocity = -global_transform.basis.z * speed * 0.75

			# Re-acquire when pointing at player again
			if dot_fwd > reacquire_dot and state_timer > 1.8:
				state = State.CHASE
				state_timer = 0.0
				fire_timer = 0.0

	move_and_slide()


func _turn_toward(target_pos: Vector3, t: float, dt: float) -> void:
	if global_position.distance_squared_to(target_pos) < 0.01:
		return
	var target = global_transform.looking_at(target_pos, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target.basis, t * dt)


func shoot() -> void:
	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + (-global_transform.basis.z * 2.5)
	bullet.direction = -global_transform.basis.z
	bullet.look_at(bullet.global_position + bullet.direction, Vector3.UP)


func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		explode()


func explode() -> void:
	is_dead = true

	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position

	var smoke = smoke_scene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position + Vector3(0, -2, 0)

	if GameManager:
		GameManager.report_objective("fighter")

	print("Caça inimigo abatido!")
	queue_free()
