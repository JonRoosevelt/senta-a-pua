# enemy_meshy.gd - Flak tower script using Meshy GLB model
extends StaticBody3D

@export var shoot_range: float = 180.0
@export var fire_rate: float = 1.5

@onready var enemy_bullet_scene = preload("res://scenes/enemy_bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var smoke_scene = preload("res://scenes/smoke_pillar.tscn")

var player: Node3D = null
var fire_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().current_scene.get_node_or_null("Player")
	
	# Fix Meshy model orientation and scale
	var model = $Flak88Model
	if model:
		model.rotation_degrees = Vector3(0, 0, 0)
		model.scale = Vector3(3, 3, 3)

func _physics_process(delta: float) -> void:
	if not player or player.is_dead:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist <= shoot_range:
		var target_pos = player.global_position
		target_pos.y = global_position.y
		
		if global_position.distance_squared_to(target_pos) > 0.001:
			look_at(target_pos, Vector3.UP)
			rotate_y(PI)
		
		fire_timer += delta
		if fire_timer >= fire_rate:
			fire_timer = 0.0
			shoot_at_player()

func shoot_at_player() -> void:
	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector3(0, 5, 0)
	var dir = (player.global_position - bullet.global_position).normalized()
	bullet.direction = dir
	bullet.look_at(bullet.global_position + dir, Vector3.UP)

func take_damage(_amount: float) -> void:
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	var smoke = smoke_scene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position + Vector3(0, 2, 0)
	
	if GameManager:
		GameManager.report_objective("flak_tower")
	
	queue_free()
