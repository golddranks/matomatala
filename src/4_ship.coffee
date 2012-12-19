Ship = (position, terrain) ->
	super(position, terrain)
	this.rotation = 0
	this.width = 16
	this.height = 16
	this.xAnimOffset = Math.round(-0.5 * this.width)
	this.yAnimOffset = Math.round(-0.5 * this.height)
	this.loadingBullet = 0
	this.img = new Image()
	loader.asyncWaitForLoading(this.img)
	this.img.src = "img/v.png"
	return

Ship extends GameObject

Ship::update = ->
	this.move()
	this.loadingBullet--

Ship::render = (ctx) ->
	ctx.save()
	ctx.translateRound(this.position.x, this.position.y)
	ctx.rotate(this.rotation)
	ctx.drawImage(this.img, this.xAnimOffset, this.yAnimOffset);
	ctx.restore()

Ship::acc = (amount) ->
	acceleration = createVector(this.rotation, amount)
	this.velocity = vectorSum(this.velocity, acceleration)

Ship::dec = (amount) ->
	acceleration = createVector(this.rotation, -amount)
	this.velocity = vectorSum(this.velocity, acceleration)

Ship::rotate = (amount) ->
	this.rotation += amount 

Ship::shoot = ->
	if this.loadingBullet <= 0
		new Bullet(this.position, this.velocity, 40, this.rotation, this.terrain)
		this.loadingBullet = 10
