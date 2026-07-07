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

# Mission definitions
var missions: Array = [
	{
		"id": "patrol",
		"title": "Missão 1: Patrulha de Combate",
		"subtitle": "Novembro de 1944 — Vale do Pó, Itália",
		"briefing": "O 1º GAvCa acaba de chegar ao teatro de operações italiano. Sua primeira missão é uma patrulha de combate sobre o Vale do Pó. Familiarize-se com o P-47 Thunderbolt e elimine os caças inimigos que patrulham a região. Mantenha-se atento — a Flak alemã está posicionada nas colinas.",
		"scene": "res://scenes/missions/mission_patrol.tscn",
		"objectives": ["Eliminar 2 caças inimigos", "Destruir 2 torres Flak"],
		"enemy_fighters": 2,
		"enemy_towers": 2
	},
	{
		"id": "interdiction",
		"title": "Missão 2: Interdição de Suprimentos",
		"subtitle": "Dezembro de 1944 — Vale do Pó, Itália",
		"briefing": "A inteligência aliada identificou um trem de suprimentos alemão cruzando uma ponte ferroviária estratégica. Sua missão é interditar essa linha de abastecimento. Destrua a ponte, o trem e as defesas antiaéreas na área. Cuidado com os caças inimigos que protegem o comboio.",
		"scene": "res://scenes/missions/mission_interdiction.tscn",
		"objectives": ["Destruir a ponte ferroviária", "Destruir o trem de suprimentos", "Eliminar 3 torres Flak", "Eliminar 2 caças inimigos"],
		"enemy_fighters": 2,
		"enemy_towers": 3,
		"has_bridge": true,
		"has_train": true
	},
	{
		"id": "ground_attack",
		"title": "Missão 3: Caça-Bombardeio",
		"subtitle": "Janeiro de 1945 — Vale do Pó, Itália",
		"briefing": "O avanço aliado está sendo retardado por posições de artilharia alemãs entrincheiradas. Sua missão é realizar ataques de precisão contra ninhos de artilharia, um depósito de munição inimigo e as torres Flak que protegem o perímetro. A superioridade aérea não está garantida — espere resistência.",
		"scene": "res://scenes/missions/mission_ground_attack.tscn",
		"objectives": ["Destruir o depósito de munição", "Destruir o ninho de artilharia", "Eliminar 4 torres Flak", "Eliminar 3 caças inimigos"],
		"enemy_fighters": 3,
		"enemy_towers": 4,
		"has_ammo_dump": true,
		"has_artillery_nest": true
	},
	{
		"id": "escort",
		"title": "Missão 4: Escolta de Bombardeiros",
		"subtitle": "Fevereiro de 1945 — Norte da Itália",
		"briefing": "Bombardeiros B-25 Mitchell da USAAF precisam de escolta para atacar alvos estratégicos no norte da Itália. Sua missão é proteger a formação de bombardeiros contra interceptadores inimigos. Os caças alemães estão determinados a abater os bombardeiros a qualquer custo. Não deixe nenhum passar.",
		"scene": "res://scenes/missions/mission_escort.tscn",
		"objectives": ["Proteger os bombardeiros", "Eliminar 4 caças inimigos"],
		"enemy_fighters": 4,
		"enemy_towers": 0,
		"has_bombers": true
	},
	{
		"id": "finale",
		"title": "Missão 5: 22 de Abril de 1945",
		"subtitle": "Ofensiva Final — Vale do Pó, Itália",
		"briefing": "Este é o dia mais intenso da campanha. Em 22 de abril de 1945, o 1º GAvCa realizou 44 surtidas em um único dia — um recorde de combate. O esquadrão está exausto e com poucos pilotos. Todas as forças alemãs restantes estão concentradas. Destrua tudo que encontrar. Esta é a hora da verdade. Senta a Pua!",
		"scene": "res://scenes/missions/mission_finale.tscn",
		"objectives": ["Eliminar 5 torres Flak", "Eliminar 4 caças inimigos", "Destruir o depósito de munição", "Destruir a ponte ferroviária"],
		"enemy_fighters": 4,
		"enemy_towers": 5,
		"has_bridge": true,
		"has_ammo_dump": true
	}
]

# === Campaign State ===

var current_pilot_index: int = 0
var dead_pilots: Array = []
var current_mission_index: int = 0
var active_enemies_count: int = 0
var score: int = 0
var pilots_lost_this_mission: int = 0
var mission_start_time: float = 0.0

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
	active_enemies_count = 0
	pilots_lost_this_mission = 0
	mission_start_time = Time.get_ticks_msec() / 1000.0

func complete_mission() -> void:
	current_mission_index += 1

func register_enemy() -> void:
	active_enemies_count += 1

func enemy_destroyed() -> void:
	active_enemies_count -= 1
	score += 1
	
	# Check victory condition
	if active_enemies_count <= 0:
		await get_tree().create_timer(1.5).timeout
		
		if current_mission_index < missions.size() - 1:
			# More missions ahead — go to mission complete screen
			get_tree().change_scene_to_file("res://scenes/mission_complete.tscn")
		else:
			# Final mission complete — campaign victory
			get_tree().change_scene_to_file("res://scenes/victory.tscn")

# === Helpers ===

func get_mission_elapsed_time() -> float:
	if mission_start_time == 0:
		return 0.0
	return (Time.get_ticks_msec() / 1000.0) - mission_start_time

func get_remaining_pilots() -> int:
	return pilots.size() - current_pilot_index

func get_total_enemies_in_mission() -> int:
	var m = get_current_mission()
	return m.get("enemy_fighters", 0) + m.get("enemy_towers", 0)
