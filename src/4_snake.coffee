class Snake
	@extend BaseObject

	toString: -> "Snake"

	image_red: new LoadedImage("img/v_coll.png")

	### Static methods ###

	@test_collisions: ->
		for snake in this::instances
			snake.collides()



	### Instance methods ###

	constructor: (player, pos) ->
		@supers()
		@player = player
		@head = new SnakeHead(this, pos)
		@tailBits = []
		@tailEnd = null
		@grow(40)
		for bit in @tailBits
			bit.Renderable(bit.image2)
		@dead = false

	maxSpeed: 150

	collides: ->

		namu = @head.collidesAny(Namu::instances)	# Namun syöminen
		if namu
			@eat(namu)

		wall = @head.collidesAny(Wall::instances)	# Törmäys seinään
		if wall
			@head.Renderable(@image_red)
			@die()

		for s in Snake::instances					# Törmäys vastustajaan
			if s isnt this
				bits = @head.collidesAll(s.tailBits)
				for bit in bits
					bit.Renderable(@image_red)
					@head.Renderable(@image_red)
					@die()

		bit = @tailEnd
		while bit = bit.forward						# Törmäys itseen (tsekataan kollisiot lopusta alkuun)
			if bit.total_pixels_moved > @head.total_pixels_moved - 33
				break
			if @head.bbox_collision(bit)
				bit.Renderable(@image_red)
				@head.Renderable(@image_red)
				@die(bit)
		
		return false

	eat: (namu) ->
		if namu.getsEaten(this)
			@grow(namu.score * 10)
			@player.score.add(namu.score)
			for i in [1..(namu.score)] by 1
				@maxSpeed *= game.speedMultiplier
				@head.velocity.scale(game.speedMultiplier)

	grow: (amount) ->
		for i in [1..(amount)] by 1
			new TailBit(this)

	up: ->
		if @head.velocity.y is 0 and @head.up_karenssi.i <= 0
			@head.setVelocity(0,-@maxSpeed)
			@head.karenssi = @head.down_karenssi

	down: ->
		if @head.velocity.y is 0 and @head.down_karenssi.i <= 0
			@head.setVelocity(0,@maxSpeed)
			@head.karenssi = @head.up_karenssi

	left: ->
		if @head.velocity.x is 0 and @head.left_karenssi.i <= 0
			@head.setVelocity(-@maxSpeed,0)
			@head.karenssi = @head.right_karenssi

	right: ->
		if @head.velocity.x is 0 and @head.right_karenssi.i <= 0
			@head.setVelocity(@maxSpeed,0)
			@head.karenssi = @head.left_karenssi

	die: (bit) ->
		if not @dead
			bit?.decompose_forward()
			bit?.decompose_backward()
			@dead = true
			@head.setVelocity(0, 0)
			@collides = -> true
			@tailEnd.decompose_forward()
			@head.backward.decompose_backward()
			@player.died()

	disposeBody: =>
		for t in @tailBits
			t.destroy()
		@head.destroy()
		@destroy()

	delirium: ->
		if not @__delirium
			@__delirium = true
			@head.Renderable(@image_red)
			@tailEnd.follow = ->
				if not @snake.dead and @head.speed > 0
					@snake.grow(1)
					@snake.head.backward.Renderable(@snake.image_red)
					@snake.player.score.add(Math.floor(game.ticker.delta_time*97971))
			@eat = -> false
			@die = ->
				@head.velocity.scale(-1)
				Movable::move.apply(@head)
				@head.setVelocity(0, 0)



SNAKE_SIZE = new Vector(16, 16)

class SnakeHead
	@extend PhysicalObject
	@extend Movable

	toString: -> "SnakeHead"

	image: new LoadedImage("img/v.png")

	constructor: (snake, pos) ->
		@supers()
		@Position(pos)
		@Size(SNAKE_SIZE)
		@relocate()
		@snake = snake
		@total_pixels_moved = 0
		@up_karenssi = {i: 0}
		@down_karenssi = {i: 0}
		@left_karenssi = {i: 0}
		@right_karenssi = {i: 0}
		@karenssi = {i: 0} # placeholder value

	relocate: ->
		for type in [Wall, SnakeHead, TailBit, Namu]
			collider = @collidesAny(type::instances, true)
			if collider
				@Position(new Vector(Math.random()*CANVAS_WIDTH, Math.random()*CANVAS_HEIGHT))
				@relocate()
	move: ->
		Movable::move.apply(this)
		if @snake.collides()
			return
		if @speed is 0
			return
		@snake.tailEnd.follow()
		@pixels_moved = @speed * game.ticker.delta_time
		@total_pixels_moved += @pixels_moved
		@up_karenssi.i -= @pixels_moved
		@down_karenssi.i -= @pixels_moved
		@left_karenssi.i -= @pixels_moved
		@right_karenssi.i -= @pixels_moved
		@karenssi.i = 16

class TailBit
	@extend PhysicalObject
	@extend Movable

	toString: -> "TailBit"

	image: new LoadedImage("img/v_munch.png")
	image2: new LoadedImage("img/v.png")

	constructor: (snake) ->
		@supers()
		@Position(snake.head.position.clone())
		@Size(SNAKE_SIZE)
		@head = snake.head
		@snake = snake
		@snake.tailBits.push(this)
		if @head.backward?	# Jos aiempaa häntää on olemassa
			@backward = @head.backward
			@backward.forward = this
		else
			@backward = null
			snake.tailEnd = this
		@forward = @head
		@head.backward = this
		@total_pixels_moved = @head.total_pixels_moved

	# Follow toimii tehokkuuden vuoksi telaketjutaktiikalla: viimeinen pala häntää siirretään niskaan
	follow: ->
		@moveTo(@head.position.clone())
		@total_pixels_moved = @head.total_pixels_moved
		@Renderable(@image2)

		# Irroita vanhasta paikastaan
		@forward.backward = null
		@snake.tailEnd = @forward

		# Kiinnitä uuteen
		@forward = @head
		@backward = @head.backward
		@head.backward = this
		@backward.forward = this

	decompose_forward: =>
		if @speed is 0
			@setVelocity(Math.random()*50-25, Math.random()*50-25)
		#	@setVelocity(0, -100)
		if @forward.decompose_forward?
			window.setTimeout(@forward.decompose_forward, 100/@snake.tailBits.length)

	decompose_backward: =>
		if @speed is 0
			@setVelocity(Math.random()*50-25, Math.random()*50-25)
		#	@setVelocity(0, -100)
		if @backward?.decompose_backward?
			window.setTimeout(@backward.decompose_backward, 100/@snake.tailBits.length)

	move: ->
		Movable::move.call(this)
		@setVelocity(@velocity.times(0.96))