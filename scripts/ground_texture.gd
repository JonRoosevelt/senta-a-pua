extends Resource
# Tactical map-style ground texture - inspired by Po Valley illustrated map
# Clean, readable, with clear field boundaries like a wargame map

static func generate(width: int = 1024, height: int = 1024) -> ImageTexture:
	var noise_base = FastNoiseLite.new()
	noise_base.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_base.frequency = 0.004
	noise_base.fractal_octaves = 3
	
	var noise_fields = FastNoiseLite.new()
	noise_fields.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise_fields.frequency = 0.006
	noise_fields.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2
	
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	
	# Po Valley illustrated map colors
	var grass_green = Color(0.45, 0.62, 0.28)     # bright agricultural green
	var field_green = Color(0.35, 0.55, 0.22)      # darker field green
	var crop_yellow = Color(0.62, 0.58, 0.28)      # harvested wheat
	var earth_brown = Color(0.48, 0.38, 0.22)      # plowed earth
	var forest_dark = Color(0.22, 0.35, 0.18)      # forest patches
	var water_blue = Color(0.25, 0.45, 0.55)        # river/lake
	
	for y in range(height):
		for x in range(width):
			var base = noise_base.get_noise_2d(x, y)
			var field = noise_fields.get_noise_2d(x, y)
			
			# Field boundaries create the patchwork look
			var is_boundary = field > 0.85
			var is_forest = base < -0.35
			var is_water = base < -0.55
			
			var color: Color
			if is_water:
				color = water_blue
			elif is_forest:
				color = forest_dark
			elif is_boundary:
				color = earth_brown  # field edges = dirt paths
			elif base > 0.15:
				color = crop_yellow  # bright = harvested/wheat
			elif base > -0.1:
				color = grass_green  # mid = green fields
			else:
				color = field_green  # lower = darker fields
			
			image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)
