# mission_piave_final.gd - Environment with PanoramaSky background
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
	env.fog_density = 0.003
	env.fog_light_color = Color(0.85, 0.72, 0.52)
	
	# PanoramaSky wraps the image around a sphere - 360° immersive background
	var sky = Sky.new()
	var panorama = PanoramaSkyMaterial.new()
	panorama.panorama = load("res://assets/terrain/po_valley_bg_360.png")
	sky.sky_material = panorama
	env.sky = sky
	
	$WorldEnvironment.environment = env
	
	var sun = $DirectionalLight3D
	sun.light_energy = 3.5
	sun.light_color = Color(1, 0.88, 0.68)
	sun.shadow_enabled = true
