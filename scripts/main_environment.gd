extends Node3D

func _ready() -> void:
	_build_environment()

func _build_environment() -> void:
	var b = load("res://scripts/scene_builder.gd").new()
	
	# 1. Terrain (look down at grassy Po Valley)
	var terrain = b.create_terrain()
	terrain.name = "PoValleyTerrain"
	add_child(terrain)
	move_child(terrain, 1)  # right after WorldEnvironment
	
	# 2. River cutting through the valley
	var river = b.create_river()
	add_child(river)
	
	# 3. Mountains in the distance
	var mountains = b.create_mountains()
	add_child(mountains)
	
	# 4. Trees scattered
	var trees = b.create_trees(50, Vector3(0, 0, -250), Vector2(400, 250))
	add_child(trees)
	
	# 5. Italian village
	var village = b.create_village(Vector3(-60, 0, -350), 15)
	add_child(village)
	
	# 6. Railway bridge with supply train
	var bridge = b.create_bridge_train(Vector3(80, 6, -450))
	add_child(bridge)
	
	# 7. Ammo dump
	var ammo = b.create_ammo_dump(Vector3(-100, 14, -280))
	add_child(ammo)
	
	b.queue_free()
	print("Po Valley environment populated.")
