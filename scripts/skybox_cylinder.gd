# skybox_cylinder.gd - Inverted sphere with panorama texture (works with any image)
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_pano.jpg"
@export var radius: float = 500.0

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show inside
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
		mat.albedo_color = Color(1, 1, 1, 1)
	
	# Sphere mesh
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 64
	mesh.rings = 32
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.name = "SkySphere"
	mi.mesh = mesh
	add_child(mi)
	
	print("[SkySphere] Radius=", radius, " texture=", texture_path)
