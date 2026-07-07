# mission_piave.gd - Missão 1: Batismo de Fogo (Ponte de Piave)
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_build_autumn_environment()
	_spawn_enemies()

func _build_autumn_environment() -> void:
	var b = load("res://scripts/scene_builder.gd").new()
	
	# Terreno outonal
	var terrain = b.create_autumn_terrain()
	add_child(terrain)
	move_child(terrain, 1)
	
	# Rio Piave largo
	var river = b.create_autumn_river()
	add_child(river)
	
	# Dolomitas ao fundo (mais largas, menos pontiagudas)
	var mountains = b.create_dolomites_mountains()
	add_child(mountains)
	
	# Choupos outonais
	var trees = b.create_autumn_trees(60, Vector3(0, 0, -200), Vector2(500, 250))
	add_child(trees)
	
	# Ponte destruível no centro do mapa
	var bridge = b.create_destructible_bridge(Vector3(0, 0, -350), 3)
	add_child(bridge)
	
	# Vilarejo italiano ao longe
	var village = b.create_village(Vector3(-100, 0, -500), 10)
	add_child(village)
	
	b.queue_free()
	print("[Missão Piave] Cenário outonal do Rio Piave construído.")

func _spawn_enemies() -> void:
	# As torres e caças já estão na cena via .tscn
	pass
