extends StaticBody3D

@export var shoot_range: float = 180.0
@export var fire_rate: float = 1.5 # Intervalo de disparo em segundos

@onready var enemy_bullet_scene = preload("res://scenes/enemy_bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var smoke_scene = preload("res://scenes/smoke_pillar.tscn")

var player: Node3D = null
var fire_timer: float = 0.0

func _ready() -> void:
	# Procura pelo jogador na cena principal
	player = get_node_or_null("/root/Main/Player")
	if not player:
		# Try finding by scene path
		player = get_tree().current_scene.get_node_or_null("Player")

func _physics_process(delta: float) -> void:
	if not player or player.is_dead:
		return
		
	# Calcula a distância até o jogador
	var dist = global_position.distance_to(player.global_position)
	
	if dist <= shoot_range:
		# Faz a torre olhar na direção horizontal do player
		var target_pos = player.global_position
		target_pos.y = global_position.y # Evita inclinar a torre inteira
		
		if global_position.distance_squared_to(target_pos) > 0.001:
			look_at(target_pos, Vector3.UP)
			rotate_y(PI) # Ajusta a orientação se necessário dependendo do mesh
		
		# Conta o tempo para disparar
		fire_timer += delta
		if fire_timer >= fire_rate:
			fire_timer = 0.0
			shoot_at_player()

func shoot_at_player() -> void:
	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	# O tiro sai da ponta superior da torre (altura de 4 metros)
	bullet.global_position = global_position + Vector3(0, 4.2, 0)
	
	# Calcula a direção apontando para o jogador
	var dir = (player.global_position - bullet.global_position).normalized()
	bullet.direction = dir
	
	# Orienta o projétil na direção do voo
	bullet.look_at(bullet.global_position + dir, Vector3.UP)

func take_damage(_amount: float) -> void:
	# Instancia o efeito de explosão 3D
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	# Instancia fumaça persistente no local
	var smoke = smoke_scene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position + Vector3(0, 2, 0)
	
	# Notifica o GameManager da destruição
	if GameManager:
		GameManager.report_objective("flak_tower")
	
	print("Torre inimiga destruída!")
	queue_free()
