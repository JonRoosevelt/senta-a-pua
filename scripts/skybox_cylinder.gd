# skybox_cylinder.gd - Large cylinder around the map with panorama texture
extends Node3D

func create_cylinder(radius: float = 800.0, height: float = 400.0, texture_path: String = "") -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show inside
	mat.albedo_color = Color(0.65, 0.75, 0.85)  # Fallback color (sky blue)
	
	if texture_path != "" and ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, height / 2.0, 0)
	add_child(mi)
	
	print("[Skybox] Cylinder created: radius=", radius, " height=", height)
