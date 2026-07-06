extends Control

# Este script controla os botões nos menus do jogo (Menu Inicial, Vitória, Game Over)

func _on_start_button_pressed() -> void:
	# Reinicia o estado da campanha e inicia o jogo
	GameManager.reset_campaign()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_button_pressed() -> void:
	# Volta para o menu principal
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_button_pressed() -> void:
	# Sai do jogo
	get_tree().quit()
