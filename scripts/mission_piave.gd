# mission_piave.gd — Missão 1: Batismo de Fogo — Ponte do Piave
@tool
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
	DEBRIEFING,
}

const RUNWAY_POS: Vector3 = Vector3(0, 0.1, -300) # North end of map, facing south (away from mountains)
const RUNWAY_HEADING: float = 0.0 # North = -Z in Godot

# ── Runway ────────────────────────────────────────────────────
@export var runway_length: float = 800.0
@export var runway_width: float = 40.0

var state: MissionState = MissionState.TAKEOFF

# ── Radio / HUD ───────────────────────────────────────────────
var radio_label: Label
var radio_tween: Tween
var radio_queue: Array = []
var radio_active: bool = false

@export_tool_button("Generate All")
var generate_button = generate_scene


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	generate_scene()
	start_mission()


# ═══════════════════════════════════════════════════════════════
# ── Process Loop ──────────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
func _process(_delta: float) -> void:
	# Check for state transitions
	match state:
		MissionState.TAKEOFF:
			_check_takeoff_complete()


func generate_scene() -> void:
	clear_generated()
	_setup_runway()


func start_mission() -> void:
	_setup_radio_hud()
	_position_player()
	_enter_state(MissionState.TAKEOFF)
	print("[Piave] Missão pronta — aguardando decolagem.")


func advance_state() -> void:
	match state:
		MissionState.TAKEOFF:
			_enter_state(MissionState.NAVIGATION)
		# Future transitions


func clear_generated() -> void:
	var old = get_node_or_null("runaway")
	if old:
		old.queue_free()


# ═══════════════════════════════════════════════════════════════
# ── State Management ──────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
func _enter_state(new_state: MissionState) -> void:
	state = new_state
	match state:
		MissionState.TAKEOFF:
			_radio(
				"Senta a Púa, aqui Controle. Inteligência informa movimentação ferroviária inimiga sobre o Rio Piave. Sua missão é interromper esse tráfego.",
				6.0,
			)
		MissionState.NAVIGATION:
			_radio("Mantenha o rumo. O alvo deve estar a poucos minutos.", 4.0)
		# Future states will be filled in as we implement them


# ═══════════════════════════════════════════════════════════════
# ── Runway / Airbase ──────────────────────────────────────────
# ═══════════════════════════════════════════════════════════════
func _setup_runway() -> void:
	var runway_root = Node3D.new()
	runway_root.name = "Runway"

	# ── Asphalt strip ─────────────────────────────────────────
	var asphalt_mat = StandardMaterial3D.new()
	asphalt_mat.albedo_color = Color(0.18, 0.18, 0.20)
	asphalt_mat.roughness = 0.9

	var asphalt = MeshInstance3D.new()
	asphalt.name = "Asphalt"
	var asphalt_mesh = BoxMesh.new()
	asphalt_mesh.size = Vector3(runway_width, 0.2, runway_length)
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
	var half_runway = runway_length / 2.0
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
		edge_mesh.size = Vector3(0.4, 0.01, runway_length)
		edge_mesh.material = edge_mat
		edge.mesh = edge_mesh
		edge.position = RUNWAY_POS + Vector3(side * (runway_width / 2.0 - 1.5), 0.11, 0)
		runway_root.add_child(edge)

	# ── Ground collision for runway ───────────────────────────
	var runway_col = StaticBody3D.new()
	runway_col.name = "RunwayCollision"
	var col_shape = CollisionShape3D.new()
	col_shape.shape = BoxShape3D.new()
	col_shape.shape.size = Vector3(runway_width + 4, 0.4, runway_length + 4)
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

	# Position at north end of runway, facing south (away from mountains)
	player.global_position = Vector3(
		RUNWAY_POS.x,
		RUNWAY_POS.y + 1.5,
		RUNWAY_POS.z - runway_length / 2.0 + 10,
	)
	player.rotation_degrees = Vector3(0, 180, 0) # Face south (+Z), away from mountains

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
	radio_label.visibility_changed.connect(func():
			shadow.visible = radio_label.visible)


func _radio(text: String, duration: float = 4.0) -> void:
	radio_queue.append({ "text": text, "duration": duration })
	if not radio_active:
		_show_next_radio()


func _show_next_radio() -> void:
	if radio_queue.is_empty():
		radio_active = false
		return

	radio_active = true
	var entry = radio_queue.pop_front()
	var text: String = entry["text"]
	var hold_duration: float = entry["duration"]

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
	radio_tween.tween_interval(hold_duration)
	# Fade out
	radio_tween.tween_property(radio_label, "modulate:a", 0.0, 0.5)
	radio_tween.tween_callback(_show_next_radio)


func _check_takeoff_complete() -> void:
	var player = get_node_or_null("Player")
	if not player:
		return

	# Player is airborne and has some altitude — takeoff complete
	# Use get() to avoid placeholder instance errors with custom methods
	var airborne = player.get("is_on_ground") == false
	if airborne and player.global_position.y > RUNWAY_POS.y + 15.0:
		advance_state()
