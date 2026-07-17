# main_environment.gd - Main scene Po Valley setup (lightweight)
extends Node3D

func _ready() -> void:
	_build_environment()

func _build_environment() -> void:
	# Remove old non-essential nodes
	for name in ["Ground", "Mountains", "EnemyTowers", "EnemyFighters"]:
		var node = get_node_or_null(name)
		if node:
			node.queue_free()
	
	# Build Po Valley
	var builder = load("res://scripts/po_valley_builder.gd").new()
	builder.name = "PoValleyEnvironment"
	builder.build_scene()
	add_child(builder)
	move_child(builder, 1)
	
	print("[Main] Po Valley environment populated.")
