# mission_piave_final.gd - Environment with Po Valley atmospheric sky
extends Node3D

func _ready() -> void:
	GameManager.start_mission()
	_setup_environment()
	print("[Piave] Ready. Edit assets in Scene panel.")

func _setup_environment() -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	
	# Warmer, richer ambient light
	env.ambient_light_color = Color(0.55, 0.50, 0.42)
	env.ambient_light_energy = 1.4
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	
	# Subtle glow for sunlight on edges
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_strength = 0.6
	env.glow_bloom = 0.15
	
	# Fog creates depth - denser at distance, Po Valley haze
	env.fog_enabled = true
	env.fog_mode = 1
	env.fog_density = 0.003
	env.fog_light_color = Color(0.88, 0.78, 0.58)
	env.fog_aerial_perspective = 0.7
	env.fog_height = 80.0
	env.fog_height_density = 0.002
	
	# Procedural sky with autumn Po Valley colors
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	# Upper sky - soft autumn blue
	sky_mat.sky_top_color = Color(0.42, 0.55, 0.72)
	# Horizon - warm golden haze over fields
	sky_mat.sky_horizon_color = Color(0.85, 0.72, 0.48)
	# Ground - green/brown fields
	sky_mat.ground_horizon_color = Color(0.48, 0.55, 0.32)
	sky_mat.ground_bottom_color = Color(0.35, 0.42, 0.25)
	# Sun settings
	sky_mat.sun_angle_max = 80.0
	sky_mat.sun_curve = 0.12
	sky.sky_material = sky_mat
	env.sky = sky
	
	$WorldEnvironment.environment = env
	
	# Warm directional light (autumn afternoon)
	var sun = $DirectionalLight3D
	sun.light_energy = 3.5
	sun.light_color = Color(1.0, 0.88, 0.68)
	sun.shadow_enabled = true
