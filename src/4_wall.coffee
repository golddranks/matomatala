class Wall
	@extend PhysicalObject

	image: new LoadedImage("img/wall.png")
	image2: new LoadedImage("img/wall2.png")

	constructor: (pos, size, type) ->
		@supers()
		@Position(pos)
		@Size(size)
		if type == 2
			@render_img = @image2
		@name = "Wall"

	toString: -> "Wall"

	render: (ctx) ->
		ctx.save()
		ctx.translate(@edge.left, @.edge.top)
		for y in [@edge.top..@edge.bottom-1] by @render_img.size.y
			ctx.save()
			for x in [@edge.left..@edge.right-1] by @render_img.size.x
				ctx.drawImage(@render_img.img, 0, 0)
				ctx.translate(@render_img.size.x, 0)
			ctx.restore()
			ctx.translate(0, @render_img.size.y)
		ctx.restore()