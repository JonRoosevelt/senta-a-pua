# hills.gd - Simple horizon strip (PlaneMesh, not cylinder)
extends Node3D

@export var texture_path: String = "res://assets/terrain/layer_hills.png"
@export var distance: float = 500.0
@export var strip_height: float = 200.0
@export var strip_width: float = 2000.0
@export var y_offset: float = 10.0

func _ready() -> void:
	if get_child_count() > 0:
		return
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(strip_width, strip_height)
	mesh.material = mat
	mesh.orientation = PlaneMesh.FACE_Z
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, y_offset + strip_height / 2.0, -distance)
	add_child(mi)
