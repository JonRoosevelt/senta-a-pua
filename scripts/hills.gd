# skybox_cylinder.gd - 360 panorama sphere
extends Node3D

@export var texture_path: String = "res://assets/terrain/layer_hills.png"
@export var radius: float = 800.0
@export var y_offset: float = 0.0

func _ready() -> void:
	if get_child_count() > 0:
		return
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius/3
	mesh.radial_segments = 32
	mesh.rings = 32
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, y_offset, 0)
	add_child(mi)
