# skybox_cylinder.gd - Curved panorama backdrop
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_bg.png"
@export var distance: float = 700.0
@export var width: float = 2800.0
@export var height: float = 900.0
@export var segments: int = 7
@export var fade_color: Color = Color(0.65, 0.75, 0.85, 1)

func _ready() -> void:
	_create_curved_backdrop()

func _create_curved_backdrop() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
		# Slight transparency for atmospheric blending
		mat.albedo_color = Color(1, 1, 1, 0.75)
		print("[Skybox] Loaded: ", texture_path)
	else:
		mat.albedo_color = Color(0.6, 0.7, 0.85, 0.5)
		print("[Skybox] Texture not found, using fallback")
	
	var seg_width = width / segments
	
	for i in range(segments):
		# Curve segments in a gentle arc
		var angle = deg_to_rad(-45 + 90 * float(i) / float(segments - 1))
		var x = sin(angle) * distance
		var z = -cos(angle) * distance
		
		var mesh = PlaneMesh.new()
		mesh.size = Vector2(seg_width + 2, height)
		mesh.material = mat.duplicate()
		mesh.orientation = PlaneMesh.FACE_Z
		
		var mi = MeshInstance3D.new()
		mi.mesh = mesh
		mi.position = Vector3(x, height / 2.0, z)
		mi.look_at(Vector3(0, height / 2.0, 0), Vector3.UP)
		add_child(mi)
	
	print("[Skybox] Curved backdrop with ", segments, " segments at distance ", distance)
