# mission_base.gd - Script base para todas as cenas de missão
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_build_environment()
	_update_hud_objectives()

func _build_environment() -> void:
	var b = load("res://scripts/scene_builder.gd").new()
	
	# Terreno patchwork do Vale do Pó
	var terrain = b.create_terrain()
	terrain.name = "PoValleyTerrain"
	add_child(terrain)
	move_child(terrain, 1)
	
	# Trilhas de terra entre campos
	var paths = b.create_field_paths()
	add_child(paths)
	
	var mountains = b.create_mountains()
	add_child(mountains)
	
	var trees = b.create_trees(300, Vector3(0, 0, -200), Vector2(600, 400))
	add_child(trees)
	
	var village = b.create_village(Vector3(-60, 0, -350), 12)
	add_child(village)
	
	var river = b.create_river()
	add_child(river)
	
	# Assets específicos da missão
	var missao = GameManager.get_current_mission()
	
	if missao.get("has_bridge"):
		var bridge = b.create_bridge_train(Vector3(80, 6, -450))
		bridge.name = "BridgeTrain"
		add_child(bridge)
	
	if missao.get("has_ammo_dump"):
		var ammo = b.create_ammo_dump(Vector3(-100, 14, -280))
		ammo.name = "AmmoDump"
		add_child(ammo)
	
	if missao.get("has_artillery_nest"):
		var nest = b.create_artillery_nest(Vector3(120, 5, -350))
		nest.name = "ArtilleryNest"
		add_child(nest)
	
	if missao.get("has_bombers"):
		# Bombardeiros aliados voando em formação à frente do jogador
		var bomber_group = Node3D.new()
		bomber_group.name = "BomberGroup"
		var bomber1 = b.create_bomber(Vector3(-30, 35, -200))
		var bomber2 = b.create_bomber(Vector3(10, 35, -250))
		var bomber3 = b.create_bomber(Vector3(-10, 35, -300))
		bomber_group.add_child(bomber1)
		bomber_group.add_child(bomber2)
		bomber_group.add_child(bomber3)
		add_child(bomber_group)
	
	b.queue_free()

func _update_hud_objectives() -> void:
	# O HUD é atualizado pelo player.gd, mas podemos adicionar texto de objetivos aqui
	pass
