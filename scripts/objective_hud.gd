# objective_hud.gd - Painel de objetivos no canto superior direito
extends Control

@onready var obj_container: VBoxContainer = $ObjectivesPanel/VBoxContainer

func _ready() -> void:
	_refresh_objectives()
	# Atualiza a cada 0.5 segundos
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_refresh_objectives)
	add_child(timer)
	timer.start()

func _refresh_objectives() -> void:
	if not GameManager:
		return
	
	# Limpa objetivos antigos
	for child in obj_container.get_children():
		child.queue_free()
	
	# Adiciona cada objetivo
	var objectives = GameManager.get_objective_status()
	for obj in objectives:
		var label = Label.new()
		if obj["done"]:
			label.text = "✓ " + obj["label"]
			label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3, 1))
		else:
			label.text = "• %s [%d/%d]" % [obj["label"], obj["progress"], obj["target"]]
			label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
		label.add_theme_font_size_override("font_size", 12)
		obj_container.add_child(label)
