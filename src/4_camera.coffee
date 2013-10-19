### Camera: a movable viewport which points to the centre of the place that is supposed to be "on-screen" ###

class Camera
	@extend Renderer
	@extend Position
	@extend Size
	@extend Collision


	constructor: ->
		@supers()
		@Position(new Vector(CANVAS_WIDTH/2, CANVAS_HEIGHT/2))
		@Size(new Vector(CANVAS_WIDTH, CANVAS_HEIGHT))

	render: (ctx) ->
		ctx.save()
		for physicals in PhysicalObject.descendants
			for renderable in @collidesAll(physicals::instances)
				renderable.render(ctx)
		ctx.translate(-this.position.x, -this.position.y)
		ctx.restore()

	toString: -> "Camera"
