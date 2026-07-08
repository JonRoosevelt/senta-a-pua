# mission_piave_final.gd - Scene setup only (assets are in .tscn)
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_setup_environment()
	print("[Piave Final] Ready. All assets in scene editor.")

func _setup_environment() -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_color = Color(0.5, 0.45, 0.38)
	env.ambient_light_energy = 1.2
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.fog_enabled = true
	env.fog_mode = 1
	env.fog_density = 0.004
	env.fog_light_color = Color(0.85, 0.72, 0.52)
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.45, 0.6, 0.78)
	sky_mat.sky_horizon_color = Color(0.82, 0.68, 0.48)
	sky_mat.ground_horizon_color = Color(0.6, 0.48, 0.32)
	sky_mat.ground_bottom_color = Color(0.45, 0.35, 0.22)
	sky.sky_material = sky_mat
	env.sky = sky
	
	$WorldEnvironment.environment = env
