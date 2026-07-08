# skybox_cylinder.gd - Simple horizon backdrop
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_bg.png"
@export var distance: float = 600.0
@export var width: float = 2400.0
@export var height: float = 400.0
@export var y_offset: float = 50.0

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	# Single large plane across the horizon
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(width, height)
	mesh.material = mat
	mesh.orientation = PlaneMesh.FACE_Z
	
	var mi = MeshInstance3D.new()
	mi.name = "HorizonBackdrop"
	mi.mesh = mesh
	mi.position = Vector3(0, y_offset + height / 2.0, -distance)
	add_child(mi)
	
	print("[Skybox] Horizon plane: ", width, "x", height, " at Z=", -distance)
