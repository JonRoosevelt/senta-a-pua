# skybox_cylinder.gd - Proper 360 panorama cylinder with correct UVs
extends Node3D

@export var texture_path: String = "res://assets/terrain/po_valley_bg_360.png"
@export var radius: float = 700.0
@export var height: float = 400.0
@export var segments: int = 64

func _ready() -> void:
	_create_panorama_cylinder()

func _create_panorama_cylinder() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path)
		print("[Panorama] Loaded: ", texture_path)
	
	# Build cylinder with proper UVs using SurfaceTool
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(segments):
		var angle0 = TAU * float(i) / segments
		var angle1 = TAU * float(i + 1) / segments
		
		var u0 = float(i) / segments
		var u1 = float(i + 1) / segments
		
		# Bottom vertices
		var x0_b = cos(angle0) * radius
		var z0_b = sin(angle0) * radius
		var x1_b = cos(angle1) * radius
		var z1_b = sin(angle1) * radius
		
		# Top vertices
		var x0_t = cos(angle0) * radius
		var z0_t = sin(angle0) * radius
		var x1_t = cos(angle1) * radius
		var z1_t = sin(angle1) * radius
		
		# Triangle 1 (bottom-left, bottom-right, top-left)
		st.set_uv(Vector2(u0, 1.0))
		st.add_vertex(Vector3(x0_b, 0, z0_b))
		st.set_uv(Vector2(u1, 1.0))
		st.add_vertex(Vector3(x1_b, 0, z1_b))
		st.set_uv(Vector2(u0, 0.0))
		st.add_vertex(Vector3(x0_t, height, z0_t))
		
		# Triangle 2 (bottom-right, top-right, top-left)
		st.set_uv(Vector2(u1, 1.0))
		st.add_vertex(Vector3(x1_b, 0, z1_b))
		st.set_uv(Vector2(u1, 0.0))
		st.add_vertex(Vector3(x1_t, height, z1_t))
		st.set_uv(Vector2(u0, 0.0))
		st.add_vertex(Vector3(x0_t, height, z0_t))
	
	st.generate_normals()
	
	var mi = MeshInstance3D.new()
	mi.name = "PanoramaCylinder"
	mi.mesh = st.commit()
	mi.mesh.surface_set_material(0, mat)
	mi.position = Vector3(0, height / 2.0, 0)
	add_child(mi)
	
	print("[Panorama] Cylinder built: ", segments, " segments, radius=", radius)
