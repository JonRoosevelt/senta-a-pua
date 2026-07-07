# mission_piave.gd - Missão 1: Batismo de Fogo (Ponte de Piave)
# Uses real 3D assets from Quaternius Nature Pack
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_build_scene()

func _build_scene() -> void:
	var b = load("res://scripts/scene_builder_assets.gd").new()
	
	# 1. Ground (simple plane)
	var ground = b.create_ground()
	ground.position = Vector3(0, -0.5, 0)
	add_child(ground)
	move_child(ground, 1)
	
	# 2. River Piave
	var river = b.create_river()
	add_child(river)
	
	# 3. Distant mountains
	var mountains = b.create_mountains()
	add_child(mountains)
	
	# 4. Autumn forest (real FBX trees!)
	var forest = b.create_forest(50, Vector3(0, 0, -250), Vector2(500, 300))
	add_child(forest)
	
	# 5. Rocks scattered around
	var rocks = b.create_rocks(30, Vector3(0, 0, -200), Vector2(400, 250))
	add_child(rocks)
	
	# 6. Bushes
	var bushes = b.create_bushes(20, Vector3(0, 0, -250), Vector2(300, 200))
	add_child(bushes)
	
	# 7. Bridge (still uses scene_builder.gd for destructible bridge)
	var old_builder = load("res://scripts/scene_builder.gd").new()
	var bridge = old_builder.create_destructible_bridge(Vector3(0, 0, -350), 3)
	add_child(bridge)
	old_builder.queue_free()
	
	b.queue_free()
	print("[Missão Piave] Cenário outonal com assets Quaternius construído.")
