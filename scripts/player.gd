extends CharacterBody3D

@export var forward_speed: float = 40.0
@export var roll_speed: float = 2.5
@export var pitch_speed: float = 2.0
@export var max_health: float = 100.0
@export var invert_pitch: bool = true  # Puxar para baixo/trás faz o nariz subir (padrão de aviação)
@export var convergence_distance: float = 150.0  # Distância de convergência das balas (metros)
@export var fire_rate: float = 0.08  # Tempo entre disparos ao segurar (segundos)

# Parâmetros de Aceleração/Throttle
@export var min_speed: float = 20.0
@export var max_speed: float = 65.0
@export var acceleration_rate: float = 18.0

@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var wing_tip_l: Marker3D = $WingTipL
@onready var wing_tip_r: Marker3D = $WingTipR
@onready var camera: Camera3D = $Camera3D
@onready var helice: MeshInstance3D = $Helice

# Referências das partículas de vapor nas pontas das asas
@onready var vapor_trail_l: CPUParticles3D = $WingTipL/VaporTrailL
@onready var vapor_trail_r: CPUParticles3D = $WingTipR/VaporTrailR

# Referências dos nós do HUD
@onready var health_label: Label = $CanvasLayer/Control/StatusPanel/VBoxContainer/HealthLabel
@onready var speed_label: Label = $CanvasLayer/Control/StatusPanel/VBoxContainer/SpeedLabel
@onready var altitude_label: Label = $CanvasLayer/Control/StatusPanel/VBoxContainer/AltitudeLabel
@onready var score_label: Label = $CanvasLayer/Control/StatusPanel/VBoxContainer/ScoreLabel

var health: float = 100.0
var is_dead: bool = false
var fire_cooldown: float = 0.0

# Variáveis do tremor de câmera (Camera Shake)
var shake_amount: float = 0.0
var shake_decay: float = 5.0  # Velocidade com que o tremor diminui
var camera_base_transform: Transform3D

func _ready() -> void:
	health = max_health
	camera_base_transform = camera.transform

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# 1. Controle de Aceleração (Throttle) - Lendo W e S fisicamente
	var throttle_input = 0.0
	if Input.is_key_pressed(KEY_W):
		throttle_input += 1.0
	if Input.is_key_pressed(KEY_S):
		throttle_input -= 1.0
		
	# Atualiza a velocidade base do motor
	forward_speed = clamp(forward_speed + throttle_input * acceleration_rate * delta, min_speed, max_speed)
	
	# 2. Captura de Inputs de Rotação (Teclado/Controle)
	var roll_input = Input.get_axis("ui_left", "ui_right")  # Setas Esquerda/Direita (Roll corrigido)
	var pitch_input = Input.get_axis("ui_up", "ui_down") if invert_pitch else Input.get_axis("ui_down", "ui_up")
	
	# 3. Aplicar as Rotações usando a base local do próprio avião
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)
	rotate_object_local(Vector3.RIGHT, pitch_input * pitch_speed * delta)
	
	# 4. Física de Voo Realista Simplificada (Gravidade vs Sustentação/Lift)
	var forward_direction = -global_transform.basis.z
	var engine_velocity = forward_direction * forward_speed
	
	# Gravidade constante puxando para baixo (9.8 m/s²)
	var gravity_vector = Vector3(0, -9.8, 0)
	
	# Sustentação (Lift): Aponta para o "teto" local do avião (global_transform.basis.y)
	# A força da sustentação é proporcional à velocidade (sustentação ideal a 40.0 m/s)
	var speed_ratio = forward_speed / 40.0
	var lift_vector = global_transform.basis.y * 9.8 * speed_ratio
	
	# A velocidade final combina o empuxo do motor com a resultante física (gravidade + lift)
	velocity = engine_velocity + (gravity_vector + lift_vector)
	
	# 5. Executa a movimentação e lida com colisões
	move_and_slide()
	
	# Detecta colisão (Crash contra chão, montanhas ou torres)
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(100.0) # Faz a torre inimiga explodir junto
		crash()
		return
	
	# Controle do tempo de recarga da metralhadora
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	# 6. Código de Tiro (Disparo contínuo ao segurar a Barra de Espaço)
	if Input.is_action_pressed("ui_accept") and fire_cooldown <= 0:
		shoot()
		fire_cooldown = fire_rate
		
	# 7. Ativação dos rastros de vento (Vapor) nas asas em curvas fechadas
	var is_turning_hard = abs(roll_input) > 0.7 or abs(pitch_input) > 0.7
	if is_instance_valid(vapor_trail_l):
		vapor_trail_l.emitting = is_turning_hard
	if is_instance_valid(vapor_trail_r):
		vapor_trail_r.emitting = is_turning_hard
		
	# 8. Atualiza o Tremor da Câmera
	if shake_amount > 0:
		shake_amount = move_toward(shake_amount, 0.0, shake_decay * delta)
		camera.transform.origin = camera_base_transform.origin + Vector3(
			randf_range(-1.0, 1.0) * shake_amount,
			randf_range(-1.0, 1.0) * shake_amount,
			0.0
		)
	else:
		camera.transform.origin = camera_base_transform.origin
		
	# 9. Roda a hélice baseada na velocidade atual do motor
	if is_instance_valid(helice):
		helice.rotate_z(26.0 * delta * (forward_speed / 40.0))
		
	# 10. Atualiza as informações do HUD na tela
	update_hud()

func shoot() -> void:
	# Ponto de convergência no espaço 3D à frente do avião
	var forward_dir = -global_transform.basis.z
	var convergence_point = global_position + forward_dir * convergence_distance
	
	# Calcula as direções anguladas para dentro em direção ao ponto de convergência
	var dir_left = (convergence_point - wing_tip_l.global_position).normalized()
	var dir_right = (convergence_point - wing_tip_r.global_position).normalized()
	
	# Cria a bala da asa esquerda e a rotaciona na direção correta
	var b_left = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b_left)
	b_left.global_position = wing_tip_l.global_position
	b_left.direction = dir_left
	b_left.look_at(b_left.global_position + dir_left, Vector3.UP)
	
	# Cria a bala da asa direita e a rotaciona na direção correta
	var b_right = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b_right)
	b_right.global_position = wing_tip_r.global_position
	b_right.direction = dir_right
	b_right.look_at(b_right.global_position + dir_right, Vector3.UP)
	
	# Adiciona um tremor leve na câmera a cada disparo para dar sensação de recuo (recoil)
	shake_amount = clamp(shake_amount + 0.05, 0.0, 0.15)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	print("Dano recebido! Integridade do P-47: ", health, "%")
	
	# Adiciona um chacoalhão forte na câmera ao levar dano
	shake_amount = clamp(shake_amount + 0.25, 0.0, 0.5)
	
	if health <= 0:
		crash()

func update_hud() -> void:
	if is_instance_valid(health_label):
		health_label.text = "INTEGRIDADE: %d%%" % int(max(health, 0))
	if is_instance_valid(speed_label):
		# Transforma a velocidade em milhas por hora (MPH) realista
		speed_label.text = "VELOCIDADE: %d MPH" % int(forward_speed * 7.5) # Ajuste de escala para parecer mais rápido (ex: 300 MPH)
	if is_instance_valid(altitude_label):
		# Transforma a posição Y em pés (Feet) de altitude
		altitude_label.text = "ALTITUDE: %d FT" % int(global_position.y * 3.28)
	if is_instance_valid(score_label):
		if GameManager:
			var missao = GameManager.get_current_mission()
			var nome_missao = missao.get("title", "MISSÃO") if missao else "MISSÃO"
			score_label.text = "%s | %s | ALVOS: %d" % [nome_missao, GameManager.get_current_pilot().to_upper(), GameManager.score]
		else:
			score_label.text = "ALVOS DESTRUÍDOS: 0"

func crash() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Instancia o efeito de explosão na posição do avião
	var expl = explosion_scene.instantiate()
	get_tree().current_scene.add_child(expl)
	expl.global_position = global_position
	
	# Esconde o modelo visual do avião ao explodir
	for child in get_children():
		if child is MeshInstance3D:
			child.visible = false
	
	# Checkpoint: perde piloto só depois de X mortes
	if GameManager:
		GameManager.checkpoint_death()
		
	print("Bateu ou foi derrubado!")
	
	# Aguarda 1.5 segundos para o jogador ver a explosão antes de reiniciar
	await get_tree().create_timer(1.5).timeout
	
	# Se a campanha acabou (sem pilotos), muda para Game Over. Caso contrário, recarrega
	if GameManager and GameManager.is_campaign_over():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		get_tree().reload_current_scene()
