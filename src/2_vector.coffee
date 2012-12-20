Vector = (x, y) ->
	this.x = x
	this.y = y

VectorByDirection = (direction, length) ->
	super(Math.sin(direction) * length, -Math.cos(direction) * length)

VectorByDirection extends Vector

Vector::dot = (that) ->
	return ( this.x * that.x ) + ( this.y * that.y )

Vector::plus = (that) ->
	return new Vector(this.x + that.x, this.y + that.y )

Vector::minus = (that) ->
	return new Vector(this.x - that.x, this.y - that.y)

Vector::per = (divisor) ->
	return new Vector(this.x / divisor, this.y / divisor )

Vector::scaledBy = (multiplier) ->
	return new Vector(this.x * multiplier, this.y * multiplier)

Vector::length = ->
	return Math.sqrt( this.x*this.x + this.y*this.y )

Vector::floor = ->
	return new Vector(Math.floor(this.x), Math.floor(this.y))

Vector::unit = ->
	return this.per this.length() 

Vector::toString = ->
	return "x: #{this.x} y: #{this.y}"

Vector::equals = (that) ->
	return (this.x == that.x and this.y == that.y)

Vector::reflectWith = (normal) ->
	normal = normal.unit()
	product = this.dot normal
	unless product > 0	# In normal case, the dot product is negative (the angle between normal and incidence is over 90 degrees)
		reflection = this.minus normal.scaledBy 2*product
	else				# BUT if it happens to be positive, we are having an odd situation.
		reflection = this		# so we just don't reflect it
	return reflection