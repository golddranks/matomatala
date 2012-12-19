### Canvas: a base class for drawing stuff. ###

Canvas = (width, height, container) ->
	this.canvas = document.createElement("canvas")
	this.canvas.width = width
	this.canvas.height = height
	this.ctx = this.canvas.getContext("2d")
	this.ctx.imageSmoothingEnabled = false
	this.color = RED

	this.ctx.translateRound = (x, y) ->
		this.translate(Math.floor(x), Math.floor(y))

	if container?
		container.appendChild(this.canvas)
	return

Canvas::drawLine = (start_point, end_point) ->
	this.ctx.strokeStyle = this.color
	this.ctx.fillStyle = this.color
	this.ctx.beginPath();
	start_point = vectorSum(start_point, HALF_PIXEL)
	end_point = vectorSum(end_point, HALF_PIXEL)
	this.ctx.moveTo( start_point.x, start_point.y )
	this.ctx.lineTo( end_point.x, end_point.y )
	this.ctx.stroke()
	
Canvas::drawRect = (left_top_coords, width, height) ->
	this.ctx.fillStyle = this.color
	this.ctx.fillRect(left_top_coords.x, left_top_coords.y, width, height);

Canvas::plot = (point) ->
	this.ctx.fillStyle = this.color
	this.ctx.fillRect(point.x, point.y, 1, 1)

Canvas::render = (ctx, cam) ->
	ctx.drawImage(this.canvas, cam.position.x, cam.position.y, cam.width, cam.height, 0, 0, cam.width, cam.height)

Canvas::clear = ->
	this.ctx.clearRect(0,0,this.canvas.width, this.canvas.height)

Canvas::drawArrow = (start_point, arrow) ->
	unit = unitVector(arrow)
	length = vectorLength(arrow)
	for i in [0..length]
		this.plot(vectorSum(start_point, vectorScale(unit, i)))
