extends CPUParticles3D

func _ready() -> void:
	# Inicia a emissão das partículas de explosão
	emitting = true
	
	# Aguarda o tempo de vida total das partículas antes de deletar o nó
	await get_tree().create_timer(lifetime).timeout
	queue_free()
