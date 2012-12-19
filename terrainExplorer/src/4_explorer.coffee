Explorer = (position, terrain) ->
	super(position, terrain)
	return

Explorer extends GameObject

Explorer::render = (ctx, canvas) ->
	canvas.plot(this.position)
	canvas.drawArrow(this.position, this.terrain.detectCurvature(this.position))