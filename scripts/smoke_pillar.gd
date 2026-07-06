# smoke_pillar.gd - Smoldering smoke/fire effect that lingers after explosions
extends CPUParticles3D

func _ready() -> void:
	emitting = true
	# Smoke persists longer than explosion particles
	await get_tree().create_timer(lifetime + 2.0).timeout
	queue_free()
