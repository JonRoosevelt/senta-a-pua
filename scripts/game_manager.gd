extends Node

# === Campaign Data ===

var pilots: Array = [
	"Ten. Rui Moreira Lima",
	"Cap. Joel Miranda",
	"Ten. Alberto Torres",
	"Ten. Danilo Moura",
	"Cap. Newton Lagares",
	"Ten. Josino Maia"
]

# === Mission 1: Batismo de Fogo — Ponte de Piave ===
var missions: Array = [
	{
		"id": "piave",
		"title": "Missão 1: Batismo de Fogo",
		"subtitle": "Novembro de 1944 — Rio Piave, Vêneto",
		"briefing": "Recém-chegados à Itália, o 1º GAvCa recebe sua primeira missão de combate real. Uma ponte ferroviária vital sobre o Rio Piave está sendo usada pelos alemães para mover suprimentos à Linha Gótica. O comando aliado ordena sua destruição imediata.\n\nA ponte é defendida por artilharia antiaérea e caças inimigos patrulham a área. A neblina matinal do outono italiano pode dificultar a visibilidade — use-a a seu favor.\n\nLembre-se: esta é a primeira impressão do Brasil na guerra aérea. Senta a Pua!",
		"scene": "res://scenes/missions/mission_piave.tscn",
		"objectives": [
			{"id": "pillar_1", "label": "Destruir pilar norte da ponte", "type": "bridge_pillar", "target": 1},
			{"id": "pillar_2", "label": "Destruir pilar central da ponte", "type": "bridge_pillar", "target": 1},
			{"id": "flak", "label": "Destruir 3 torres Flak", "type": "flak_tower", "target": 3},
			{"id": "fighters", "label": "Eliminar 2 caças inimigos", "type": "fighter", "target": 2},
		],
		# Enemy counts for scene spawning
		"enemy_fighters": 2,
		"enemy_towers": 3,
		"checkpoint_deaths": 3,  # deaths allowed before losing a pilot
	}
]

# === Campaign State ===

var current_pilot_index: int = 0
var dead_pilots: Array = []
var current_mission_index: int = 0
var score: int = 0
var pilots_lost_this_mission: int = 0
var mission_start_time: float = 0.0
var deaths_at_checkpoint: int = 0

# Objective tracking
var objective_progress: Dictionary = {}  # {"obj_id": current_count}
var objectives_completed: Array = []      # ["obj_id", ...]

# === Pilot Management ===

func get_current_pilot() -> String:
	if current_pilot_index < pilots.size():
		return pilots[current_pilot_index]
	return "Piloto Substituto"

func kill_current_pilot() -> void:
	var dead_pilot = get_current_pilot()
	if not dead_pilot in dead_pilots:
		dead_pilots.append(dead_pilot)
	pilots_lost_this_mission += 1
	current_pilot_index += 1

func is_campaign_over() -> bool:
	return current_pilot_index >= pilots.size()

# === Objective System ===

func init_objectives() -> void:
	objective_progress.clear()
	objectives_completed.clear()
	var mission = get_current_mission()
	for obj in mission.get("objectives", []):
		objective_progress[obj["id"]] = 0

func report_objective(objective_type: String) -> void:
	var mission = get_current_mission()
	for obj in mission.get("objectives", []):
		if obj["type"] == objective_type and not obj["id"] in objectives_completed:
			objective_progress[obj["id"]] = min(objective_progress.get(obj["id"], 0) + 1, obj["target"])
			score += 1
			
			if objective_progress[obj["id"]] >= obj["target"]:
				objectives_completed.append(obj["id"])
				_check_mission_complete()
			return

func _check_mission_complete() -> void:
	var mission = get_current_mission()
	var all_done = true
	for obj in mission.get("objectives", []):
		if not obj["id"] in objectives_completed:
			all_done = false
			break
	
	if all_done:
		await get_tree().create_timer(2.0).timeout
		if current_mission_index < missions.size() - 1:
			get_tree().change_scene_to_file("res://scenes/mission_complete.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/victory.tscn")

# === Checkpoint System ===

func checkpoint_death() -> bool:
	"""Returns true if pilot should be lost (too many deaths at checkpoint)"""
	var mission = get_current_mission()
	var max_deaths = mission.get("checkpoint_deaths", 3)
	deaths_at_checkpoint += 1
	if deaths_at_checkpoint >= max_deaths:
		kill_current_pilot()
		deaths_at_checkpoint = 0
		return true
	return false

func reset_checkpoint_deaths() -> void:
	deaths_at_checkpoint = 0

func save_checkpoint() -> void:
	# Save progress (objectives already stored in objective_progress/objectives_completed)
	deaths_at_checkpoint = 0
	print("[Checkpoint] Progresso salvo. Objetivos completados: ", objectives_completed)

# === Mission Management ===

func get_current_mission() -> Dictionary:
	if current_mission_index < missions.size():
		return missions[current_mission_index]
	return {}

func start_campaign() -> void:
	current_pilot_index = 0
	dead_pilots.clear()
	current_mission_index = 0
	score = 0

func start_mission() -> void:
	pilots_lost_this_mission = 0
	mission_start_time = Time.get_ticks_msec() / 1000.0
	deaths_at_checkpoint = 0
	init_objectives()

func complete_mission() -> void:
	current_mission_index += 1

# === Helpers ===

func get_remaining_pilots() -> int:
	return pilots.size() - current_pilot_index

func get_objective_status() -> Array:
	"""Returns array of {label, progress, target, done} for HUD"""
	var result = []
	var mission = get_current_mission()
	for obj in mission.get("objectives", []):
		result.append({
			"label": obj["label"],
			"progress": objective_progress.get(obj["id"], 0),
			"target": obj["target"],
			"done": obj["id"] in objectives_completed
		})
	return result
