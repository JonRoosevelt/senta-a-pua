extends Area3D

@export var speed: float = 120.0
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Destrói a bala inimiga após 3 segundos para não acumular lixo na memória
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	# Se colidir com o jogador, causa dano
	if body is CharacterBody3D and body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(20)
		queue_free()
		return
		
	# Destrói ao colidir com o chão ou montanhas, ignorando outras torres inimigas
	if body is StaticBody3D and not body.name.begins_with("Enemy"):
		queue_free()
