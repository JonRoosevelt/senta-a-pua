extends Node3D

@onready var fire_particles: CPUParticles3D = $FireParticles
@onready var smoke_particles: CPUParticles3D = $SmokeParticles

func _ready() -> void:
	# Emit both fire and smoke simultaneously
	if fire_particles:
		fire_particles.emitting = true
	if smoke_particles:
		smoke_particles.emitting = true
	
	# Wait for smoke lifetime (longer) before cleaning up
	var max_lifetime = max(
		fire_particles.lifetime if fire_particles else 1.0,
		smoke_particles.lifetime if smoke_particles else 1.0
	)
	await get_tree().create_timer(max_lifetime + 0.5).timeout
	queue_free()
