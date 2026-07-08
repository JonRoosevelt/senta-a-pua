# skybox_cylinder.gd - Sky sphere (add as child of root scene, not player)
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_pano.jpg"
@export var radius: float = 800.0

func _ready() -> void:
	# Don't recreate if already has children (placed in editor)
	if get_child_count() > 0:
		print("[SkySphere] Already has mesh, skipping creation")
		return
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 64
	mesh.rings = 32
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.name = "SkySphereMesh"
	mi.mesh = mesh
	mi.position = Vector3(0, -100, 0)  # Dip below ground so horizon blends
	add_child(mi)
	
	print("[SkySphere] Created sphere radius=", radius)
