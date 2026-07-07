# scene_builder_assets.gd - Environment builder using real 3D assets (FBX/GLTF)
# Replaces BoxMesh garbage with actual low-poly models from Quaternius Nature Pack
extends Node3D

# === ASSET PATHS (preloaded FBX files) ===
const ASSETS = {
	# Autumn trees (various shapes)
	"tree_autumn_1": "res://assets/terrain/CommonTree_Autumn_1.fbx",
	"tree_autumn_2": "res://assets/terrain/CommonTree_Autumn_2.fbx",
	"tree_autumn_3": "res://assets/terrain/CommonTree_Autumn_3.fbx",
	"birch_autumn_1": "res://assets/terrain/BirchTree_Autumn_1.fbx",
	"birch_autumn_2": "res://assets/terrain/BirchTree_Autumn_3.fbx",
	# Rocks
	"rock_1": "res://assets/terrain/Rock_1.fbx",
	"rock_2": "res://assets/terrain/Rock_2.fbx",
	"rock_3": "res://assets/terrain/Rock_3.fbx",
	"rock_moss_1": "res://assets/terrain/Rock_Moss_1.fbx",
	"rock_moss_2": "res://assets/terrain/Rock_Moss_2.fbx",
	# Bushes
	"bush_1": "res://assets/terrain/Bush_1.fbx",
	"bush_2": "res://assets/terrain/Bush_2.fbx",
}

# Simple BoxMesh for things we still need (ground plane, river, simple structures)
const BOX_COLORS = {
	"ground_autumn": Color(0.55, 0.42, 0.22),
	"river_autumn": Color(0.42, 0.55, 0.45),
	"concrete": Color(0.52, 0.50, 0.45),
}

func _make_mat(color: Color, rough: float = 0.8) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return m

func _spawn_mesh(parent: Node, path: String, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scl: float = 1.0) -> void:
	var loaded = load(path)
	if not loaded:
		print("[WARN] Failed to load: ", path)
		return
	var instance = loaded.instantiate()
	instance.position = pos
	instance.rotation_degrees = rot_deg
	instance.scale = Vector3(scl, scl, scl)
	parent.add_child(instance)


# =============================================
# AUTUMN GROUND - simple flat plane (no more grid of tiles)
# =============================================
func create_ground() -> StaticBody3D:
	var root = StaticBody3D.new()
	root.name = "Ground"
	
	# Ground with a simple gradient material (not just flat brown)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.48, 0.38, 0.2)  # warm earth
	mat.roughness = 0.95
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	# Use UV1 for a subtle detail
	mat.uv1_scale = Vector3(20, 20, 20)
	mat.detail_enabled = true
	mat.detail_albedo = Color(0.55, 0.45, 0.25)
	mat.detail_uv_layer = 1
	
	var mi = MeshInstance3D.new()
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(2000, 2000)
	mesh.material = mat
	mi.mesh = mesh
	mi.position = Vector3(0, -0.5, 0)
	root.add_child(mi)
	
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(2000, 1, 2000)
	col.position = Vector3(0, -0.5, 0)
	root.add_child(col)
	
	return root


# =============================================
# RIVER - simple wide blue-green plane
# =============================================
func create_river() -> Node3D:
	var root = Node3D.new()
	root.name = "River"
	
	var mat = _make_mat(BOX_COLORS["river_autumn"], 0.35)
	
	var segments = 15
	var seg_len = 60.0
	var width = 50.0
	var pos = Vector3.ZERO
	var angle = 0.0
	
	for i in range(segments):
		angle += randf_range(-0.06, 0.06)
		var dir = Vector3(sin(angle), 0, 1)
		pos += dir * seg_len
		
		var mi = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(width, 0.2, seg_len * 1.1)
		mesh.material = mat
		mi.mesh = mesh
		mi.position = Vector3(pos.x, 0.15, pos.z)
		mi.rotation = Vector3(0, rad_to_deg(angle), 0)
		root.add_child(mi)
	
	return root


# =============================================
# TREES - using real Quaternius FBX models
# =============================================
func create_forest(count: int, center: Vector3, area: Vector2) -> Node3D:
	var root = Node3D.new()
	root.name = "Forest"
	
	var tree_types = ["tree_autumn_1", "tree_autumn_2", "tree_autumn_3",
		"birch_autumn_1", "birch_autumn_2"]
	
	for _i in range(count):
		var x = center.x + randf_range(-area.x/2, area.x/2)
		var z = center.z + randf_range(-area.y/2, area.y/2)
		var tree_type = tree_types[randi() % tree_types.size()]
		var s = randf_range(2.5, 4.5)  # Much bigger scale for visibility
		var rot = Vector3(0, randf_range(0, 360), 0)
		_spawn_mesh(root, ASSETS[tree_type], Vector3(x, 0, z), rot, s)
	
	return root


# =============================================
# ROCKS - scattered boulders
# =============================================
func create_rocks(count: int, center: Vector3, area: Vector2) -> Node3D:
	var root = Node3D.new()
	root.name = "Rocks"
	
	var rock_types = ["rock_1", "rock_2", "rock_3", "rock_moss_1", "rock_moss_2"]
	
	for _i in range(count):
		var x = center.x + randf_range(-area.x/2, area.x/2)
		var z = center.z + randf_range(-area.y/2, area.y/2)
		var rock_type = rock_types[randi() % rock_types.size()]
		var s = randf_range(2.0, 5.0)  # Bigger rocks
		var rot = Vector3(randf_range(-10, 10), randf_range(0, 360), randf_range(-10, 10))
		_spawn_mesh(root, ASSETS[rock_type], Vector3(x, 0, z), rot, s)
	
	return root


# =============================================
# BUSHES - scattered undergrowth
# =============================================
func create_bushes(count: int, center: Vector3, area: Vector2) -> Node3D:
	var root = Node3D.new()
	root.name = "Bushes"
	
	var bush_types = ["bush_1", "bush_2"]
	
	for _i in range(count):
		var x = center.x + randf_range(-area.x/2, area.x/2)
		var z = center.z + randf_range(-area.y/2, area.y/2)
		var bush_type = bush_types[randi() % bush_types.size()]
		var s = randf_range(0.5, 1.0)
		var rot = Vector3(0, randf_range(0, 360), 0)
		_spawn_mesh(root, ASSETS[bush_type], Vector3(x, 0, z), rot, s)
	
	return root


# =============================================
# DISTANT MOUNTAINS - still BoxMesh but done BETTER (solid pyramid shapes, not stacked boxes)
# =============================================
func create_mountains() -> Node3D:
	var root = Node3D.new()
	root.name = "Mountains"
	
	# Single solid mountain silhouettes closer to player
	var configs = [
		{"pos": Vector3(-250, 60, -400), "w": 140, "h": 180, "d": 90},
		{"pos": Vector3(-50, 70, -450), "w": 120, "h": 210, "d": 80},
		{"pos": Vector3(180, 55, -430), "w": 130, "h": 190, "d": 85},
		{"pos": Vector3(320, 45, -380), "w": 110, "h": 160, "d": 75},
	]
	
	for cfg in configs:
		var m = _make_mountain(cfg["pos"], cfg["w"], cfg["h"], cfg["d"])
		root.add_child(m)
	
	return root


func _make_mountain(pos: Vector3, width: float, height: float, depth: float) -> StaticBody3D:
	var root = StaticBody3D.new()
	root.position = pos
	
	var rock_color = Color(0.38, 0.35, 0.42)
	var highlight = Color(0.45, 0.42, 0.50)
	var snow_color = Color(0.78, 0.80, 0.85)
	
	# 4-layer pyramid: broader at base, narrower at top
	# Each layer is positioned ON TOP of the previous (no gaps)
	var layers = 4
	var prev_h = 0.0
	
	for i in range(layers):
		var t = float(i) / layers
		var lw = width * (1.0 - t * 0.75)
		var ld = depth * (1.0 - t * 0.75)
		var lh = height / layers
		
		var color = rock_color
		if i == layers - 1:
			color = snow_color
		elif i == layers - 2:
			color = highlight
		
		var mat = _make_mat(color, 0.85)
		var mi = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(lw, lh, ld)
		mesh.material = mat
		mi.mesh = mesh
		# Position directly on top of previous layer
		mi.position = Vector3(0, prev_h + lh/2.0, 0)
		mi.rotation_degrees = Vector3(randf_range(-1, 1), randf_range(-2, 2), randf_range(-1, 1))
		root.add_child(mi)
		
		prev_h += lh
	
	# Collision (half size to avoid weird clipping)
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.5, height, depth * 0.5)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col)
	
	return root
