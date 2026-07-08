# skybox_cylinder.gd - Simple curved backdrop (single mesh, no seams)
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_bg_360.png"
@export var radius: float = 800.0
@export var height: float = 500.0
@export var arc_degrees: float = 180.0

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
		print("[Skybox] Loaded: ", texture_path)
	else:
		mat.albedo_color = Color(0.55, 0.65, 0.80)
	
	# Create a CylinderMesh (seamless curved surface)
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 64  # Smooth curve
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.name = "SkyboxMesh"
	mi.mesh = mesh
	mi.position = Vector3(0, height / 2.0, 0)
	add_child(mi)
	
	print("[Skybox] Cylinder radius=", radius, " height=", height)
