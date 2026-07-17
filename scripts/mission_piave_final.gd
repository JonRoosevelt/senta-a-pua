# mission_piave_final.gd - Po Valley final mission
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_cleanup()
	_setup_lighting()
	print("[Piave] Ready.")

func _cleanup() -> void:
	for name in ["Terrain", "River", "Alps", "LayerHills", "SkySphere", "Grass_1"]:
		var node = get_node_or_null(name)
		if node:
			node.queue_free()

func _setup_lighting() -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_color = Color(0.55, 0.48, 0.35)
	env.ambient_light_energy = 1.3
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.fog_enabled = true
	env.fog_mode = 1
	env.fog_density = 0.0008
	env.fog_light_color = Color(0.92, 0.78, 0.52)
	env.fog_aerial_perspective = 0.7
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.35, 0.48, 0.68)
	sky_mat.sky_horizon_color = Color(0.88, 0.68, 0.38)
	sky_mat.ground_horizon_color = Color(0.42, 0.52, 0.28)
	sky_mat.ground_bottom_color = Color(0.25, 0.35, 0.18)
	sky.sky_material = sky_mat
	env.sky = sky
	
	$WorldEnvironment.environment = env
	
	var sun = $DirectionalLight3D
	sun.light_energy = 3.5
	sun.light_color = Color(1.0, 0.85, 0.62)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 300.0
