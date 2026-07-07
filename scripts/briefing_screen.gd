extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/Title
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/Subtitle
@onready var briefing_label: Label = $CenterContainer/VBoxContainer/Briefing
@onready var objectives_label: Label = $CenterContainer/VBoxContainer/Objectives
@onready var pilot_label: Label = $CenterContainer/VBoxContainer/PilotLabel

func _ready() -> void:
	var mission = GameManager.get_current_mission()
	
	title_label.text = mission["title"]
	subtitle_label.text = mission["subtitle"]
	briefing_label.text = mission["briefing"]
	
	# Build objectives list
	var objective_text = "OBJETIVOS:\n"
	for obj in mission["objectives"]:
		objective_text += "  • " + obj["label"] + "\n"
	objectives_label.text = objective_text
	
	pilot_label.text = "PILOTO: " + GameManager.get_current_pilot().to_upper() + \
		" | PILOTOS RESTANTES: " + str(GameManager.get_remaining_pilots())

func _on_start_button_pressed() -> void:
	var mission = GameManager.get_current_mission()
	get_tree().change_scene_to_file(mission["scene"])

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
