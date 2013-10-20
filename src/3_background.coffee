class Background
	@extend PhysicalObject

	@image = new LoadedImage("img/terrain2.png")

	constructor: ->
		@supers()
		@Renderable(Background.image)
		@Position(new Vector(0, 0))
		@Size(new Vector(CANVAS_WIDTH, CANVAS_HEIGHT))

	toString: -> "Background"