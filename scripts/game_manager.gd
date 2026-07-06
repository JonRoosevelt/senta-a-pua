extends Node

var pilots: Array = [
	"Ten. Rui Moreira Lima",
	"Cap. Joel Miranda",
	"Ten. Alberto Torres",
	"Ten. Danilo Moura",
	"Cap. Newton Lagares",
	"Ten. Josino Maia"
]
var current_pilot_index: int = 0
var dead_pilots: Array = []
var active_enemies_count: int = 0
var score: int = 0

func get_current_pilot() -> String:
	if current_pilot_index < pilots.size():
		return pilots[current_pilot_index]
	return "Piloto Substituto"

func kill_current_pilot() -> void:
	var dead_pilot = get_current_pilot()
	if not dead_pilot in dead_pilots:
		dead_pilots.append(dead_pilot)
	current_pilot_index += 1

func is_campaign_over() -> bool:
	return current_pilot_index >= pilots.size()

func reset_campaign() -> void:
	current_pilot_index = 0
	dead_pilots.clear()
	score = 0
	active_enemies_count = 0

func register_enemy() -> void:
	active_enemies_count += 1

func enemy_destroyed() -> void:
	active_enemies_count -= 1
	score += 1
	
	# Verifica condição de vitória (todas as torres eliminadas)
	if active_enemies_count <= 0:
		# Aguarda um pequeno delay para a explosão terminar antes de mudar de cena
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
