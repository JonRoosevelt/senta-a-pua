# sky_layer.gd - Cilindro ou esfera para camada de background
extends Node3D

@export var texture_path: String = ""
@export var radius: float = 500.0
@export var height: float = 200.0
@export var y_offset: float = 0.0
@export var mode: String = "cylinder"  # "cylinder" or "sphere"

func _ready() -> void:
	if get_child_count() > 0:
		return
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if texture_path != "" and ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
	
	var mesh: Mesh
	if mode == "sphere":
		var s = SphereMesh.new()
		s.radius = radius
		s.height = radius * 2
		s.radial_segments = 64
		s.rings = 32
		mesh = s
	else:
		var c = CylinderMesh.new()
		c.top_radius = radius
		c.bottom_radius = radius
		c.height = height
		c.radial_segments = 64
		mesh = c
	
	mesh.material = mat
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, y_offset + height / 2.0, 0)
	add_child(mi)
