# mission_piave_final.gd - Clean procedural sky + optional skysphere
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_setup_environment()
	print("[Piave] Ready.")

func _setup_environment() -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_color = Color(0.5, 0.45, 0.38)
	env.ambient_light_energy = 1.2
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.fog_enabled = true
	env.fog_mode = 1
	env.fog_density = 0.006
	env.fog_light_color = Color(0.88, 0.78, 0.58)
	env.fog_aerial_perspective = 0.8
	env.fog_height = 60.0
	env.fog_height_density = 0.005
	
	# Procedural sky
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.42, 0.55, 0.72)
	sky_mat.sky_horizon_color = Color(0.85, 0.72, 0.48)
	sky_mat.ground_horizon_color = Color(0.48, 0.55, 0.32)
	sky_mat.ground_bottom_color = Color(0.35, 0.42, 0.25)
	sky.sky_material = sky_mat
	env.sky = sky
	
	$WorldEnvironment.environment = env
	
	var sun = $DirectionalLight3D
	sun.light_energy = 3.5
	sun.light_color = Color(1, 0.88, 0.68)
	sun.shadow_enabled = true
