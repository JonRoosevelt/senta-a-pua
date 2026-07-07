extends Resource
# Po Valley ground texture - agricultural patchwork (like real satellite imagery)
# Generates a 1024x1024 texture with varied crop fields

static func generate(width: int = 1024, height: int = 1024) -> ImageTexture:
	var noise_large = FastNoiseLite.new()
	noise_large.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise_large.frequency = 0.003
	noise_large.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	
	var noise_detail = FastNoiseLite.new()
	noise_detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_detail.frequency = 0.015
	noise_detail.fractal_octaves = 3
	
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	
	# Agricultural color palette (Po Valley crops)
	var colors = [
		Color(0.22, 0.38, 0.15),  # dark green (corn/alfalfa)
		Color(0.30, 0.42, 0.18),  # medium green (wheat field)
		Color(0.35, 0.48, 0.20),  # light green (pasture)
		Color(0.42, 0.36, 0.18),  # brown (plowed earth)
		Color(0.48, 0.40, 0.22),  # tan (harvested wheat)
		Color(0.38, 0.44, 0.16),  # olive green (vineyard)
		Color(0.28, 0.35, 0.20),  # forest green (tree clusters)
		Color(0.52, 0.45, 0.25),  # light tan (dry grass)
	]
	
	for y in range(height):
		for x in range(width):
			var cell_val = noise_large.get_noise_2d(x, y)
			var detail = noise_detail.get_noise_2d(x, y) * 0.08
			
			# Map cell value to color index
			var idx = int((cell_val + 1.0) / 2.0 * (colors.size() - 1))
			idx = clampi(idx, 0, colors.size() - 1)
			
			var base = colors[idx]
			var final_color = Color(
				clamp(base.r + detail, 0.0, 1.0),
				clamp(base.g + detail, 0.0, 1.0),
				clamp(base.b + detail * 0.5, 0.0, 1.0)
			)
			
			image.set_pixel(x, y, final_color)
	
	return ImageTexture.create_from_image(image)
