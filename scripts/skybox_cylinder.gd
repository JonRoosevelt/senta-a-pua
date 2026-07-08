# skybox_cylinder.gd - Flexible background system
# Works with both flat backdrop images and 360° panoramas
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_bg.png"
@export var mode: String = "flat"  # "flat" or "cylinder"
@export var distance: float = 700.0
@export var width: float = 2000.0
@export var height: float = 800.0

func _ready() -> void:
	if mode == "cylinder":
		_create_cylinder()
	else:
		_create_flat_backdrop()

func _create_flat_backdrop() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
		print("[Skybox] Loaded texture: ", texture_path)
	else:
		mat.albedo_color = Color(0.6, 0.7, 0.85)
		print("[Skybox] Texture not found, using fallback color")
	
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(width, height)
	mesh.material = mat
	mesh.orientation = PlaneMesh.FACE_Z  # Face toward player
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, height / 2.0, -distance)
	add_child(mi)
	print("[Skybox] Flat backdrop at Z=", -distance)

func _create_cylinder() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = distance
	mesh.bottom_radius = distance
	mesh.height = height
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, height / 2.0, 0)
	add_child(mi)
	print("[Skybox] 360° cylinder radius=", distance)
