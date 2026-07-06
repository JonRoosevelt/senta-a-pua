extends Control

func _draw() -> void:
	# Desenha uma mira de cruz verde neon centralizada de alto contraste
	var color = Color(0.2, 1.0, 0.2, 0.8) # Verde brilhante neon
	var length = 14.0
	var thickness = 2.0
	var offset = 6.0 # Espaço vazio no centro para melhor visibilidade
	
	# Linha Horizontal Esquerda
	draw_line(Vector2(-length - offset, 0), Vector2(-offset, 0), color, thickness)
	# Linha Horizontal Direita
	draw_line(Vector2(offset, 0), Vector2(length + offset, 0), color, thickness)
	# Linha Vertical Cima
	draw_line(Vector2(0, -length - offset), Vector2(0, -offset), color, thickness)
	# Linha Vertical Baixo
	draw_line(Vector2(0, offset), Vector2(0, length + offset), color, thickness)
	
	# Ponto central
	draw_circle(Vector2.ZERO, 1.5, color)
