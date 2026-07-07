extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/Title
@onready var stats_label: Label = $CenterContainer/VBoxContainer/Stats
@onready var next_button: Button = $CenterContainer/VBoxContainer/NextButton

func _ready() -> void:
	title_label.text = "MISSÃO CUMPRIDA!"
	
	var mission = GameManager.get_current_mission()
	var next_index = GameManager.current_mission_index + 1
	
	if next_index < GameManager.missions.size():
		var next_mission = GameManager.missions[next_index]
		stats_label.text = "Pilotos perdidos nesta missão: %d\nPróxima: %s" % [GameManager.pilots_lost_this_mission, next_mission["title"]]
		next_button.text = "PRÓXIMA MISSÃO"
	else:
		stats_label.text = "Pilotos perdidos nesta missão: %d" % GameManager.pilots_lost_this_mission
		next_button.text = "CONTINUAR"

func _on_next_button_pressed() -> void:
	var next_index = GameManager.current_mission_index + 1
	
	if next_index < GameManager.missions.size():
		GameManager.complete_mission()
		get_tree().change_scene_to_file("res://scenes/briefing.tscn")
	else:
		# Campaign complete
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
