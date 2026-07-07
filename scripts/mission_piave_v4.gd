# mission_piave_v4.gd - Infinite procedural river, bridge at center
extends Node3D

var river_segments: Array = []
var river_material: StandardMaterial3D
var last_river_x: float = -500.0
var last_river_z: float = -180.0
var river_angle: float = 0.0
var segment_length: float = 40.0

func _ready() -> void:
	GameManager.start_mission()
	_setup_world()
	_build_terrain()
	_spawn_elements()
	_prefill_river()

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
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.42, 0.38, 0.22)
	ground_mat.roughness = 0.92
	
	var ground_vis = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(3000, 3000)
	plane.material = ground_mat
	ground_vis.mesh = plane
	add_child(ground_vis)
	
	var ground_body = StaticBody3D.new()
	var ground_col = CollisionShape3D.new()
	ground_col.shape = BoxShape3D.new()
	ground_col.shape.size = Vector3(3000, 2, 3000)
	ground_body.add_child(ground_col)
	add_child(ground_body)
	
	# Mountains
	var cfgs = [
		{"x": -250, "z": -400, "w": 120, "h": 150, "d": 80},
		{"x": 0, "z": -450, "w": 100, "h": 170, "d": 75},
		{"x": 200, "z": -420, "w": 110, "h": 140, "d": 70},
	]
	for cfg in cfgs:
		_add_mountain(cfg["x"], cfg["z"], cfg["w"], cfg["h"], cfg["d"])

func _add_mountain(x: float, z: float, width: float, height: float, depth: float) -> void:
	var root = StaticBody3D.new()
	root.position = Vector3(x, 0, z)
	var layers = 5
	var cy = 0.0
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
		mesh.position = Vector3(0, cy + lh/2.0, 0)
		root.add_child(mesh)
		cy += lh
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.5, height, depth * 0.5)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col)
	add_child(root)

func _prefill_river() -> void:
	# Create initial river segments from far west to far east
	river_material = StandardMaterial3D.new()
	river_material.albedo_color = Color(0.25, 0.45, 0.38)
	river_material.roughness = 0.25
	river_material.metallic = 0.3
	
	last_river_x = -800.0
	last_river_z = -180.0
	
	# Pre-generate segments across the whole map
	while last_river_x < 800.0:
		_add_river_segment()

func _add_river_segment() -> void:
	river_angle += randf_range(-0.08, 0.08)
	river_angle = clamp(river_angle, -0.5, 0.5)
	
	var seg = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(segment_length + 2, 0.15, 35)
	mesh.material = river_material
	seg.mesh = mesh
	seg.position = Vector3(last_river_x, 0.08, last_river_z)
	seg.rotation = Vector3(0, river_angle, 0)
	add_child(seg)
	river_segments.append(seg)
	
	# Advance position for next segment
	last_river_x += segment_length * cos(river_angle)
	last_river_z += segment_length * sin(river_angle)

func _process(_delta: float) -> void:
	# Extend river if player is approaching the end
	var player = get_node_or_null("Player")
	if player and river_segments.size() > 0:
		var last_seg = river_segments[-1]
		var dist_to_end = player.global_position.distance_to(last_seg.global_position)
		if dist_to_end < 200.0:
			_add_river_segment()
		
		# Remove old segments far behind player
		if river_segments.size() > 40:
			var first = river_segments.pop_front()
			first.queue_free()

func _spawn_elements() -> void:
	# Bridge at center of river (X=0)
	var bridge_scene = load("res://assets/meshy/bridge_segment.tscn")
	var bridge = bridge_scene.instantiate()
	bridge.position = Vector3(0, 0, -180)
	bridge.objective_type = "bridge_pillar"
	var bmodel = bridge.get_node("BridgeModel")
	if bmodel:
		bmodel.scale = Vector3(25, 12, 12)
		bmodel.rotation_degrees = Vector3(0, 0, 0)
	add_child(bridge)
	
	# Trees
	var b = load("res://scripts/scene_builder_assets.gd").new()
	var trees = b.create_forest(30, Vector3(0, 0, -150), Vector2(400, 60))
	add_child(trees)
	var rocks = b.create_rocks(15, Vector3(0, 0, -190), Vector2(300, 25))
	add_child(rocks)
	b.queue_free()
	
	print("[Piave v4] Infinite river, bridge at center.")
