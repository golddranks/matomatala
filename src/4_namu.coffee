class Namu
	@extend PhysicalObject
	@extend Movable

	toString: -> "Namu"

	image: new LoadedImage("img/namu.png")
	image2: new LoadedImage("img/namu2.png")

	constructor: ->
		@supers()
		@Renderable(@image)
		@Position(new Vector(Math.random()*CANVAS_WIDTH, Math.random()*CANVAS_HEIGHT))
		@Size(new Vector(16, 16))
		@relocate()
		if Math.random() > 0.7
			@score = 3
			@render_img = @image2
		else
			@score = 1
		@eaten = false

	relocate: ->
		for type in [Wall, SnakeHead, TailBit, Namu]
			collider = @collidesAny(type::instances) or @collidesAny(type::created)
			if collider
				@Position(new Vector(Math.random()*CANVAS_WIDTH, Math.random()*CANVAS_HEIGHT))
				@relocate()

	getsEaten: (eater) ->
		if not @eaten
			@eaten = true
			@setVelocity(eater.head.position.minus(@position).times(10))
			new Namu()
			window.setTimeout(@destroy, 100)
			return true
		return false

	destroy: =>
		Destructable::destroy.call(this)

	move: ->
		Movable::move.call(this)
		@setVelocity(@velocity.scale(0.9))

	@destroyAll: ->
		for n in Namu::instances
			n.destroy()
		for n in Namu::created
			n.destroy()

class MenuNamu
	@extend Namu

	toString: -> "MenuNamu"

	constructor: (callback) ->
		@supers()
		@Renderable(@image)
		@Position(new Vector(Math.random()*CANVAS_WIDTH*0.8+CANVAS_WIDTH*0.1, Math.random()*CANVAS_HEIGHT*0.35+(CANVAS_HEIGHT*0.4)))
		@Size(new Vector(16, 16))
		@relocate()
		@callback = callback
		label = new Label(@callback.title, @position.minus(new Vector(0,13)))
		game.hud.add(label)

	getsEaten: ->
		@callback()


	relocate: ->
		for type in [Wall, SnakeHead, TailBit, Namu]
			collider = @collidesAny(type::instances) or @collidesAny(type::created)
			if collider
				@Position(new Vector(Math.random()*CANVAS_WIDTH*0.8+CANVAS_WIDTH*0.1, Math.random()*CANVAS_HEIGHT*0.6+(CANVAS_HEIGHT*0.3)))
				@relocate()
