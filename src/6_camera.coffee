### Camera: a movable object which points to the centre of the place that is supposed to be "on-screen" ###

Camera = (viewport_size, terrain) -> # Params x and y signify the left-top corner
	this.position = new Vector(0,0)
	this.size = viewport_size
	this.terrain = terrain
	return

Camera::focusTo = (coords) ->	# Params x and y signify the point, which is supposed to be at the centre of screen
	x = coords.x - (this.size.x/2)
	y = coords.y - (this.size.y/2)
	if x < 0
		x = 0
	if x+this.width > this.terrain.width
		x = this.terrain.width - this.width
	if y < 0
		y = 0
	if y+this.height > this.terrain.height
		y = this.terrain.height - this.height
	this.position = new Vector(x, y).floor()

Camera::render = (ctx) ->
	ctx.save()
#	ctx.clearRect(0,0, CANVAS_WIDTH, CANVAS_HEIGHT);
	ctx.drawImage(this.terrain.terrain, this.position.x, this.position.y, this.size.x, this.size.y, 0, 0, this.size.x, this.size.y)
	ctx.translateRound(-this.position.x, -this.position.y)
	GameObject.render(ctx)
	ctx.restore()