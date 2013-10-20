class Player
	@extend BaseObject

	up: => @snake?.up()
	down: => @snake?.down()
	left: => @snake?.left()
	right: => @snake?.right()

	spawn: =>
		@snake = new Snake(this, @position.clone())

	constructor: (x, y, name) ->
		@position = new Vector(x, y)
		@name = name
		@score = new Score(this)
		@dead_snake = null

	died: ->
		@dead_snake = @snake
		@snake = null
		setTimeout(@spawn, 2100)
		setTimeout(@dead_snake.disposeBody, 1700)
		@score.reset()


class Score
	@extend BaseObject

	constructor: (player) ->
		@i = 0
		@player = player

	add: (n) ->
		@i += n
		if @i >= game.winningScore
			game.declareWinner(@player)

	reset: ->
		@i = 0

	toString: -> @i


class HUD
	@extend Renderer

	constructor: () ->
		@supers()
		@labels = []

	render: (ctx) ->
		for l in @labels
			l.render(ctx)

	add: (label) ->
		@labels.push(label)


class Label
	@extend BaseObject
	@extend Renderable
	@extend Position

	constructor: (text, pos, font="bold 20px sans-serif", align="center", colour="#FFFFFF", stroke=false) ->
		@supers
		@text = text
		@Position(pos)
		@font = font
		@align = align
		@colour = colour
		@stroke = stroke

	render: (ctx) ->
		ctx.font = @font
		ctx.textAlign = @align
		ctx.fillStyle = @colour
		ctx.fillText(@text, @position.x, @position.y)
		if @stroke
			ctx.lineWidth = 2
			ctx.strokeStyle = @stroke
			ctx.strokeText(@text, @position.x, @position.y)