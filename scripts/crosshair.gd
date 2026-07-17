extends Control

var locked: bool = false
var locked_color: Color = Color(1.0, 0.35, 0.1, 0.9)  # Amber/orange when target locked
var normal_color: Color = Color(0.2, 1.0, 0.2, 0.8)   # Green neon default

func set_locked(p_locked: bool) -> void:
	if locked != p_locked:
		locked = p_locked
		queue_redraw()

func _draw() -> void:
	var color = locked_color if locked else normal_color
	var length = 14.0
	var thickness = 2.0
	var offset = 6.0

	# Lock ring
	if locked:
		draw_arc(Vector2.ZERO, length + offset + 8, 0, TAU, 32, Color(locked_color, 0.4), 1.5)

	# Horizontal Left
	draw_line(Vector2(-length - offset, 0), Vector2(-offset, 0), color, thickness)
	# Horizontal Right
	draw_line(Vector2(offset, 0), Vector2(length + offset, 0), color, thickness)
	# Vertical Up
	draw_line(Vector2(0, -length - offset), Vector2(0, -offset), color, thickness)
	# Vertical Down
	draw_line(Vector2(0, offset), Vector2(0, length + offset), color, thickness)

	# Center dot
	draw_circle(Vector2.ZERO, 1.5, color)
