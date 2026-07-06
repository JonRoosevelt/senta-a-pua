extends Area3D

@export var speed: float = 150.0
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Deleta a bala após 3 segundos para liberar memória
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	# Ignora se colidir com o próprio jogador
	if body is CharacterBody3D and body.name == "Player":
		return
		
	# Se o objeto atingido tiver o método take_damage, aplica o dano
	if body.has_method("take_damage"):
		body.take_damage(10)
		
	# Destrói a bala ao colidir com qualquer coisa (exceto o player)
	queue_free()
