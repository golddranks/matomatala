class Vector
	constructor: (x, y) ->
		@x = x
		@y = y
		return this



	### WITH SIDE-EFFECTS ###

	increment: (that) ->
		@x = @x + that.x
		@y = @y + that.y
		return this

	decrement: (that) ->
		@x = @x - that.x
		@y = @y - that.y
		return this

	scale: (scalar) ->
		@x *= scalar
		@y *= scalar
		return this



	### WITHOUT SIDE-EFFECTS ###

	plus: (that) ->
		new Vector(@x + that.x, @y + that.y)

	minus: (that) ->
		new Vector(@x - that.x, @y - that.y)

	per: (scalar) ->
		new Vector(@x / scalar, @y / scalar)

	times: (scalar) ->
		new Vector(@x * scalar, @y * scalar)

	clone: ->
		new Vector(@x, @y)

	length: ->
		return Math.sqrt( @x * @x  +  @y * @y )

	floor: ->
		new Vector(Math.floor(@x), Math.floor(@y))

	unit: ->
		return this.per this.length() 

	toString: ->
		return "x: #{@x} y: #{@y}"

	equals: (that) ->
		return (@x == that.x and @y == that.y)