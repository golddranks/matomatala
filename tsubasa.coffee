window.requestAnimFrame = ( ->
	return ( window.requestAnimationFrame	|| 
		window.webkitRequestAnimationFrame	|| 
		window.mozRequestAnimationFrame		|| 
		window.oRequestAnimationFrame		|| 
		window.msRequestAnimationFrame		|| 
		(callback, element) ->
			window.setTimeout(callback, 1000 / 60)
		)
)()

# Constant values for key codes
left = 37
up = 38
right = 39
down = 40
space = 32
enter = 13
a = 65

canvas_width = 320
canvas_height = 240

Terrain = window.Terrain

Ship = (x, y) ->
	this.x = x
	this.y = y
	this.dx = 0
	this.dy = 0
	this.rot = 0
	this.width = 16
	this.height = 16
	this.xAnimOffset = Math.round(-0.5 * this.width)
	this.yAnimOffset = Math.round(-0.5 * this.height)
	this.loadingBullet = 0
	this.img = new Image()
	game.waitForLoading(this.img)
	this.img.src = "img/v.png"
	Ship.ships.push(this)

Ship.ships = []

Ship.render = (c) ->
	ship.render(c) for ship in Ship.ships

Ship.update = ->
	for ship in Ship.ships
		ship.move()
		ship.hit()
		ship.loadingBullet--

Ship.prototype.render = (c) ->
	c.save()
	c.translateRound(this.x, this.y)
	c.rotate(this.rot)
	c.drawImage(this.img, this.xAnimOffset, this.yAnimOffset);
	c.restore()

Ship.prototype.acc = (amount) ->
	this.dx += Math.sin(this.rot) * amount
	this.dy -= Math.cos(this.rot) * amount

Ship.prototype.dec = (amount) ->
	this.dx += Math.sin(this.rot) * -amount
	this.dy -= Math.cos(this.rot) * -amount

Ship.prototype.rotate = (amount) ->
	this.rot += amount 

Ship.prototype.move = ->
	this.x += this.dx
	this.y += this.dy

Ship.prototype.shoot = ->
	if this.loadingBullet <= 0
		new Bullet(this.x, this.y, this.dx, this.dy, 10, this.rot)
		this.loadingBullet = 10

Ship.prototype.getSpeed = ->
	Math.sqrt(Math.pow(this.dx, 2) + Math.pow(this.dy, 2))

Ship.prototype.hit = ->
	coord = game.terrain.lineHit(this.x - this.dx, this.y-this.dy, this.x, this.y)
	if coord
		vect = game.terrain.detectCurvature(coord[0], coord[1])
		this.bounce(vect[0], vect[1])

Ship.prototype.bounce = (dx, dy) ->
	this.dx = dx/8
	this.dy = dy/8
	this.move()

Camera = (x, y, viewport_width, viewport_height) ->
	this.x = x
	this.y = y
	this.width = viewport_width
	this.height = viewport_height

Camera.prototype.focusTo = (x,y) ->
	x = x - (this.width/2)
	if x < 0
		x = 0
	if x+this.width > game.terrain.width
		x = game.terrain.width - this.width
	y = y - (this.height/2)
	if y < 0
		y = 0
	if y+this.height > game.terrain.height
		y = game.terrain.height - this.height
	this.x = x
	this.y = y

Camera.prototype.setFocus = ->
	game.cam = this

Bullet = (x, y, dx, dy, speed, dir) ->
	this.x = x
	this.y = y
	this.dx = dx + Math.sin(dir) * speed
	this.dy = dy + -Math.cos(dir) * speed
	Bullet.bullets.push(this)
	this.hit(game.c)
	Bullet.performDestroy()

Bullet.bullets = []
Bullet.toBeDestroyed = []

Bullet.update = (c) ->
	for bullet in Bullet.bullets
		bullet.move()
		bullet.hit(c)
		bullet.clean()
	if Bullet.toBeDestroyed.length > 0
		this.performDestroy()

Bullet.performDestroy = ->
	for deadBullet in Bullet.toBeDestroyed
		for index, bullet of Bullet.bullets
			if bullet == deadBullet
				break
		Bullet.bullets.splice(index, 1)
	Bullet.toBeDestroyed = []


Bullet.render = (c) ->
	bullet.render(c) for bullet in Bullet.bullets

Bullet.prototype.move = ->
	this.x += this.dx
	this.y += this.dy

Bullet.prototype.render = (c) ->
	c.beginPath()
	c.strokeStyle = "rgb(255,255,255)"
	c.moveTo(Math.round(this.x)+0.5, Math.round(this.y)+0.5)
	c.lineTo(Math.round(this.x+this.dx)+0.5, Math.round(this.y+this.dy)+0.5)
	c.stroke()

Bullet.prototype.hit = (c) ->
	if coords = game.terrain.lineHit(this.x-this.dx, this.y-this.dy, this.x, this.y)
		this.destroy()
		game.terrain.blow(coords[0], coords[1], 4)

Bullet.prototype.clean = ->
	if this.x < 0
		this.destroy()
		return
	if this.y < 0
		this.destroy()
		return
	if this.x > game.terrain.width
		this.destroy()
		return
	if this.y > game.terrain.height
		this.destroy()
		return

Bullet.prototype.destroy = ->
	Bullet.toBeDestroyed.push(this)

game = {
	keys: {}

	render: ->
		game.c.save()
		game.c.clearRect(0,0,canvas_width,canvas_height);
		game.terrain.render(game.c, game.cam)
		game.c.translateRound(-game.cam.x, -game.cam.y)
		Ship.render(game.c)
		Bullet.render(game.c)
		game.c.drawImage(game.debug, 0, 0);
		game.c.restore()

	commands: ( -> 
		cmd = {}
		cmd[up] = -> game.player.acc(0.18)
		cmd[down] = -> game.player.dec(0.18)
		cmd[left] = -> game.player.rotate(-0.06)
		cmd[right] = -> game.player.rotate(0.06)
		cmd[space] = -> game.player.shoot()
		cmd[enter] = -> game.player.dx = 0; game.player.dy = 0;
#		cmd[a] = -> Bullet.update(game.c); game.keys[a] = false
		return cmd
		)()

	logic: ->
		action() for key, action of game.commands when game.keys[key]
		
		Ship.update()
		Bullet.update(game.c)
		game.cam.focusTo(game.player.x, game.player.y);

	tick: ->
		game.logic()
		game.render()
		requestAnimFrame(game.tick)

	waitList: [] ## The list of objects that need to be marked ready

	waitForLoading: (object, callback) ->	## Param object: wait for this object to load
											## Param callback: this callback is run when object is loaded
		this.waitList.push(object)
		object.ready = false
		object.onload = ->
			object.ready = true
			if callback?
				callback(object)
			game.runIfReady()

	runIfReady: -> ## Polls whether all objects are loaded and the game is ready to start
		return false for object in this.waitList when not object.ready
		this.tick(); ## If all objects were loaded, do the first tick!

	init: ->
		game.waitForLoading(game)
		game.player = new Ship(20,100)
		game.player.rotate((Math.PI/2))
		game.terrain = new Terrain("img/terrain1.png", 700, 500, this)
		game.debug = document.createElement('canvas') # TODO debuggausta varten
		game.debug.width = game.terrain.width
		game.debug.height = game.terrain.height
		game.d_ctx = game.debug.getContext("2d")
		game.cam = new Camera(60, 60, canvas_width, canvas_height)
		game.ready = true
		game.onload() ## So the game is ready to run.

}

$(document).ready( ->
	canvas = document.createElement("canvas")
	canvas.width = canvas_width
	canvas.height = canvas_height
	game.c = canvas.getContext("2d")
	game.c.imageSmoothingEnabled = false
	game.c.translateRound = (x, y) ->
		game.c.translate(Math.round(x), Math.round(y))
	document.getElementById("shinkuunotsubasa").appendChild(canvas)
	$(document).keydown((eventInfo) -> game.keys[eventInfo.which] = true)
	$(document).keyup((eventInfo) -> game.keys[eventInfo.which] = false)
	game.init()
)