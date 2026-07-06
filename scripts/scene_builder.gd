# scene_builder.gd - Procedural Low-Poly Asset Generator
# Attach to Main node to populate the Po Valley scene
extends Node3D

# === TERRAIN ===
func create_po_valley_ground() -> Node3D:
	var ground_root = Node3D.new()
	ground_root.name = "PoValleyTerrain"
	
	# Main ground plane - faceted low-poly terrain
	# We'll use multiple tilted planes to create rolling hills
	var colors = [
		Color(0.22, 0.28, 0.15),  # olive green field
		Color(0.25, 0.30, 0.18),  # lighter field
		Color(0.18, 0.22, 0.12),  # darker field
		Color(0.28, 0.25, 0.14),  # dry grass
		Color(0.15, 0.18, 0.10),  # dark earth
	]
	
	# Create a grid of tilted ground planes for rolling hills effect
	var grid_size = 10
	var cell_size = 150.0
	for x in range(-grid_size/2, grid_size/2):
		for z in range(-grid_size/2, grid_size/2):
			var tile = _create_ground_tile(
				Vector3(x * cell_size, 0, z * cell_size),
				Vector3(cell_size, 0.5, cell_size),
				colors[randi() % colors.size()]
			)
			
			# Slight random tilt for low-poly faceted look
			tile.rotation_degrees = Vector3(
				randf_range(-2.0, 2.0),
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			)
			ground_root.add_child(tile)
	
	# Add collision body
	var ground_body = StaticBody3D.new()
	ground_body.name = "GroundPhysics"
	var ground_shape = CollisionShape3D.new()
	var ground_box = BoxShape3D.new()
	ground_box.size = Vector3(grid_size * cell_size, 2, grid_size * cell_size)
	ground_shape.shape = ground_box
	ground_body.add_child(ground_shape)
	ground_root.add_child(ground_body)
	
	return ground_root


func _create_ground_tile(pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var mesh = BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	return mi


# === MOUNTAINS (Alps) ===
func create_alps_mountains() -> Node3D:
	var mountains_root = Node3D.new()
	mountains_root.name = "AlpsMountains"
	
	# Create a ridge of jagged mountains in the distance
	var mountain_configs = [
		{"pos": Vector3(-250, 60, -500), "width": 80, "height": 200, "depth": 60},
		{"pos": Vector3(-150, 45, -550), "width": 60, "height": 150, "depth": 50},
		{"pos": Vector3(0, 80, -520), "width": 90, "height": 240, "depth": 70},
		{"pos": Vector3(150, 50, -560), "width": 70, "height": 170, "depth": 55},
		{"pos": Vector3(250, 55, -510), "width": 75, "height": 190, "depth": 60},
		{"pos": Vector3(-300, 30, -420), "width": 50, "height": 100, "depth": 40},
		{"pos": Vector3(300, 35, -430), "width": 55, "height": 110, "depth": 45},
	]
	
	for cfg in mountain_configs:
		var mountain = _create_mountain(cfg["pos"], cfg["width"], cfg["height"], cfg["depth"])
		mountains_root.add_child(mountain)
	
	return mountains_root


func _create_mountain(pos: Vector3, width: float, height: float, depth: float) -> Node3D:
	var root = StaticBody3D.new()
	root.position = pos
	
	# Mountain base color (deep purple-blue for distance)
	var base_color = Color(0.2, 0.18, 0.3)
	var highlight_color = Color(0.25, 0.22, 0.38)
	
	# Create pyramid-like mountain using multiple stacked boxes (low-poly style)
	var layers = 6
	for i in range(layers):
		var t = float(i) / float(layers)
		var layer_width = width * (1.0 - t * 0.8)
		var layer_depth = depth * (1.0 - t * 0.8)
		var layer_height = height / float(layers)
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = base_color.lerp(highlight_color, t * 0.5)
		mat.roughness = 0.9
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
		var mesh = BoxMesh.new()
		mesh.size = Vector3(layer_width, layer_height, layer_depth)
		mesh.material = mat
		
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = Vector3(0, i * layer_height + layer_height/2.0, 0)
		mi.rotation_degrees = Vector3(randf_range(-3, 3), randf_range(-3, 3), randf_range(-3, 3))
		root.add_child(mi)
		
		# Add snow cap on top layers
		if i >= layers - 2:
			var snow_color = Color(0.75, 0.78, 0.85) if i == layers - 1 else Color(0.55, 0.58, 0.7)
			mat.albedo_color = snow_color
	
	# collision
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(width * 0.6, height, depth * 0.6)
	shape.shape = box
	shape.position = Vector3(0, height/2.0, 0)
	root.add_child(shape)
	
	return root


# === RIVER (Po River) ===
func create_river() -> Node3D:
	var river_root = Node3D.new()
	river_root.name = "PoRiver"
	
	var river_mat = StandardMaterial3D.new()
	river_mat.albedo_color = Color(0.15, 0.25, 0.4)
	river_mat.roughness = 0.3
	river_mat.metallic = 0.1
	river_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Create a winding river using segments
	var segments = 40
	var segment_length = 30.0
	var river_width = 18.0
	var path_center = Vector3.ZERO
	var angle = 0.0
	
	for i in range(segments):
		angle += randf_range(-0.15, 0.15)
		var dir = Vector3(sin(angle), 0, 1)
		path_center += dir * segment_length
		
		var mesh = BoxMesh.new()
		mesh.size = Vector3(river_width, 0.3, segment_length * 1.2)
		mesh.material = river_mat
		
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = path_center - Vector3(0, 0.3, 0)
		mi.rotation = Vector3(0, angle, 0)
		river_root.add_child(mi)
	
	return river_root


# === TREES (Italian Cypress) ===
func create_cypress_trees(count: int, area_center: Vector3, area_size: Vector2) -> Node3D:
	var trees_root = Node3D.new()
	trees_root.name = "CypressTrees"
	
	for i in range(count):
		var x = area_center.x + randf_range(-area_size.x/2, area_size.x/2)
		var z = area_center.z + randf_range(-area_size.y/2, area_size.y/2)
		var tree = _create_cypress(Vector3(x, 0, z))
		trees_root.add_child(tree)
	
	return trees_root


func _create_cypress(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var trunk_color = Color(0.35, 0.25, 0.15)
	var leaves_color = Color(0.15, 0.35, 0.12)
	var leaves_dark = Color(0.1, 0.28, 0.08)
	
	# Trunk
	var trunk_mat = StandardMaterial3D.new()
	trunk_mat.albedo_color = trunk_color
	trunk_mat.roughness = 0.9
	trunk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var trunk = MeshInstance3D.new()
	var trunk_mesh = BoxMesh.new()
	trunk_mesh.size = Vector3(0.5, 6.0 + randf() * 4.0, 0.5)
	trunk_mesh.material = trunk_mat
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0, trunk_mesh.size.y / 2.0, 0)
	root.add_child(trunk)
	
	# Foliage - stacked cones (classic cypress shape)
	var foliage_layers = 4
	var base_width = 3.0
	var total_height = trunk_mesh.size.y * 0.7
	var start_y = trunk_mesh.size.y * 0.4
	
	for i in range(foliage_layers):
		var t = float(i) / float(foliage_layers - 1)
		var layer_width = base_width * (1.0 - t * 0.6)
		var layer_height = total_height / foliage_layers
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = leaves_color if i % 2 == 0 else leaves_dark
		mat.roughness = 0.9
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
		var foliage = MeshInstance3D.new()
		var foliage_mesh = BoxMesh.new()
		foliage_mesh.size = Vector3(layer_width, layer_height, layer_width)
		foliage_mesh.material = mat
		foliage.mesh = foliage_mesh
		foliage.position = Vector3(0, start_y + i * layer_height, 0)
		foliage.rotation_degrees = Vector3(randf_range(-3, 3), randf_range(0, 360), randf_range(-3, 3))
		root.add_child(foliage)
	
	return root


# === ITALIAN VILLAGE BUILDINGS ===
func create_italian_village(center: Vector3, building_count: int) -> Node3D:
	var village_root = Node3D.new()
	village_root.name = "ItalianVillage"
	village_root.position = center
	
	for i in range(building_count):
		var x = randf_range(-40, 40)
		var z = randf_range(-40, 40)
		var building = _create_building(Vector3(x, 0, z))
		village_root.add_child(building)
	
	# Add a church (taller building with cross-like top)
	var church = _create_church(Vector3(0, 0, 0))
	village_root.add_child(church)
	
	return village_root


func _create_building(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var w = randf_range(4, 10)
	var d = randf_range(4, 8)
	var h = randf_range(5, 12)
	
	# Walls - warm Italian colors
	var wall_color: Color
	var r = randf()
	if r < 0.4:
		wall_color = Color(0.85, 0.78, 0.65)  # cream/beige
	elif r < 0.7:
		wall_color = Color(0.75, 0.55, 0.35)  # terracotta
	else:
		wall_color = Color(0.6, 0.55, 0.45)  # stone gray
	
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = wall_color
	wall_mat.roughness = 0.8
	wall_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var walls = MeshInstance3D.new()
	var wall_mesh = BoxMesh.new()
	wall_mesh.size = Vector3(w, h, d)
	wall_mesh.material = wall_mat
	walls.mesh = wall_mesh
	walls.position = Vector3(0, h/2.0, 0)
	root.add_child(walls)
	
	# Roof - orange clay tiles
	var roof_color = Color(0.7, 0.3, 0.15)
	var roof_mat = StandardMaterial3D.new()
	roof_mat.albedo_color = roof_color
	roof_mat.roughness = 0.7
	roof_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Roof as a prism (two boxes forming a triangle roof shape)
	var roof_width = w + 1.0
	var roof_depth = d + 1.0
	var roof_thickness = 0.5
	
	# Left slope
	var roof_left = MeshInstance3D.new()
	var rl_mesh = BoxMesh.new()
	rl_mesh.size = Vector3(roof_width/2.0, roof_thickness, roof_depth)
	rl_mesh.material = roof_mat
	roof_left.mesh = rl_mesh
	roof_left.position = Vector3(0, h + 2.5, 0)
	roof_left.rotation_degrees = Vector3(0, 0, -25)
	root.add_child(roof_left)
	
	# Right slope
	var roof_right = MeshInstance3D.new()
	var rr_mesh = BoxMesh.new()
	rr_mesh.size = Vector3(roof_width/2.0, roof_thickness, roof_depth)
	rr_mesh.material = roof_mat
	roof_right.mesh = rr_mesh
	roof_right.position = Vector3(0, h + 2.5, 0)
	roof_right.rotation_degrees = Vector3(0, 0, 25)
	root.add_child(roof_right)
	
	# Windows (small darker rectangles on the front face)
	var window_mat = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.2, 0.25, 0.4)
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var window_count = randi() % 3 + 1
	for wi in range(window_count):
		var wy = h * 0.3 + wi * h * 0.3
		var window = MeshInstance3D.new()
		var win_mesh = BoxMesh.new()
		win_mesh.size = Vector3(0.1, 1.2, 0.9)
		win_mesh.material = window_mat
		window.mesh = win_mesh
		window.position = Vector3(-w/2.0 - 0.05, wy, d * 0.15)
		root.add_child(window)
	
	return root


func _create_church(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var w = 8.0
	var d = 12.0
	var h = 16.0
	
	# Main building
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.8, 0.75, 0.6)
	wall_mat.roughness = 0.8
	wall_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var walls = MeshInstance3D.new()
	var wall_mesh = BoxMesh.new()
	wall_mesh.size = Vector3(w, h, d)
	wall_mesh.material = wall_mat
	walls.mesh = wall_mesh
	walls.position = Vector3(0, h/2.0, 0)
	root.add_child(walls)
	
	# Bell tower
	var tower = MeshInstance3D.new()
	var tower_mesh = BoxMesh.new()
	tower_mesh.size = Vector3(3, h * 1.3, 3)
	tower_mesh.material = wall_mat
	tower.mesh = tower_mesh
	tower.position = Vector3(0, h * 1.3 / 2.0, -d/2.0 - 1.5)
	root.add_child(tower)
	
	# Cross on top
	var cross_mat = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(0.3, 0.2, 0.1)
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var cross_v = MeshInstance3D.new()
	var cv_mesh = BoxMesh.new()
	cv_mesh.size = Vector3(0.2, 3, 0.3)
	cv_mesh.material = cross_mat
	cross_v.mesh = cv_mesh
	cross_v.position = Vector3(0, h * 1.3 + 1.5, -d/2.0 - 1.5)
	root.add_child(cross_v)
	
	var cross_h = MeshInstance3D.new()
	var ch_mesh = BoxMesh.new()
	ch_mesh.size = Vector3(1.5, 0.2, 0.3)
	ch_mesh.material = cross_mat
	cross_h.mesh = ch_mesh
	cross_h.position = Vector3(0, h * 1.3 + 2.5, -d/2.0 - 1.5)
	root.add_child(cross_h)
	
	return root


# === RAILWAY BRIDGE + TRAIN ===
func create_bridge_and_train(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.name = "BridgeAndTrain"
	root.position = pos
	
	# Bridge pillars
	var pillar_mat = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.5, 0.45, 0.4)
	pillar_mat.roughness = 0.9
	pillar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var bridge_length = 60.0
	var bridge_width = 6.0
	var bridge_height = 12.0
	
	# Track bed
	var track_mat = StandardMaterial3D.new()
	track_mat.albedo_color = Color(0.3, 0.25, 0.2)
	track_mat.roughness = 0.8
	track_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var track = MeshInstance3D.new()
	var track_mesh = BoxMesh.new()
	track_mesh.size = Vector3(bridge_width, 1.0, bridge_length)
	track_mesh.material = track_mat
	track.mesh = track_mesh
	track.position = Vector3(0, bridge_height, 0)
	root.add_child(track)
	
	# Pillars
	for x in [-12, 0, 12]:
		var pillar = MeshInstance3D.new()
		var pillar_mesh = BoxMesh.new()
		pillar_mesh.size = Vector3(2, bridge_height - 1, 2)
		pillar_mesh.material = pillar_mat
		pillar.mesh = pillar_mesh
		pillar.position = Vector3(x, (bridge_height - 1) / 2.0, 0)
		root.add_child(pillar)
	
	# Train engine
	var train_engine = _create_train_engine(Vector3(0, bridge_height + 3, 12))
	root.add_child(train_engine)
	
	# Train cars
	for i in range(3):
		var car = _create_train_car(Vector3(0, bridge_height + 2.5, 12 + (i + 1) * 10))
		root.add_child(car)
	
	# Bridge as StaticBody for collision
	var bridge_body = StaticBody3D.new()
	bridge_body.name = "BridgeBody"
	var bridge_shape = CollisionShape3D.new()
	var bridge_box = BoxShape3D.new()
	bridge_box.size = Vector3(bridge_width, bridge_height + 2, bridge_length)
	bridge_shape.shape = bridge_box
	bridge_body.add_child(bridge_shape)
	bridge_body.position = Vector3(0, bridge_height/2.0, 0)
	root.add_child(bridge_body)
	
	return root


func _create_train_engine(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var steam_color = Color(0.15, 0.15, 0.18)
	var accent_color = Color(0.6, 0.15, 0.1)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = steam_color
	mat.roughness = 0.5
	mat.metallic = 0.4
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Body
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(3.5, 3, 8)
	body_mesh.material = mat
	body.mesh = body_mesh
	root.add_child(body)
	
	# Cabin
	var cabin_mat = StandardMaterial3D.new()
	cabin_mat.albedo_color = accent_color
	cabin_mat.roughness = 0.5
	cabin_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var cabin = MeshInstance3D.new()
	var cabin_mesh = BoxMesh.new()
	cabin_mesh.size = Vector3(3.5, 2, 3)
	cabin_mesh.material = cabin_mat
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 2.5, -2.5)
	root.add_child(cabin)
	
	# Smokestack
	var stack = MeshInstance3D.new()
	var stack_mesh = BoxMesh.new()
	stack_mesh.size = Vector3(1, 2, 1)
	stack_mesh.material = mat
	stack.mesh = stack_mesh
	stack.position = Vector3(0, 3.5, 2)
	root.add_child(stack)
	
	# Wheels
	var wheel_mat = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.1, 0.1, 0.1)
	wheel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	for wx in [-1.2, 1.2]:
		for wz in [-2.5, 0, 2.5]:
			var wheel = MeshInstance3D.new()
			var wheel_mesh = BoxMesh.new()
			wheel_mesh.size = Vector3(0.3, 1.2, 1.2)
			wheel_mesh.material = wheel_mat
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(wx, -1.0, wz)
			root.add_child(wheel)
	
	return root


func _create_train_car(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var car_color = Color(0.2, 0.18, 0.15)
	var canvas_color = Color(0.35, 0.3, 0.2)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = car_color
	mat.roughness = 0.6
	mat.metallic = 0.3
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Box car body
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(3, 3.5, 8)
	body_mesh.material = mat
	body.mesh = body_mesh
	root.add_child(body)
	
	# Canvas top
	var canvas_mat = StandardMaterial3D.new()
	canvas_mat.albedo_color = canvas_color
	canvas_mat.roughness = 0.9
	canvas_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var top = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(2.8, 1.5, 7.5)
	top_mesh.material = canvas_mat
	top.mesh = top_mesh
	top.position = Vector3(0, 2.5, 0)
	root.add_child(top)
	
	# Wheels
	var wheel_mat = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.1, 0.1, 0.1)
	wheel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	for wx in [-1.2, 1.2]:
		for wz in [-2.5, 2.5]:
			var wheel = MeshInstance3D.new()
			var wheel_mesh = BoxMesh.new()
			wheel_mesh.size = Vector3(0.3, 1.0, 1.0)
			wheel_mesh.material = wheel_mat
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(wx, -1.2, wz)
			root.add_child(wheel)
	
	return root


# === FLAK TOWER (Refined) ===
func create_flak_tower(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	# Base - concrete bunker
	var base_mat = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.45, 0.42, 0.4)
	base_mat.roughness = 0.9
	base_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(5, 1.5, 5)
	base_mesh.material = base_mat
	base.mesh = base_mesh
	base.position = Vector3(0, 0.75, 0)
	root.add_child(base)
	
	# Gun platform
	var platform_mat = StandardMaterial3D.new()
	platform_mat.albedo_color = Color(0.35, 0.33, 0.3)
	platform_mat.roughness = 0.7
	platform_mat.metallic = 0.3
	platform_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var platform = MeshInstance3D.new()
	var platform_mesh = BoxMesh.new()
	platform_mesh.size = Vector3(3, 0.5, 3)
	platform_mesh.material = platform_mat
	platform.mesh = platform_mesh
	platform.position = Vector3(0, 2.5, 0)
	root.add_child(platform)
	
	# Gun barrel
	var barrel_mat = StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.15, 0.15, 0.18)
	barrel_mat.roughness = 0.3
	barrel_mat.metallic = 0.8
	barrel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var barrel = MeshInstance3D.new()
	var barrel_mesh = BoxMesh.new()
	barrel_mesh.size = Vector3(0.4, 0.4, 6)
	barrel_mesh.material = barrel_mat
	barrel.mesh = barrel_mesh
	barrel.position = Vector3(0, 3.5, 3.5)
	barrel.rotation_degrees = Vector3(-45, 0, 0)
	root.add_child(barrel)
	
	# Shield plate
	var shield_mat = StandardMaterial3D.new()
	shield_mat.albedo_color = Color(0.2, 0.22, 0.2)
	shield_mat.roughness = 0.5
	shield_mat.metallic = 0.5
	shield_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var shield = MeshInstance3D.new()
	var shield_mesh = BoxMesh.new()
	shield_mesh.size = Vector3(3.5, 2.5, 0.3)
	shield_mesh.material = shield_mat
	shield.mesh = shield_mesh
	shield.position = Vector3(0, 3.0, 1.5)
	root.add_child(shield)
	
	return root


# === DESTROYABLE TARGET: AMMO DUMP ===
func create_ammo_dump(pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.position = pos
	
	var crate_mat = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.35, 0.28, 0.18)
	crate_mat.roughness = 0.8
	crate_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Stack of ammo crates
	for i in range(3):
		var crate = MeshInstance3D.new()
		var crate_mesh = BoxMesh.new()
		crate_mesh.size = Vector3(2, 1, 1.5)
		crate_mesh.material = crate_mat
		crate.mesh = crate_mesh
		crate.position = Vector3(randf_range(-1, 1), i * 1.1 + 0.5, randf_range(-1, 1))
		crate.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		root.add_child(crate)
	
	return root
