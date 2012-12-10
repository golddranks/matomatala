Terrain = (terrainFileName, width, height, game) ->
	img = this.img = new Image()
	this.collisionMask = document.createElement('canvas')
	document.getElementById("collisionmap").appendChild(this.collisionMask)
	coll_ctx = this.coll_ctx = this.collisionMask.getContext("2d")
	coll_ctx.fillStyle = "rgb(0,0,0)"
	this.terrain = document.createElement('canvas')
	terrain_ctx = this.terrain_ctx = this.terrain.getContext("2d")
	this.width = width
	this.height = height
	this.collisionMask.width = width
	this.collisionMask.height = height
	this.terrain.width = width
	this.terrain.height = height
	game.waitForLoading(this.img, -> coll_ctx.drawImage(img, 0, 0); terrain_ctx.drawImage(img, 0, 0))
	this.img.src = terrainFileName

Terrain.curvatureVectorField = (->
	fullArc = Math.PI*2
	increment = (Math.PI*2/16)
	radius = 2
	for i in [0..fullArc] by increment
		[i, Math.sin(i)*radius, Math.cos(i)*radius]
)()

Terrain.prototype.detectCurvature = (x, y) -> ## sums all vectors in curvatureVectorField, that don't collide with terrain.
	freeVectors = []
	for vector in Terrain.curvatureVectorField
		pixel = this.coll_ctx.getImageData(Math.round(x+vector[1]), Math.round(y+vector[2]), 1, 1).data[0]
		if pixel == 0
			freeVectors.push(vector)
	norm_x = 0
	norm_y = 0
	for v in freeVectors
		norm_x += v[1]
		norm_y += v[2]
	return [norm_x, norm_y]

Terrain.prototype.render = (c, cam) ->
	c.drawImage(this.terrain, cam.x, cam.y, cam.width, cam.height, 0, 0, cam.width, cam.height)

Terrain.prototype.lineHit = (x1, y1, x2, y2) ->		## Tests a hit with terrain collision map utilizing Bresenham's optimised line drawing algorithm
	x = Math.round(Math.min(x1, x2))	## Since getImageData needs it's rectangles coordinates start from left-top corner ..
	y = Math.round(Math.min(y1, y2))	## ...let's take the minimum coordinates of the vector

	dx = Math.round(x2-x1)	
	dy = Math.round(y2-y1)

	width = Math.abs(dx)
	height = Math.abs(dy)
	if width == 0
		width = 1
	if height == 0
		height = 1

	xIncrement = 4					## Incrementing by 4 -> one pixel left, since one pixel consits of four values (RGBA)
	yIncrement = 4 * width			## Incrementing by width of the pixel array times 4 -> one pixel down

	indexRow = 0
	indexCol = 0
	if height <= width
		step = xIncrement
		indexCorrect = yIncrement
		errorCorrect = width
		errorIncrement = height
		if dx < 0							## If vector points left
			indexCol += xIncrement * (width-1)	## Index starts from right
			step = -step					## Stepping leftwards
		if dy < 0							## If vector points up
			indexRow += yIncrement * (height-1)	## Index starts from bottom
			indexCorrect = -indexCorrect		## Correcting upwards
	else
		step = yIncrement
		indexCorrect = xIncrement
		errorCorrect = height
		errorIncrement = width
		if dx < 0							## If vector points left
			indexCol += xIncrement * (width-1)	## Index starts from right
			indexCorrect = -indexCorrect		## Stepping leftwards
		if dy < 0							## If vector points up
			indexRow += yIncrement * (height-1)	## Index starts from bottom
			step = -step						## Correcting upwards


	imgData = this.coll_ctx.getImageData(x, y, width, height)
	data = imgData.data
	error = errorCorrect

#	console.log "data.length: "+data.length+", pixels in data: "+ (data.length/xIncrement) + ", rows in data: " + (data.length/yIncrement)+", width: "+width+", rowlength: "+(data.length/height)+", height: "+height+", raw dy+"+this.dy+", raw dx+"+this.dx+" "
#	game.d_ctx.strokeStyle = "rgb(255, 0, 0)"
#	game.d_ctx.strokeRect(x+0.5, y+0.5, width-1, height-1)
#	color = Math.round(Math.random()*255)
#	game.d_ctx.fillStyle = "rgb(0, "+color+", 255)"
	
	if height <= width
		loop
#			game.d_ctx.fillRect(x+(indexCol/xIncrement), y+(indexRow/yIncrement), 1,1)
#			console.log "drawn at col "+indexCol+ "-"+(indexCol+3)+" row "+indexRow+"-"+(indexRow+yIncrement-1)+" "
			if data[indexRow + indexCol] > 0		## The red channel is not 0, so it's opaque! Collision!
				return [x+(indexCol/xIncrement), y+(indexRow/yIncrement)]
			indexCol += step
#			console.log "stepped to "+indexCol
			if indexCol >= yIncrement or indexCol < 0
				break
			error -= errorIncrement
			if error <= 0
				error += errorCorrect
				indexRow += indexCorrect
#				console.log "corrected to "+indexRow
			if indexRow >= data.length or indexRow < 0
				break
	else
		loop
#			game.d_ctx.fillRect(x+(indexCol/xIncrement), y+(indexRow/yIncrement), 1,1)
#			console.log "drawn at col "+indexCol+ "-"+(indexCol+3)+" row "+indexRow+"-"+(indexRow+yIncrement-1)+" "
			if data[indexRow + indexCol] > 0		## The red channel is not 0, so it's opaque! Collision!
				return [x+(indexCol/xIncrement), y+(indexRow/yIncrement)]
			indexRow += step
#			console.log "stepped to "+indexRow
			if indexRow >= data.length or indexRow < 0
				break
			error -= errorIncrement
			if error <= 0
				error += errorCorrect
				indexCol += indexCorrect
#				console.log "corrected to "+indexCol
			if indexCol >= data.length or indexCol < 0
				break

	return false

Terrain.prototype.blow = (x, y, rad) ->
	this.coll_ctx.beginPath()
	this.coll_ctx.arc(x+0.5, y+0.5, rad, 0, Math.PI*2, true)
	this.coll_ctx.closePath()
	this.coll_ctx.fill()
	this.terrain_ctx.beginPath()
	this.terrain_ctx.arc(x+0.5, y+0.5, rad, 0, Math.PI*2, true)
	this.terrain_ctx.closePath()
	this.terrain_ctx.fill()

window.Terrain = Terrain