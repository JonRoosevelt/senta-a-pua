# scene_builder.gd - Low-Poly Po Valley Environment Builder
# Uses flat-shaded geometry with proper lighting for a stylized low-poly look
# (not Minecraft blocks - faceted but smooth, like the reference images)
extends Node3D

# === COLOR PALETTE (inspired by reference images) ===
const COLORS = {
	"grass_light": Color(0.35, 0.52, 0.22),
	"grass_mid": Color(0.28, 0.45, 0.18),
	"grass_dark": Color(0.20, 0.35, 0.14),
	"earth": Color(0.42, 0.35, 0.22),
	"mountain_rock": Color(0.38, 0.35, 0.42),
	"mountain_snow": Color(0.78, 0.80, 0.85),
	"mountain_dark": Color(0.28, 0.25, 0.32),
	"water": Color(0.18, 0.30, 0.48),
	"building_wall": Color(0.88, 0.80, 0.65),
	"building_roof": Color(0.68, 0.32, 0.18),
	"building_stone": Color(0.58, 0.52, 0.45),
	"concrete": Color(0.52, 0.50, 0.45),
	"metal_dark": Color(0.18, 0.18, 0.22),
	"metal_barrel": Color(0.22, 0.22, 0.25),
	"wood": Color(0.42, 0.28, 0.15),
	"train_steam": Color(0.15, 0.14, 0.16),
	"train_accent": Color(0.55, 0.18, 0.12),
	"ammo_crate": Color(0.35, 0.28, 0.15),
	"smoke": Color(0.15, 0.13, 0.10, 0.85),
	"fire_glow": Color(1.0, 0.45, 0.08),
}

func make_material(color: Color, rough: float = 0.75, metal: float = 0.0, shade: int = BaseMaterial3D.SHADING_MODE_PER_PIXEL) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	mat.metallic = metal
	mat.shading_mode = shade
	return mat

func box_mesh(size: Vector3, mat: StandardMaterial3D) -> BoxMesh:
	var m = BoxMesh.new()
	m.size = size
	m.material = mat
	return m

func add_node(parent: Node, mesh: Mesh, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


# =============================================
# TERRAIN - flat shaded ground tiles
# =============================================
func create_terrain() -> Node3D:
	var root = Node3D.new()
	root.name = "Terrain"
	
	var grid = [-900, -600, -300, 0, 300, 600, 900]
	
	for x in grid:
		for z in grid:
			var color = COLORS["grass_mid"] if (x + z) % 600 == 0 else COLORS["grass_light"]
			if randf() < 0.25:
				color = COLORS["grass_dark"]
			var mat = make_material(color, 0.9)
			var tile = add_node(root, box_mesh(Vector3(300, 0.3, 300), mat), Vector3(x, 0, z))
			tile.rotation_degrees = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
	
	# Ground collision
	var body = StaticBody3D.new()
	body.name = "GroundPhysics"
	var cs = CollisionShape3D.new()
	cs.shape = BoxShape3D.new()
	cs.shape.size = Vector3(2400, 2, 2400)
	body.add_child(cs)
	root.add_child(body)
	
	return root


# =============================================
# MOUNTAINS - faceted pyramids with snow caps
# =============================================
func create_mountains() -> Node3D:
	var root = Node3D.new()
	root.name = "Mountains"
	
	var configs = [
		# pos x,y,z | base width | height | depth
		{"p": Vector3(-350, 45, -520), "w": 110, "h": 220, "d": 80},
		{"p": Vector3(-180, 55, -580), "w": 85, "h": 260, "d": 70},
		{"p": Vector3(30, 65, -550), "w": 100, "h": 280, "d": 90},
		{"p": Vector3(220, 50, -600), "w": 90, "h": 240, "d": 75},
		{"p": Vector3(380, 40, -530), "w": 105, "h": 200, "d": 80},
		{"p": Vector3(-420, 30, -450), "w": 70, "h": 140, "d": 60},
		{"p": Vector3(440, 35, -460), "w": 75, "h": 150, "d": 65},
	]
	
	for cfg in configs:
		var mountain = _make_mountain(cfg["p"], cfg["w"], cfg["h"], cfg["d"])
		root.add_child(mountain)
	
	return root


func _make_mountain(pos: Vector3, width: float, height: float, depth: float) -> Node3D:
	var root = StaticBody3D.new()
	root.position = pos
	
	var layers = 8
	for i in range(layers):
		var t = float(i) / float(layers)
		var layer_w = width * (1.0 - t * 0.85)
		var layer_d = depth * (1.0 - t * 0.85)
		var layer_h = height / float(layers)
		
		var color: Color
		if i >= layers - 2:
			color = COLORS["mountain_snow"]
		elif t > 0.5:
			color = COLORS["mountain_rock"]
		else:
			color = COLORS["mountain_dark"]
		
		var mat = make_material(color, 0.85)
		add_node(root, box_mesh(Vector3(layer_w, layer_h, layer_d), mat),
			Vector3(0, i * layer_h + layer_h/2.0, 0),
			Vector3(randf_range(-2, 2), randf_range(-3, 3), randf_range(-2, 2)))
	
	# Collision
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(width * 0.6, height, depth * 0.6)
	col.position = Vector3(0, height/2.0, 0)
	root.add_child(col)
	
	return root


# =============================================
# ITALIAN CYPRESS TREES
# =============================================
func create_trees(count: int, center: Vector3, area: Vector2) -> Node3D:
	var root = Node3D.new()
	root.name = "Trees"
	
	for _i in range(count):
		var x = center.x + randf_range(-area.x/2, area.x/2)
		var z = center.z + randf_range(-area.y/2, area.y/2)
		root.add_child(_make_cypress(Vector3(x, 0, z)))
	
	return root


func _make_cypress(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var trunk_h = 5.0 + randf() * 3.0
	var trunk_w = 0.4
	
	# Trunk
	var trunk_mat = make_material(COLORS["wood"], 0.9)
	add_node(root, box_mesh(Vector3(trunk_w, trunk_h, trunk_w), trunk_mat),
		Vector3(0, trunk_h/2.0, 0))
	
	# Foliage layers (tall narrow cones)
	var foliage_layers = 5
	var base_w = 2.5
	var foliage_h = trunk_h * 0.6
	var start_y = trunk_h * 0.45
	
	for i in range(foliage_layers):
		var t = float(i) / float(foliage_layers - 1)
		var w = base_w * (1.0 - t * 0.65)
		var color = COLORS["grass_dark"] if i % 2 == 0 else COLORS["grass_mid"]
		var mat = make_material(color, 0.85)
		add_node(root, box_mesh(Vector3(w, foliage_h/foliage_layers, w), mat),
			Vector3(0, start_y + i * (foliage_h/foliage_layers), 0),
			Vector3(randf_range(-3, 3), randf_range(0, 360), randf_range(-3, 3)))
	
	return root


# =============================================
# ITALIAN VILLAGE
# =============================================
func create_village(center: Vector3, building_count: int) -> Node3D:
	var root = Node3D.new()
	root.name = "Village"
	root.position = center
	
	for _i in range(building_count):
		var bx = randf_range(-50, 50)
		var bz = randf_range(-50, 50)
		root.add_child(_make_building(Vector3(bx, 0, bz)))
	
	root.add_child(_make_church(Vector3(0, 0, 0)))
	
	return root


func _make_building(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var w = randf_range(4, 10)
	var d = randf_range(4, 8)
	var h = randf_range(6, 14)
	
	# Wall color
	var wall_color = COLORS["building_wall"]
	if randf() < 0.3:
		wall_color = COLORS["building_stone"]
	
	var wall_mat = make_material(wall_color, 0.8)
	add_node(root, box_mesh(Vector3(w, h, d), wall_mat), Vector3(0, h/2.0, 0))
	
	# Roof
	var roof_mat = make_material(COLORS["building_roof"], 0.7)
	var roof_w = w + 1.5
	var roof_d = d + 1.5
	
	# Left roof slope
	add_node(root, box_mesh(Vector3(roof_w/2.0, 0.4, roof_d), roof_mat),
		Vector3(0, h + 2.2, 0), Vector3(0, 0, -22))
	# Right roof slope
	add_node(root, box_mesh(Vector3(roof_w/2.0, 0.4, roof_d), roof_mat),
		Vector3(0, h + 2.2, 0), Vector3(0, 0, 22))
	
	# Windows (small dark squares)
	var win_mat = make_material(Color(0.15, 0.18, 0.3), 0.1, 0.5)
	for wi in range(randi() % 3 + 1):
		var wy = h * 0.25 + wi * h * 0.25
		add_node(root, box_mesh(Vector3(0.08, 1.2, 0.8), win_mat),
			Vector3(-w/2.0 - 0.04, wy, d * 0.15))
	
	return root


func _make_church(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var w = 8.0; var d = 14.0; var h = 18.0
	var wall_mat = make_material(COLORS["building_wall"], 0.8)
	
	add_node(root, box_mesh(Vector3(w, h, d), wall_mat), Vector3(0, h/2.0, 0))
	
	# Bell tower
	add_node(root, box_mesh(Vector3(3, h * 1.3, 3), wall_mat),
		Vector3(0, h * 1.3/2.0, -d/2.0 - 1.5))
	
	# Cross
	var cross_mat = make_material(Color(0.25, 0.18, 0.1), 0.9)
	add_node(root, box_mesh(Vector3(0.2, 3.5, 0.3), cross_mat),
		Vector3(0, h * 1.3 + 1.8, -d/2.0 - 1.5))
	add_node(root, box_mesh(Vector3(1.8, 0.2, 0.3), cross_mat),
		Vector3(0, h * 1.3 + 3.0, -d/2.0 - 1.5))
	
	return root


# =============================================
# RAILWAY BRIDGE + GERMAN SUPPLY TRAIN
# =============================================
func create_bridge_train(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.name = "BridgeTrain"
	root.position = pos
	
	var blen = 70.0; var bwid = 6.0; var bheight = 12.0
	
	# Track bed
	var track_mat = make_material(Color(0.25, 0.22, 0.18), 0.85)
	add_node(root, box_mesh(Vector3(bwid, 1.0, blen), track_mat),
		Vector3(0, bheight, 0))
	
	# Pillars
	var pillar_mat = make_material(COLORS["concrete"], 0.85)
	for px in [-18, 0, 18]:
		add_node(root, box_mesh(Vector3(2.5, bheight - 1, 2.5), pillar_mat),
			Vector3(px, (bheight - 1)/2.0, 0))
	
	# Train engine + cars
	root.add_child(_train_engine(Vector3(0, bheight + 2.5, 15)))
	for i in range(3):
		root.add_child(_train_car(Vector3(0, bheight + 2.2, 15 + (i + 1) * 11)))
	
	# Bridge collision
	var body = StaticBody3D.new()
	body.name = "BridgeBody"
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(bwid, bheight + 4, blen)
	body.add_child(shape)
	body.position = Vector3(0, bheight/2.0, 0)
	root.add_child(body)
	
	return root


func _train_engine(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var mat = make_material(COLORS["train_steam"], 0.5, 0.3)
	add_node(root, box_mesh(Vector3(3.5, 3.2, 9), mat), Vector3.ZERO)
	
	var cabin_mat = make_material(COLORS["train_accent"], 0.5)
	add_node(root, box_mesh(Vector3(3.5, 2.2, 3.5), cabin_mat),
		Vector3(0, 2.7, -2.8))
	
	add_node(root, box_mesh(Vector3(1.0, 2.2, 1.0), mat),
		Vector3(0, 3.7, 2.5))  # smokestack
	
	var wheel_mat = make_material(Color(0.08, 0.08, 0.08), 0.3, 0.9)
	for wx in [-1.3, 1.3]:
		for wz in [-2.8, 0, 2.8]:
			add_node(root, box_mesh(Vector3(0.3, 1.2, 1.2), wheel_mat),
				Vector3(wx, -1.2, wz))
	
	return root


func _train_car(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var mat = make_material(Color(0.18, 0.15, 0.12), 0.6, 0.2)
	add_node(root, box_mesh(Vector3(3, 3.5, 8.5), mat), Vector3.ZERO)
	
	var canvas_mat = make_material(Color(0.4, 0.35, 0.25), 0.85)
	add_node(root, box_mesh(Vector3(2.8, 1.5, 8), canvas_mat),
		Vector3(0, 2.5, 0))
	
	var wheel_mat = make_material(Color(0.08, 0.08, 0.08), 0.3, 0.9)
	for wx in [-1.3, 1.3]:
		for wz in [-2.8, 2.8]:
			add_node(root, box_mesh(Vector3(0.3, 1.0, 1.0), wheel_mat),
				Vector3(wx, -1.4, wz))
	
	return root


# =============================================
# FLAK TOWER
# =============================================
func create_flak_tower(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	add_node(root, box_mesh(Vector3(5.5, 1.5, 5.5), make_material(COLORS["concrete"], 0.85)),
		Vector3(0, 0.75, 0))
	add_node(root, box_mesh(Vector3(3.2, 0.6, 3.2), make_material(COLORS["metal_dark"], 0.5, 0.4)),
		Vector3(0, 2.6, 0))
	add_node(root, box_mesh(Vector3(0.35, 0.35, 6.5), make_material(COLORS["metal_barrel"], 0.3, 0.9)),
		Vector3(0, 3.6, 3.5), Vector3(-40, 0, 0))
	add_node(root, box_mesh(Vector3(3.8, 2.8, 0.25), make_material(Color(0.2, 0.22, 0.2), 0.4, 0.5)),
		Vector3(0, 3.1, 1.6))
	
	return root


# =============================================
# AMMO DUMP
# =============================================
func create_ammo_dump(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var mat = make_material(COLORS["ammo_crate"], 0.8)
	for i in range(4):
		add_node(root, box_mesh(Vector3(2.2, 1, 1.6), mat),
			Vector3(randf_range(-1.5, 1.5), i * 1.1 + 0.5, randf_range(-1.5, 1.5)),
			Vector3(0, randf_range(0, 360), 0))
	
	return root


# =============================================
# RIVER (simple blue plane)
# =============================================
func create_river() -> Node3D:
	var root = Node3D.new()
	root.name = "River"
	
	var mat = make_material(COLORS["water"], 0.4, 0.15)
	
	var segments = 30
	var seg_len = 35.0
	var width = 20.0
	var path = Vector3.ZERO
	var angle = 0.0
	
	for i in range(segments):
		angle += randf_range(-0.12, 0.12)
		var dir = Vector3(sin(angle), 0, 1)
		path += dir * seg_len
		add_node(root, box_mesh(Vector3(width, 0.25, seg_len * 1.2), mat),
			Vector3(path.x, 0.15, path.z), Vector3(0, rad_to_deg(angle), 0))
	
	return root
