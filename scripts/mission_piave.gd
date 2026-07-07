# mission_piave.gd - Missão 1: Batismo de Fogo (Ponte de Piave)
# Uses real 3D assets from Quaternius Nature Pack
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_build_scene()

func _build_scene() -> void:
	var b = load("res://scripts/scene_builder_assets.gd").new()
	
	# 1. Ground (plane at Y=-0.5, everything else on top)
	var ground = b.create_ground()
	add_child(ground)
	move_child(ground, 1)
	
	# 2. Distant mountains (closer now, at Z=-350)
	var mountains = b.create_mountains()
	add_child(mountains)
	
	# 3. River Piave (at Y=0, ON TOP of ground)
	var river = b.create_river()
	add_child(river)
	
	# 4. Autumn forest (bigger trees, scaled up)
	var forest = b.create_forest(40, Vector3(0, 0, -200), Vector2(400, 250))
	add_child(forest)
	
	# 5. Rocks scattered
	var rocks = b.create_rocks(25, Vector3(0, 0, -200), Vector2(300, 200))
	add_child(rocks)
	
	# 6. Bushes
	var bushes = b.create_bushes(15, Vector3(0, 0, -200), Vector2(250, 150))
	add_child(bushes)
	
	# 7. Bridge (destructible)
	var old_builder = load("res://scripts/scene_builder.gd").new()
	var bridge = old_builder.create_destructible_bridge(Vector3(0, 0, -300), 3)
	add_child(bridge)
	old_builder.queue_free()
	
	b.queue_free()
	print("[Missão Piave] Cenário outonal construído.")
