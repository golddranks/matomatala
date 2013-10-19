class Yaoi
	@extend Renderer

	toString: -> "Yaoi"

	olli: new LoadedImage("img/olli.png")
	mika: new LoadedImage("img/mika.png")

	constructor: ->
		@supers()
		@o = new Miekkailija(@olli, new Vector(130, 220))
		@m = new Miekkailija(@mika, new Vector(270, 220))
		@l = new Label("Mika ja Olli, harmoniset värähtelijät.", new Vector(200, 310), "bold 10px sans-serif")
		@ll = new Label("YAOI_SHOW", new Vector(200, 130), "bold 20px sans-serif")

	@run: ->
		if this::instances.length > 0
		else
			@running = new Yaoi()
		@running.show = true

	render: (ctx) ->
		if @show
			@l.render(ctx)
			@ll.render(ctx)
			@o.render(ctx)
			@m.render(ctx)
			@show = false

class Miekkailija
	@extend BaseObject
	@extend Renderable
	@extend Position
	@extend Size
	@extend Collision
	@extend Movable

	constructor: (img, pos) ->
		@supers()
		@Position(pos)
		@Renderable(img)
		@Size(@render_img.size)

	move: ->
		Movable::move.call(this)
		@accelerate((200-@position.x)*0.5, 0)