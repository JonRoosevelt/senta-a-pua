extends CharacterBody3D

@export var speed: float = 32.0
@export var turn_speed: float = 1.4  # Permite que o jogador manobre melhor que ele
@export var max_health: float = 30.0
@export var shoot_range: float = 140.0
@export var fire_rate: float = 0.6  # Cadência de disparo do inimigo

@onready var enemy_bullet_scene = preload("res://scenes/enemy_bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var smoke_scene = preload("res://scenes/smoke_pillar.tscn")
@onready var helice: MeshInstance3D = $Helice

var player: Node3D = null
var health: float = 30.0
var is_dead: bool = false
var fire_timer: float = 0.0

func _ready() -> void:
	health = max_health
	player = get_node_or_null("/root/Main/Player")
	
	# Registra a si mesmo no GameManager global
	if GameManager:
		GameManager.register_enemy()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not player or player.is_dead:
		# Se o player morreu, apenas voa reto
		velocity = -global_transform.basis.z * speed
		move_and_slide()
		return
		
	# Roda a hélice inimiga
	if is_instance_valid(helice):
		helice.rotate_z(24.0 * delta)
		
	# 1. Rastreamento e Perseguição (Suave look_at)
	var target_dir = (player.global_position - global_position).normalized()
	
	# Calcula rotação para apontar para o player
	var target_transform = global_transform.looking_at(player.global_position, Vector3.UP)
	
	# Interpola a rotação do caça (Slerp) para não virar instantaneamente
	global_transform.basis = global_transform.basis.slerp(target_transform.basis, turn_speed * delta)
	
	# Voa para frente local
	velocity = -global_transform.basis.z * speed
	move_and_slide()
	
	# 2. Lógica de Disparo
	var dist = global_position.distance_to(player.global_position)
	var angle_to_player = (-global_transform.basis.z).angle_to(target_dir)
	
	# Atira se estiver no alcance e apontando aproximadamente na direção do jogador (ângulo < 15 graus)
	if dist <= shoot_range and angle_to_player < 0.26:
		fire_timer += delta
		if fire_timer >= fire_rate:
			fire_timer = 0.0
			shoot()
	else:
		fire_timer = 0.0

func shoot() -> void:
	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	# O tiro sai da ponta da hélice (nariz do avião)
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
	
	# Instancia efeito de explosão
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	# Fumaça persistente caindo
	var smoke = smoke_scene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position + Vector3(0, -2, 0)
	
	# Notifica o GameManager
	if GameManager:
		GameManager.enemy_destroyed()
		
	print("Caça inimigo abatido!")
	queue_free()
