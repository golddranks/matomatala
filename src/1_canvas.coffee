### Canvas: a base class for drawing stuff. ###

Canvas = (size, container) ->
	this.canvas = document.createElement("canvas")
	this.canvas.width = size.x
	this.canvas.height = size.y
	this.ctx = this.canvas.getContext("2d")
	this.ctx.imageSmoothingEnabled = false
	this.color = RED

	this.ctx.translateRound = (coords) ->
		coords = coords.floor()
		this.translate(coords.x, coords.y)

	if container?
		container.appendChild(this.canvas)
	return

Canvas::drawLine = (start_point, end_point) ->
	this.ctx.strokeStyle = this.color
	this.ctx.fillStyle = this.color
	this.ctx.beginPath();
	start_point = start_point.plus HALF_PIXEL
	end_point = end_point.plus HALF_PIXEL
	this.ctx.moveTo( start_point.x, start_point.y )
	this.ctx.lineTo( end_point.x, end_point.y )
	this.ctx.stroke()
	
Canvas::drawRect = (left_top_coords, size) ->
	this.ctx.fillStyle = this.color
	this.ctx.fillRect(left_top_coords.x, left_top_coords.y, size.x, size.y);

Canvas::plot = (point) ->
	this.ctx.fillStyle = this.color
	this.ctx.fillRect(point.x, point.y, 1, 1)

Canvas::render = (ctx, cam) ->
	ctx.drawImage(this.canvas, cam.position.x, cam.position.y, cam.size.x, cam.size.y, 0, 0, cam.size.x, cam.size.y)

Canvas::clear = ->
	this.ctx.clearRect(0,0,this.canvas.width, this.canvas.height)

Canvas::drawArrow = (start_point, arrow) ->
	unit = arrow.unit()
	for i in [0..arrow.length()]
		this.plot(start_point.plus unit.scaledBy i)
