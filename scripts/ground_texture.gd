extends Resource
# Procedural ground texture using FastNoiseLite
# Generates a 512x512 texture with grass/earth variation

static func generate(width: int = 512, height: int = 512) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.005
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	
	for y in range(height):
		for x in range(width):
			var value = noise.get_noise_2d(x, y)  # -1.0 to 1.0
			
			# Map noise to grass/earth colors
			var color: Color
			if value > 0.1:
				# Greener grass
				color = Color(0.25 + value * 0.15, 0.35 + value * 0.2, 0.12, 1)
			elif value > -0.1:
				# Transition earth/grass
				color = Color(0.38, 0.32, 0.18, 1)
			else:
				# Dirt/earth
				color = Color(0.42 + value * 0.1, 0.30 + value * 0.1, 0.14, 1)
			
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.create_from_image(image)
	return texture
