# hills.gd - Cylinder layer for mid-ground hills (horizon wrap, not full sky)
extends Node3D

@export var texture_path: String = "res://assets/terrain/layer_hills.png"
@export var radius: float = 600.0
@export var height: float = 250.0
@export var y_offset: float = 20.0

func _ready() -> void:
	if get_child_count() > 0:
		return
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 64
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, y_offset + height / 2.0, 0)
	add_child(mi)
