# mission_piave.gd — Missão 1: Batismo de Fogo — Ponte do Piave
extends Node3D

# ── Mission State Machine ──────────────────────────────────────
enum MissionState {
	TAKEOFF,
	NAVIGATION,
	RECON,
	SUPPRESSION,
	ATTACK,
	REACTION,
	DISENGAGE,
	DEBRIEFING
}

var state: MissionState = MissionState.TAKEOFF

# ── Radio / HUD ───────────────────────────────────────────────
var radio_label: Label
var radio_tween: Tween
var radio_queue: Array[String] = []
var radio_active: bool = false

# ── Runway ────────────────────────────────────────────────────
const RUNWAY_LENGTH: float = 500.0
const RUNWAY_WIDTH: float = 40.0
const RUNWAY_POS: Vector3 = Vector3(0, 0.1, 300)  # South end of map
const RUNWAY_HEADING: float = 0.0  # North = -Z in Godot


func _ready() -> void:
	GameManager.start_mission()
	_cleanup()
	_setup_lighting()
	_create_runway()
	_setup_radio_hud()
	_position_player()
	_enter_state(MissionState.TAKEOFF)
	print("[Piave] Missão pronta — aguardando decolagem.")


# ═══════════════════════════════════════════════════════════════
# ── State Management ──────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════

func _enter_state(new_state: MissionState) -> void:
	state = new_state
	match state:
		MissionState.TAKEOFF:
			_radio("Senta a Púa, aqui Controle. Inteligência informa movimentação ferroviária inimiga sobre o Rio Piave. Sua missão é interromper esse tráfego.", 6.0)
		MissionState.NAVIGATION:
			_radio("Mantenha o rumo. O alvo deve estar a poucos minutos.", 4.0)
		# Future states will be filled in as we implement them


func advance_state() -> void:
	match state:
		MissionState.TAKEOFF:
			_enter_state(MissionState.NAVIGATION)
		# Future transitions


# ═══════════════════════════════════════════════════════════════
# ── Runway / Airbase ──────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════

func _create_runway() -> void:
	var runway_root = Node3D.new()
	runway_root.name = "Runway"
	
	# ── Asphalt strip ─────────────────────────────────────────
	var asphalt_mat = StandardMaterial3D.new()
	asphalt_mat.albedo_color = Color(0.18, 0.18, 0.20)
	asphalt_mat.roughness = 0.9
	
	var asphalt = MeshInstance3D.new()
	asphalt.name = "Asphalt"
	var asphalt_mesh = BoxMesh.new()
	asphalt_mesh.size = Vector3(RUNWAY_WIDTH, 0.2, RUNWAY_LENGTH)
	asphalt_mesh.material = asphalt_mat
	asphalt.mesh = asphalt_mesh
	asphalt.position = RUNWAY_POS + Vector3(0, 0, 0)
	runway_root.add_child(asphalt)
	
	# ── Center line (dashed white) ─────────────────────────────
	var line_mat = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.9, 0.9, 0.9)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.15, 0.15, 0.15)
	line_mat.emission_energy_multiplier = 0.5
	
	var dash_length = 8.0
	var gap_length = 4.0
	var half_runway = RUNWAY_LENGTH / 2.0
	var pos_z = -half_runway
	
	while pos_z < half_runway:
		var dash = MeshInstance3D.new()
		var dash_mesh = BoxMesh.new()
		dash_mesh.size = Vector3(0.6, 0.01, dash_length)
		dash_mesh.material = line_mat
		dash.mesh = dash_mesh
		dash.position = RUNWAY_POS + Vector3(0, 0.11, pos_z + dash_length / 2.0)
		runway_root.add_child(dash)
		pos_z += dash_length + gap_length
	
	# ── Edge lines ─────────────────────────────────────────────
	var edge_mat = StandardMaterial3D.new()
	edge_mat.albedo_color = Color(0.85, 0.85, 0.85)
	
	for side in [-1, 1]:
		var edge = MeshInstance3D.new()
		var edge_mesh = BoxMesh.new()
		edge_mesh.size = Vector3(0.4, 0.01, RUNWAY_LENGTH)
		edge_mesh.material = edge_mat
		edge.mesh = edge_mesh
		edge.position = RUNWAY_POS + Vector3(side * (RUNWAY_WIDTH / 2.0 - 1.5), 0.11, 0)
		runway_root.add_child(edge)
	
	# ── Ground collision for runway ───────────────────────────
	var runway_col = StaticBody3D.new()
	runway_col.name = "RunwayCollision"
	var col_shape = CollisionShape3D.new()
	col_shape.shape = BoxShape3D.new()
	col_shape.shape.size = Vector3(RUNWAY_WIDTH + 4, 0.4, RUNWAY_LENGTH + 4)
	runway_col.add_child(col_shape)
	runway_col.position = RUNWAY_POS
	runway_root.add_child(runway_col)
	
	add_child(runway_root)
	print("[Piave] Pista de decolagem criada em ", RUNWAY_POS)


# ── Player Positioning ────────────────────────────────────────

func _position_player() -> void:
	var player = get_node_or_null("Player")
	if not player:
		print("[Piave] ⚠ Player node not found!")
		return
	
	# Position at south end of runway, facing north
	player.global_position = Vector3(RUNWAY_POS.x, RUNWAY_POS.y + 1.5, RUNWAY_POS.z + RUNWAY_LENGTH / 2.0 - 10)
	player.rotation_degrees = Vector3(0, 180, 0)  # Face north (-Z)
	
	# Tell player we're in takeoff mode
	if player.has_method("set_takeoff_mode"):
		player.set_takeoff_mode(RUNWAY_POS.y)
	
	print("[Piave] Player posicionado na cabeceira da pista.")


# ═══════════════════════════════════════════════════════════════
# ── Radio / HUD Messages ──────────────────────────────────────
# ═══════════════════════════════════════════════════════════════

func _setup_radio_hud() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "RadioHUD"
	
	radio_label = Label.new()
	radio_label.name = "RadioLabel"
	radio_label.text = ""
	radio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	radio_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	radio_label.add_theme_font_size_override("font_size", 16)
	radio_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	
	# Position at bottom center of screen
	radio_label.anchor_left = 0.15
	radio_label.anchor_right = 0.85
	radio_label.anchor_bottom = 1.0
	radio_label.offset_bottom = -40
	
	# Shadow effect via a second label behind it
	var shadow = Label.new()
	shadow.name = "RadioShadow"
	shadow.text = ""
	shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shadow.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	shadow.add_theme_font_size_override("font_size", 16)
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.5))
	shadow.anchor_left = 0.15
	shadow.anchor_right = 0.85
	shadow.anchor_bottom = 1.0
	shadow.offset_bottom = -42
	shadow.offset_left = 2
	
	canvas.add_child(shadow)
	canvas.add_child(radio_label)
	add_child(canvas)
	
	# Connect label text changes to shadow
	radio_label.visibility_changed.connect(func(): shadow.visible = radio_label.visible)


func _radio(text: String, duration: float = 4.0) -> void:
	radio_queue.append(text)
	if not radio_active:
		_show_next_radio()


func _show_next_radio() -> void:
	if radio_queue.is_empty():
		radio_active = false
		return
	
	radio_active = true
	var text = radio_queue.pop_front()
	
	# Show radio prefix
	radio_label.text = "[RÁDIO] " + text
	radio_label.modulate.a = 0.0
	radio_label.visible = true
	
	if radio_tween and radio_tween.is_valid():
		radio_tween.kill()
	
	radio_tween = create_tween()
	radio_tween.set_parallel(false)
	# Fade in
	radio_tween.tween_property(radio_label, "modulate:a", 1.0, 0.3)
	# Hold
	radio_tween.tween_interval(duration)
	# Fade out
	radio_tween.tween_property(radio_label, "modulate:a", 0.0, 0.5)
	radio_tween.tween_callback(_show_next_radio)


# ═══════════════════════════════════════════════════════════════
# ── Process Loop ──────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════

func _process(_delta: float) -> void:
	# Check for state transitions
	match state:
		MissionState.TAKEOFF:
			_check_takeoff_complete()


func _check_takeoff_complete() -> void:
	var player = get_node_or_null("Player")
	if not player:
		return
	
	# Player is airborne and has some altitude — takeoff complete
	if player.has_method("is_airborne") and player.is_airborne():
		if player.global_position.y > RUNWAY_POS.y + 15.0:
			advance_state()


# ═══════════════════════════════════════════════════════════════
# ── Lighting & Environment ─────────────────────────────────────
# ═══════════════════════════════════════════════════════════════

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
