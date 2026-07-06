extends Node3D

func _ready() -> void:
	# Build Po Valley environment procedurally
	_build_environment()

func _build_environment() -> void:
	var builder = load("res://scripts/scene_builder.gd").new()
	
	# 1. Ground terrain (rolling hills)
	var terrain = builder.create_po_valley_ground()
	terrain.name = "PoValleyTerrain"
	add_child(terrain)
	
	# 2. Alps mountains in distance
	var mountains = builder.create_alps_mountains()
	add_child(mountains)
	
	# 3. Italian village near center
	var village = builder.create_italian_village(Vector3(-40, 0, -300), 12)
	add_child(village)
	
	# 4. Cypress trees scattered around
	var trees = builder.create_cypress_trees(40, Vector3(0, 0, -200), Vector2(300, 200))
	add_child(trees)
	
	# 5. Railway bridge with train (key target for interdiction missions)
	var bridge = builder.create_bridge_and_train(Vector3(50, 5, -400))
	add_child(bridge)
	
	# 6. Ammo dump target
	var ammo = builder.create_ammo_dump(Vector3(-80, 12, -250))
	add_child(ammo)
	
	builder.queue_free()
	print("Po Valley environment built!")
