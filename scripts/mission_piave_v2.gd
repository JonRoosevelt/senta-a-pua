# mission_piave_v2.gd - Missão 1 refeita com foco em VISUAIS corretos
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_setup_world()
	_build_terrain()
	_populate_assets()

func _setup_world() -> void:
	# Find or create WorldEnvironment
	var we = $WorldEnvironment
	if not we:
		we = WorldEnvironment.new()
		we.name = "WorldEnvironment"
		add_child(we)
	
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_color = Color(0.5, 0.45, 0.38)
	env.ambient_light_energy = 1.2
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_strength = 0.8
	env.fog_enabled = true
	env.fog_mode = 1  # Depth fog
	env.fog_density = 0.004
	env.fog_light_color = Color(0.85, 0.72, 0.52)
	env.fog_aerial_perspective = 0.5
	
	# Procedural sky
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.45, 0.6, 0.78)
	sky_mat.sky_horizon_color = Color(0.82, 0.68, 0.48)
	sky_mat.ground_horizon_color = Color(0.6, 0.48, 0.32)
	sky_mat.ground_bottom_color = Color(0.45, 0.35, 0.22)
	sky_mat.sun_angle_max = 65.0
	sky_mat.sun_curve = 0.15
	sky.sky_material = sky_mat
	env.sky = sky
	
	we.environment = env
	
	# Directional light (sun)
	var sun = $DirectionalLight3D
	if not sun:
		sun = DirectionalLight3D.new()
		sun.name = "DirectionalLight3D"
		add_child(sun)
	
	sun.position = Vector3(0, 20, 0)
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 3.0
	sun.light_color = Color(1, 0.9, 0.72)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS

func _build_terrain() -> void:
	# === GROUND ===
	var ground = StaticBody3D.new()
	ground.name = "GroundPhysics"
	var ground_col = CollisionShape3D.new()
	ground_col.shape = BoxShape3D.new()
	ground_col.shape.size = Vector3(3000, 2, 3000)
	ground.add_child(ground_col)
	add_child(ground)
	
	# Ground visual (tactical map-style texture based on Po Valley reference)
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_texture = preload("res://scripts/ground_texture.gd").generate()
	ground_mat.roughness = 0.95
	ground_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	
	var ground_vis = MeshInstance3D.new()
	ground_vis.name = "GroundVisual"
	var plane = PlaneMesh.new()
	plane.size = Vector2(3000, 3000)
	plane.material = ground_mat
	ground_vis.mesh = plane
	add_child(ground_vis)
	
	# === MOUNTAINS (touching the ground at Y=0) ===
	var mountain_cfgs = [
		{"x": -200, "z": -350, "w": 120, "h": 150, "d": 80},
		{"x": 0, "z": -400, "w": 100, "h": 170, "d": 75},
		{"x": 180, "z": -370, "w": 110, "h": 140, "d": 70},
		{"x": -300, "z": -320, "w": 80, "h": 100, "d": 60},
		{"x": 280, "z": -330, "w": 90, "h": 110, "d": 65},
	]
	
	for cfg in mountain_cfgs:
		_add_mountain(cfg["x"], cfg["z"], cfg["w"], cfg["h"], cfg["d"])
	
	# === RIVER ===
	var river_mat = StandardMaterial3D.new()
	river_mat.albedo_color = Color(0.25, 0.45, 0.38)
	river_mat.roughness = 0.25
	river_mat.metallic = 0.3
	
	for i in range(12):
		var rz = -280 + i * 35
		var rx = sin(i * 0.2) * 15
		var rw = 35.0 + sin(i * 0.5) * 8
		
		var seg = MeshInstance3D.new()
		var seg_mesh = BoxMesh.new()
		seg_mesh.size = Vector3(rw, 0.15, 36)
		seg_mesh.material = river_mat
		seg.mesh = seg_mesh
		seg.position = Vector3(rx, 0.08, rz)
		add_child(seg)

func _add_mountain(x: float, z: float, width: float, height: float, depth: float) -> void:
	var root = StaticBody3D.new()
	root.position = Vector3(x, 0, z)  # Y=0, no chão!
	
	var layers = 5
	var current_y = 0.0
	
	for i in range(layers):
		var t = float(i) / layers
		var lw = width * (1.0 - t * 0.7)
		var ld = depth * (1.0 - t * 0.7)
		var lh = height / layers
		
		var color: Color
		if i >= layers - 1:
			color = Color(0.72, 0.75, 0.8)  # snow cap
		elif i >= layers - 2:
			color = Color(0.45, 0.42, 0.5)  # rocky highlight
		else:
			color = Color(0.32, 0.3, 0.38)  # dark rock
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.85
		
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(lw, lh, ld)
		box.material = mat
		mesh.mesh = box
		mesh.position = Vector3(0, current_y + lh/2.0, 0)
		mesh.rotation_degrees = Vector3(randf_range(-1, 1), randf_range(-2, 2), randf_range(-1, 1))
		root.add_child(mesh)
		
		current_y += lh
	
	# Collision
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.5, height, depth * 0.5)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col)
	
	add_child(root)

func _populate_assets() -> void:
	var b = load("res://scripts/scene_builder_assets.gd").new()
	
	# Dense tree clusters (Po Valley = agricultural + forest patches)
	# Multiple clusters instead of one spread
	var forest1 = b.create_forest(25, Vector3(-100, 0, -150), Vector2(80, 60))
	add_child(forest1)
	
	var forest2 = b.create_forest(20, Vector3(80, 0, -200), Vector2(70, 60))
	add_child(forest2)
	
	var forest3 = b.create_forest(30, Vector3(0, 0, -100), Vector2(100, 80))
	add_child(forest3)
	
	var forest4 = b.create_forest(15, Vector3(-180, 0, -250), Vector2(50, 40))
	add_child(forest4)
	
	# Rocks near river and mountain bases
	var rocks_river = b.create_rocks(12, Vector3(0, 0, -200), Vector2(60, 40))
	add_child(rocks_river)
	
	var rocks_mountain = b.create_rocks(15, Vector3(-200, 0, -320), Vector2(80, 50))
	add_child(rocks_mountain)
	
	# Bridge (destructible)
	var old_b = load("res://scripts/scene_builder.gd").new()
	var bridge = old_b.create_destructible_bridge(Vector3(0, 0, -280), 3)
	add_child(bridge)
	old_b.queue_free()
	
	b.queue_free()
	print("[Piave v2] Scene ready with dense vegetation.")
