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

canvas_width = 320
canvas_height = 240


Ship = (x, y) ->
	this.x = x
	this.y = y
	this.dx = 0
	this.dy = 0
	this.rot = 0
	this.img = new Image()
	game.waitForLoading(this.img)
	this.img.src = "img/v.png"
	Ship.ships.push(this)

Ship.ships = []

Ship.render = (c) ->
	ship.render(c) for ship in Ship.ships

Ship.move = ->
	ship.move() for ship in Ship.ships

Ship.prototype.render = (c) ->
	c.save()
	c.translate(this.x, this.y)
	c.rotate(this.rot)
	c.drawImage(this.img, -0.5 * this.img.width, -0.5 * this.img.height	);
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
	new Bullet(this.x, this.y, this.dx, this.dy, this.getSpeed(), this.rot)

Ship.prototype.getSpeed = ->
	Math.sqrt(Math.pow(this.dx, 2) + Math.pow(this.dy, 2))

Terrain = (terrainFileName) ->
	this.img = new Image()
	game.waitForLoading(this.img)
	this.img.src = terrainFileName

Terrain.prototype.render = (c) ->
	c.drawImage(this.img, 0, 0)

Camera = (x, y) ->
	this.x = x
	this.y = y

Camera.prototype.moveTo = (x,y) ->
	this.x = x
	this.y = y

Camera.prototype.setFocus = ->
	game.cam = this

Bullet = (x, y, dx, dy, speed, dir) ->
	this.x = x
	this.y = y
	this.dx = dx + Math.sin(dir) * 10
	this.dy = dy + -Math.cos(dir) * 10
	Bullet.bullets.push(this)

Bullet.bullets = []

Bullet.move = ->
	bullet.move() for bullet in Bullet.bullets

Bullet.render = (c) ->
	bullet.render(c) for bullet in Bullet.bullets

Bullet.prototype.move = ->
	this.x += this.dx
	this.y += this.dy

Bullet.prototype.render = (c) ->
	c.beginPath()
	c.moveTo(this.x-this.dx, this.y-this.dy)
	c.lineTo(this.x, this.y)
	c.stroke()

game = {
	keys: {}

	render: ->
		game.c.save()
		game.c.clearRect(0,0,canvas_width,canvas_height);
		game.c.translate(-game.cam.x+(canvas_width/2), -game.cam.y+(canvas_width/2))
		game.terrain.render(game.c)
		Ship.render(game.c)
		Bullet.render(game.c)
		game.c.restore()

	commands: ( -> 
		cmd = {}
		cmd[up] = -> game.player.acc(0.18)
		cmd[down] = -> game.player.dec(0.18)
		cmd[left] = -> game.player.rotate(-0.06)
		cmd[right] = -> game.player.rotate(0.06)
		cmd[space] = -> game.player.shoot()
		cmd[enter] = -> console.log game.player.getSpeed()
		return cmd
		)()

	logic: ->
		action() for key, action of game.commands when game.keys[key]
			
		Ship.move()
		Bullet.move()
		game.cam.moveTo(game.player.x, game.player.y);

	tick: ->
		game.logic()
		game.render()
		requestAnimFrame(game.tick)

	waitList: []

	waitForLoading: (object) ->
		this.waitList.push(object)
		object.ready = false
		object.onload = ->
			object.ready = true
			game.readyForRun()

	readyForRun: ->
		return false for object in this.waitList when not object.ready
		this.tick();

	init: ->
		game.player = new Ship(100,100)
		game.terrain = new Terrain("img/terrain1.png")
		game.cam = new Camera(60, 60)
		this.readyForRun()

}

$(document).ready( ->
	canvas = document.createElement("canvas")
	canvas.width = canvas_width
	canvas.height = canvas_height
	game.c = canvas.getContext("2d")
	document.getElementById("shinkuunotsubasa").appendChild(canvas)
	$(document).keydown((eventInfo) -> game.keys[eventInfo.which] = true)
	$(document).keyup((eventInfo) -> game.keys[eventInfo.which] = false)
	game.init()
)