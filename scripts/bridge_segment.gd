# bridge_segment.gd - Segmento destruível da ponte (alvo de missão)
extends StaticBody3D

@export var segment_type: String = "bridge_pillar"  # "bridge_pillar" or "bridge_deck"
@export var max_health: float = 50.0
@export var objective_type: String = "bridge_pillar"

var health: float = 50.0
var is_dead: bool = false

@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var smoke_scene = preload("res://scenes/smoke_pillar.tscn")

func _ready() -> void:
	health = max_health

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		explode()

func explode() -> void:
	is_dead = true
	
	# Explosion
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	# Smoke
	var smoke = smoke_scene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position + Vector3(0, 3, 0)
	
	# Report to GameManager
	if GameManager:
		GameManager.report_objective(objective_type)
	
	print("Segmento da ponte destruído: ", objective_type)
	
	# Hide mesh
	for child in get_children():
		if child is MeshInstance3D:
			child.visible = false
	
	# Disable collision safely
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
			break
