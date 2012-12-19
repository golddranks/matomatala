Bullet = (position, parent_velocity, speed, direction, terrain) ->
	super(position, terrain)
	this.velocity = vectorSum(parent_velocity, createVector(direction, speed))
	this.lifespan = 10
	this.lifestack = [this.position]
	this.renderstack = [this.position]
	return

Bullet extends GameObject

Bullet::update = ->
	this.move()
	this.clean()
#	this.hitTest()

Bullet::move = (displacement) ->
	this.renderstack.push(this.position)
	this.lifestack.push(this.position)
	super(displacement)
	unless this.lifespan < 0
		this.renderstack.push(this.position)
		this.lifestack.push(this.position)

Bullet::bounce = (a, b) ->
	this.lifespan--
	this.renderstack.push(this.position)
	this.lifestack.push(this.position)
	displacement = super(a, b)
#	if this.lifespan < 2
#		this.terrain.blow(this.position, 4)
	return displacement

Bullet::render = (ctx) ->
	stack = this.renderstack
	if this.demo?
		console.log "rendering lifepath"
		stack = this.lifestack
		console.log stack
	ctx.beginPath()
	ctx.strokeStyle = "rgb(255,255,255)"
	start_point = vectorSum(floorVector(stack[0]), HALF_PIXEL)
	ctx.moveTo(start_point.x, start_point.y)
	for coords in stack[1..]
		point = vectorSum(floorVector(coords), HALF_PIXEL)
		ctx.lineTo(point.x, point.y)
	ctx.stroke()
	this.renderstack = [this.position]

Bullet::hitTest = () ->
	[hit_coords, last_safe] = this.terrain.lineHit(this.x, this.y, this.x+this.dx, this.y+this.dy)
	if hit_coords
		this.destroy()
		this.terrain.blow(hit_coords, 4)
		debug.color = MAGENTA
		debug.plot(coords[2][0], coords[2][1])

Bullet::clean = ->
	if this.position.x < 0
		this.destroy()
		return
	if this.position.y < 0
		this.destroy()
		return
	if this.position.x > this.terrain.width
		this.destroy()
		return
	if this.position.y > this.terrain.height
		this.destroy()
		return
	if this.lifespan < 0
#		console.log "life depleted"
		this.destroy()