# mission_piave_v3.gd - Redesigned with proper river crossing layout
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_setup_world()
	_build_terrain()
	_spawn_elements()

func _setup_world() -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_color = Color(0.5, 0.45, 0.38)
	env.ambient_light_energy = 1.2
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.fog_enabled = true
	env.fog_mode = 1
	env.fog_density = 0.004
	env.fog_light_color = Color(0.85, 0.72, 0.52)
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.45, 0.6, 0.78)
	sky_mat.sky_horizon_color = Color(0.82, 0.68, 0.48)
	sky_mat.ground_horizon_color = Color(0.6, 0.48, 0.32)
	sky_mat.ground_bottom_color = Color(0.45, 0.35, 0.22)
	sky.sky_material = sky_mat
	env.sky = sky
	
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)
	
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.position = Vector3(0, 20, 0)
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 3.0
	sun.light_color = Color(1, 0.9, 0.72)
	sun.shadow_enabled = true
	add_child(sun)

func _build_terrain() -> void:
	# === GROUND (large flat plane) ===
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.42, 0.38, 0.22)
	ground_mat.roughness = 0.92
	
	var ground_vis = MeshInstance3D.new()
	ground_vis.name = "GroundVisual"
	var plane = PlaneMesh.new()
	plane.size = Vector2(2000, 2000)
	plane.material = ground_mat
	ground_vis.mesh = plane
	add_child(ground_vis)
	
	var ground_body = StaticBody3D.new()
	ground_body.name = "GroundPhysics"
	var ground_col = CollisionShape3D.new()
	ground_col.shape = BoxShape3D.new()
	ground_col.shape.size = Vector3(2000, 2, 2000)
	ground_body.add_child(ground_col)
	add_child(ground_body)
	
	# === RIVER (runs West-East along X axis) ===
	var river_mat = StandardMaterial3D.new()
	river_mat.albedo_color = Color(0.25, 0.45, 0.38)
	river_mat.roughness = 0.25
	river_mat.metallic = 0.3
	
	for i in range(20):
		var rx = -500 + i * 50  # River segments along X axis
		var rz = -180 + sin(i * 0.3) * 8  # Slight curve
		var rw = 52.0  # Each segment slightly wider than spacing
		
		var seg = MeshInstance3D.new()
		var seg_mesh = BoxMesh.new()
		seg_mesh.size = Vector3(rw, 0.15, 30)  # Wide(X) x shallow(Y) x narrow(Z)
		seg_mesh.material = river_mat
		seg.mesh = seg_mesh
		seg.position = Vector3(rx, 0.08, rz)
		add_child(seg)
	
	# === MOUNTAINS in the distance (north, Z=-350+) ===
	var mountain_cfgs = [
		{"x": -250, "z": -400, "w": 120, "h": 150, "d": 80},
		{"x": 0, "z": -450, "w": 100, "h": 170, "d": 75},
		{"x": 200, "z": -420, "w": 110, "h": 140, "d": 70},
		{"x": -350, "z": -370, "w": 80, "h": 100, "d": 60},
		{"x": 300, "z": -380, "w": 90, "h": 110, "d": 65},
	]
	for cfg in mountain_cfgs:
		_add_mountain(cfg["x"], cfg["z"], cfg["w"], cfg["h"], cfg["d"])

func _add_mountain(x: float, z: float, width: float, height: float, depth: float) -> void:
	var root = StaticBody3D.new()
	root.position = Vector3(x, 0, z)
	var layers = 5
	var current_y = 0.0
	for i in range(layers):
		var t = float(i) / layers
		var lw = width * (1.0 - t * 0.7)
		var ld = depth * (1.0 - t * 0.7)
		var lh = height / layers
		var color = Color(0.32, 0.3, 0.38)
		if i >= layers - 1: color = Color(0.72, 0.75, 0.8)
		elif i >= layers - 2: color = Color(0.45, 0.42, 0.5)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.85
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(lw, lh, ld)
		box.material = mat
		mesh.mesh = box
		mesh.position = Vector3(0, current_y + lh/2.0, 0)
		root.add_child(mesh)
		current_y += lh
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.5, height, depth * 0.5)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col)
	add_child(root)

func _spawn_elements() -> void:
	# === BRIDGE crossing the river at center ===
	var bridge_scene = load("res://assets/meshy/bridge_segment.tscn")
	var bridge = bridge_scene.instantiate()
	bridge.position = Vector3(0, 0, -175)
	bridge.objective_type = "bridge_pillar"
	var bmodel = bridge.get_node("BridgeModel")
	if bmodel:
		bmodel.scale = Vector3(25, 12, 12)
		bmodel.rotation_degrees = Vector3(0, 0, 0)
	add_child(bridge)
	
	# === TREES on both sides of river ===
	var b = load("res://scripts/scene_builder_assets.gd").new()
	
	# South bank trees (near player start)
	var trees_south = b.create_forest(20, Vector3(0, 0, -120), Vector2(300, 40))
	add_child(trees_south)
	
	# North bank trees (toward mountains)
	var trees_north = b.create_forest(25, Vector3(0, 0, -230), Vector2(300, 40))
	add_child(trees_north)
	
	# Scattered trees elsewhere
	var trees_east = b.create_forest(15, Vector3(200, 0, -150), Vector2(80, 80))
	add_child(trees_east)
	var trees_west = b.create_forest(15, Vector3(-200, 0, -150), Vector2(80, 80))
	add_child(trees_west)
	
	# Rocks near river banks
	var rocks = b.create_rocks(15, Vector3(0, 0, -190), Vector2(200, 30))
	add_child(rocks)
	
	b.queue_free()
	
	print("[Piave v3] River W→E, bridge at center, mountains north.")
