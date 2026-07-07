# mission_piave_final.gd - Complete Mission 1 with all 13 Meshy assets
extends Node3D

var river_segments: Array = []
var river_material: StandardMaterial3D
var last_river_x: float = -800.0
var last_river_z: float = -180.0
var river_angle: float = 0.0
var segment_length: float = 40.0

func _ready() -> void:
	print("[Piave Final] Starting...")
	GameManager.start_mission()
	_setup_world()
	print("[Piave Final] World setup done")
	_build_terrain()
	print("[Piave Final] Terrain done")
	_prefill_river()
	print("[Piave Final] River done")
	_spawn_bridge_and_train()
	print("[Piave Final] Bridge+train spawned")
	_spawn_village()
	print("[Piave Final] Village spawned")
	_spawn_military_targets()
	print("[Piave Final] Military targets spawned")
	_spawn_vegetation()
	print("[Piave Final] Vegetation spawned. DONE.")

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
	
	# Mountains north
	for cfg in [
		{"x": -250, "z": -400, "w": 120, "h": 150, "d": 80},
		{"x": 0, "z": -450, "w": 100, "h": 170, "d": 75},
		{"x": 200, "z": -420, "w": 110, "h": 140, "d": 70},
	]:
		_add_mountain(cfg["x"], cfg["z"], cfg["w"], cfg["h"], cfg["d"])

func _add_mountain(x: float, z: float, width: float, height: float, depth: float) -> void:
	var root = StaticBody3D.new()
	root.position = Vector3(x, 0, z)
	var cy = 0.0
	for i in range(5):
		var t = float(i) / 5
		var lw = width * (1.0 - t * 0.7)
		var ld = depth * (1.0 - t * 0.7)
		var lh = height / 5
		var color = Color(0.32, 0.3, 0.38)
		if i >= 4: color = Color(0.72, 0.75, 0.8)
		elif i >= 3: color = Color(0.45, 0.42, 0.5)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color; mat.roughness = 0.85
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(lw, lh, ld); box.material = mat
		mesh.mesh = box; mesh.position = Vector3(0, cy + lh/2.0, 0)
		root.add_child(mesh); cy += lh
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.5, height, depth * 0.5)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col); add_child(root)

# =============================================
# RIVER
# =============================================
func _prefill_river() -> void:
	river_material = StandardMaterial3D.new()
	river_material.albedo_color = Color(0.25, 0.45, 0.38)
	river_material.roughness = 0.25
	river_material.metallic = 0.3
	while last_river_x < 800.0:
		_add_river_segment()

func _add_river_segment() -> void:
	river_angle += randf_range(-0.06, 0.06)
	river_angle = clamp(river_angle, -0.4, 0.4)
	var seg = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(segment_length + 2, 0.15, 35)
	mesh.material = river_material
	seg.mesh = mesh
	seg.position = Vector3(last_river_x, 0.08, last_river_z)
	seg.rotation = Vector3(0, river_angle, 0)
	add_child(seg)
	river_segments.append(seg)
	last_river_x += segment_length * cos(river_angle)
	last_river_z += segment_length * sin(river_angle)

func _process(_delta: float) -> void:
	var player = get_node_or_null("Player")
	if player and river_segments.size() > 0:
		if player.global_position.distance_to(river_segments[-1].global_position) < 200.0:
			_add_river_segment()
		if river_segments.size() > 40:
			river_segments.pop_front().queue_free()

# =============================================
# BRIDGE + TRAIN
# =============================================
func _spawn_bridge_and_train() -> void:
	# Bridge at center
	var bridge = _spawn_glb("res://assets/meshy/railway_bridge.glb",
		Vector3(0, 0, -180), Vector3(25, 12, 12), Vector3(0, 0, 0))
	bridge.name = "Bridge"
	_add_bridge_script(bridge)
	
	# Steam locomotive on bridge
	var train = _spawn_glb("res://assets/meshy/steam_train.glb",
		Vector3(0, 5, -220), Vector3(15, 15, 15), Vector3(0, 0, 0))
	train.name = "SteamTrain"
	
	# Boxcars behind locomotive
	for i in range(3):
		var boxcar = _spawn_glb("res://assets/meshy/boxcar.glb",
			Vector3(0, 5, -245 - i * 18), Vector3(15, 15, 15), Vector3(0, 0, 0))
		boxcar.name = "Boxcar" + str(i)

# =============================================
# ITALIAN VILLAGE
# =============================================
func _spawn_village() -> void:
	# Organic village layout - houses clustered around the church
	# Church is the anchor at center
	var church = _spawn_glb("res://assets/meshy/church.glb",
		Vector3(-60, 0, -100), Vector3(18, 18, 18), Vector3(0, 15, 0))
	church.name = "Church"
	
	# Houses in a loose cluster around the church, with organic offsets
	var house_data = [
		# (x_offset, z_offset, rotation)
		Vector3(-90, 0, -85),   # NW of church
		Vector3(-85, 0, -115),  # SW
		Vector3(-40, 0, -80),   # NE
		Vector3(-35, 0, -120),  # SE
		Vector3(-65, 0, -65),   # North
		Vector3(-70, 0, -135),  # South
		Vector3(-110, 0, -100), # West
		Vector3(-20, 0, -100),  # East
	]
	
	for pos in house_data:
		var house = _spawn_glb("res://assets/meshy/farmhouse.glb", pos,
			Vector3(15, 15, 15), Vector3(0, randf_range(0, 360), 0))
		house.name = "Farmhouse"
	
	# Second cluster - smaller, east side
	var east_buildings = [
		Vector3(140, 0, -80),
		Vector3(160, 0, -95),
		Vector3(150, 0, -120),
		Vector3(180, 0, -85),
	]
	for pos in east_buildings:
		var b = _spawn_glb("res://assets/meshy/village_building.glb", pos,
			Vector3(15, 15, 15), Vector3(0, randf_range(0, 360), 0))
		b.name = "VillageBuilding"
	
	# A couple more farmhouses scattered
	var extra_houses = [
		Vector3(-180, 0, -70),
		Vector3(200, 0, -130),
		Vector3(-140, 0, -140),
	]
	for pos in extra_houses:
		var house = _spawn_glb("res://assets/meshy/farmhouse.glb", pos,
			Vector3(15, 15, 15), Vector3(0, randf_range(0, 360), 0))
		house.name = "Farmhouse"

# =============================================
# MILITARY TARGETS
# =============================================
func _spawn_military_targets() -> void:
	# Bunker near bridge
	var bunker = _spawn_glb("res://assets/meshy/bunker.glb",
		Vector3(60, 0, -210), Vector3(15, 15, 15), Vector3(0, 0, 0))
	bunker.name = "Bunker"
	
	# Ammo depot west
	var ammo = _spawn_glb("res://assets/meshy/ammo_depot.glb",
		Vector3(-200, 0, -280), Vector3(15, 15, 15), Vector3(0, 45, 0))
	ammo.name = "AmmoDepot"

# =============================================
# VEGETATION
# =============================================
func _spawn_vegetation() -> void:
	# DENSE forest clusters (not scattered individuals)
	# North bank forest (between river and mountains)
	_spawn_tree_cluster(Vector3(-150, 0, -230), 20, 40)
	_spawn_tree_cluster(Vector3(50, 0, -240), 15, 35)
	_spawn_tree_cluster(Vector3(200, 0, -225), 18, 30)
	
	# South bank trees (near player start)
	_spawn_tree_cluster(Vector3(-100, 0, -130), 12, 25)
	_spawn_tree_cluster(Vector3(80, 0, -120), 12, 25)
	
	# Village trees (around houses)
	_spawn_tree_cluster(Vector3(-60, 0, -100), 8, 15)
	_spawn_tree_cluster(Vector3(150, 0, -100), 6, 12)
	
	# Eastern forest
	_spawn_tree_cluster(Vector3(-250, 0, -180), 10, 20)
	
	# Scattered individual trees between clusters
	for _i in range(30):
		var x = randf_range(-300, 300)
		var z = randf_range(-140, -260)
		var tree = _spawn_glb("res://assets/meshy/cypress.glb", Vector3(x, 0, z),
			Vector3(10, 10, 10), Vector3(0, randf_range(0, 360), 0))
		tree.name = "Cypress"

func _spawn_tree_cluster(center: Vector3, count: int, radius: float) -> void:
	for _i in range(count):
		var angle = randf_range(0, TAU)
		var dist = randf_range(0, radius)
		var x = center.x + cos(angle) * dist
		var z = center.z + sin(angle) * dist
		var tree = _spawn_glb("res://assets/meshy/cypress.glb", Vector3(x, 0, z),
			Vector3(10, 10, 10), Vector3(0, randf_range(0, 360), 0))
		tree.name = "Cypress"

# =============================================
# HELPERS
# =============================================
func _spawn_glb(path: String, pos: Vector3, scl: Vector3, rot: Vector3) -> Node3D:
	print("  Spawning: ", path, " at ", pos)
	var scene = load(path)
	if not scene:
		print("  ERROR: Failed to load ", path)
		return Node3D.new()
	var instance = scene.instantiate()
	instance.position = pos
	instance.scale = scl
	instance.rotation_degrees = rot
	
	# Disable all collision on scenery assets
	_remove_collisions(instance)
	
	add_child(instance)
	print("  -> Spawned OK, child count now: ", get_child_count())
	return instance

func _remove_collisions(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionShape3D or child is StaticBody3D or child is CharacterBody3D:
			child.queue_free()
		else:
			_remove_collisions(child)

func _add_collision(node: Node3D, size: Vector3) -> void:
	var body = StaticBody3D.new()
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = size
	body.add_child(col)
	node.add_child(body)

func _add_bridge_script(node: Node3D) -> void:
	# Bridge script requires StaticBody3D, create it as child
	var body = StaticBody3D.new()
	body.name = "BridgeBody"
	body.set_script(load("res://scripts/bridge_segment.gd"))
	body.objective_type = "bridge_pillar"
	body.max_health = 80.0
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(50, 15, 15)
	body.add_child(col)
	node.add_child(body)
