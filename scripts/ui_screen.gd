extends Control

func _on_start_button_pressed() -> void:
	GameManager.start_campaign()
	# Go to briefing screen for first mission
	get_tree().change_scene_to_file("res://scenes/briefing.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
