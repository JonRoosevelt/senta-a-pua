# skybox_layers.gd - Multi-layer parallax horizon background
extends Node3D

# Each layer: texture, distance (Z), height, y_offset
@export var layers: Array[Dictionary] = [
	{"texture": "res://assets/terrain/layer_alps.png", "distance": 800, "height": 300, "y": 100},
	{"texture": "res://assets/terrain/layer_hills.png", "distance": 500, "height": 200, "y": 40},
	{"texture": "res://assets/terrain/layer_fields.png", "distance": 250, "height": 150, "y": 10},
]

func _ready() -> void:
	for layer in layers:
		_create_layer(layer["texture"], layer["distance"], layer["height"], layer["y"])

func _create_layer(tex_path: String, z_dist: float, h: float, y_off: float) -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if ResourceLoader.exists(tex_path):
		mat.albedo_texture = load(tex_path)
	else:
		# Fallback solid color so we can see the layer even without texture
		var fallback_colors = [Color(0.5, 0.6, 0.8), Color(0.4, 0.5, 0.3), Color(0.6, 0.55, 0.3)]
		var idx = layers.find({"texture": tex_path, "distance": z_dist, "height": h, "y": y_off})
		if idx >= 0 and idx < fallback_colors.size():
			mat.albedo_color = fallback_colors[idx]
	
	# Wide plane to span the view
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(3000, h)
	mesh.material = mat
	mesh.orientation = PlaneMesh.FACE_Z
	
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, y_off + h / 2.0, -z_dist)
	add_child(mi)
	
	print("[Layer] ", tex_path, " at Z=", -z_dist)
