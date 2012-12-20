Terrain = (terrainFileName, size) ->
	img = this.img = new Image()
	this.collisionMask = document.createElement('canvas')
	document.getElementById("collisionmap").appendChild(this.collisionMask)
	coll_ctx = this.coll_ctx = this.collisionMask.getContext("2d")
	coll_ctx.fillStyle = "rgb(0,0,0)"
	this.terrain = document.createElement('canvas')
	terrain_ctx = this.terrain_ctx = this.terrain.getContext("2d")
	this.size = size
	this.collisionMask.width = size.x
	this.collisionMask.height = size.y
	this.terrain.width = size.x
	this.terrain.height = size.y
	loader.asyncWaitForLoading(this.img, -> coll_ctx.drawImage(img, 0, 0); terrain_ctx.drawImage(img, 0, 0))
	this.img.src = terrainFileName

Terrain.curvatureVectorField = (->
	increment = (Math.PI*2/16)
	radius = 2
	for direction in [0..FULL_ARC] by increment
		new VectorByDirection(direction, radius)
)()

Terrain.curvatureVectorField2 = (->
	vectors = []
	for x in [-3..3]
		vectors = vectors.concat(new Vector(x, y)) for y in [-3..3]
	return vectors
)()

Terrain::detectCurvature = (air_coords, solid_coords) -> ## returns a normal vector of a terrain surface
	freeVectors = []
	for vector in Terrain.curvatureVectorField2
		pixel_coord = (air_coords.plus vector).floor()
		pixel = this.coll_ctx.getImageData(pixel_coord.x, pixel_coord.y, 1, 1).data[0]
		if pixel == 0
			freeVectors.push(vector)
	normal = new Vector(0,0)
	for v in freeVectors
		normal = normal.plus v
	return normal

Terrain::pointHit = (coords) ->
	coords = coords.floor()
	imgData = this.coll_ctx.getImageData(coords.x, coords.y, 1, 1)
	if imgData.data[0] > 0
		return coords
	else
		return false
	

Terrain::lineHit = (start_point, end_point, reverse = false) ->		## Tests a hit with terrain collision map utilizing Bresenham's optimised line drawing algorithm
	rect_x = Math.floor(Math.min(start_point.x, end_point.x))	## Since getImageData needs it's rectangles coordinates start from left-top corner ..
	rect_y = Math.floor(Math.min(start_point.y, end_point.y))	## ...let's take the minimum coordinates of the vector
	rect_width = Math.round(Math.max(start_point.x, end_point.x)+0.5) - rect_x
	rect_height = Math.round(Math.max(start_point.y, end_point.y)+0.5) - rect_y

	xIncrement = 4					## Incrementing by 4 -> one pixel left, since one pixel consits of four values (RGBA)
	yIncrement = 4 * rect_width		## Incrementing by width of the pixel array times 4 -> one pixel down

	data = this.coll_ctx.getImageData(rect_x, rect_y, rect_width, rect_height).data

	indexRow = 0
	indexCol = 0
	step = xIncrement
	indexCorrect = yIncrement
	errorCorrect = rect_width-1
	errorIncrement = rect_height-1
	if (end_point.x-start_point.x) < 0		## If vector points left
		indexCol += xIncrement * (rect_width-1)		## Index starts from right
		step = -step								## Stepping leftwards
	if (end_point.y-start_point.y) < 0		## If vector points up
		indexRow += yIncrement * (rect_height-1)	## Index starts from bottom
		indexCorrect = -indexCorrect				## Correcting upwards

	tolerance = (errorCorrect - errorIncrement)/2
	lastSafe = new Vector(NaN, NaN)
	hit_point = new Vector(NaN, NaN)
	
	if (not reverse and data[indexRow + indexCol] > 0) or (reverse and data[indexRow + indexCol] == 0)
			## The red channel is not 0, so it's opaque! Collision!
		hit_point.x = rect_x+(indexCol/xIncrement)
		hit_point.y = rect_y+(indexRow/yIncrement)
#		console.log "collision!"
#		console.log hit_point
		return [hit_point, lastSafe]
	else
		lastSafe.x = rect_x+(indexCol/xIncrement)
		lastSafe.y = rect_y+(indexRow/yIncrement)
	loop
		until tolerance > 0
			if (not reverse and data[indexRow + indexCol] > 0) or (reverse and data[indexRow + indexCol] == 0)
					## The red channel is not 0, so it's opaque! Collision!
					## Or if reverse = true and we are searching for the first non-colliding pixel
				hit_point.x = rect_x+(indexCol/xIncrement)
				hit_point.y = rect_y+(indexRow/yIncrement)
#				console.log "collision!"
#				console.log hit_point
				return [hit_point, lastSafe]
			else
				lastSafe.x = rect_x+(indexCol/xIncrement)
				lastSafe.y = rect_y+(indexRow/yIncrement)
			tolerance += errorCorrect
			indexRow += indexCorrect
			if indexRow < 0 or indexRow >= data.length
				break
		indexCol += step
		tolerance -= errorIncrement

		if indexCol >= yIncrement or indexCol < 0
			break

		if (not reverse and data[indexRow + indexCol] > 0) or (reverse and data[indexRow + indexCol] == 0)
				## The red channel is not 0, so it's opaque! Collision!
				## Or if reverse = true and we are searching for the first non-colliding pixel
			hit_point.x = rect_x+(indexCol/xIncrement)
			hit_point.y = rect_y+(indexRow/yIncrement)
#			console.log "collision!"
#			console.log hit_point
			return [hit_point, lastSafe]
		else
			lastSafe.x = rect_x+(indexCol/xIncrement)
			lastSafe.y = rect_y+(indexRow/yIncrement)

	return false

Terrain::blow = (coords, radius) ->
	coords = coords.plus HALF_PIXEL
	this.coll_ctx.beginPath()
	this.coll_ctx.arc(coords.x, coords.y, radius, 0, FULL_ARC, true)
	this.coll_ctx.closePath()
	this.coll_ctx.fill()
	this.terrain_ctx.beginPath()
	this.terrain_ctx.arc(coords.x, coords.y, radius, 0, FULL_ARC, true)
	this.terrain_ctx.closePath()
	this.terrain_ctx.fill()
 