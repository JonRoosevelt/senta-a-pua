# boundary_guard.gd - Keeps player within mission area
# Attach to Player node
extends Node

@export var boundary_radius: float = 600.0  # Max distance from origin
@export var warning_radius: float = 450.0   # When to show warning
@export var max_altitude: float = 200.0     # Ceiling
@export var min_altitude: float = 5.0       # Floor (above ground collision)

var warning_label: Label
var warning_timer: float = 0.0

func _ready() -> void:
	# Create warning HUD
	warning_label = Label.new()
	warning_label.text = ""
	warning_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	warning_label.add_theme_font_size_override("font_size", 24)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.anchors_preset = Control.PRESET_CENTER_WIDE
	warning_label.visible = false
	
	var canvas = CanvasLayer.new()
	canvas.add_child(warning_label)
	get_parent().add_child(canvas)

func _process(delta: float) -> void:
	var player = get_parent() as Node3D
	if not player:
		return
	
	var pos = player.global_position
	var dist_from_center = Vector2(pos.x, pos.z).length()
	var is_out_of_bounds = dist_from_center > boundary_radius or pos.y > max_altitude or pos.y < min_altitude
	var is_near_boundary = dist_from_center > warning_radius and not is_out_of_bounds
	
	if is_out_of_bounds:
		warning_label.text = "⚠ RETORNE À ÁREA DE MISSÃO ⚠"
		warning_label.visible = true
		warning_timer += delta
		
		# After 5 seconds out of bounds, crash
		if warning_timer > 5.0:
			if player.has_method("take_damage"):
				player.take_damage(100)
	elif is_near_boundary:
		warning_label.text = "⚠ Aproximando-se do limite da missão"
		warning_label.visible = true
		warning_timer = 0.0
	else:
		warning_label.visible = false
		warning_timer = 0.0
