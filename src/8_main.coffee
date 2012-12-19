window.requestAnimFrame = ( ->				# for cross-browser compability
	return ( window.requestAnimationFrame	|| 
		window.webkitRequestAnimationFrame	|| 
		window.mozRequestAnimationFrame		|| 
		window.oRequestAnimationFrame		|| 
		window.msRequestAnimationFrame		|| 
		(callback, element) ->
			window.setTimeout(callback, 1000 / 60)
		)
)()

### Constant values ###
LEFT = 37
UP = 38
RIGHT = 39
DOWN = 40
SPACE = 32
ENTER = 13
A = 65

CANVAS_WIDTH = 160
CANVAS_HEIGHT = 120

ZERO_VECTOR = {x:0, y:0}
HALF_PIXEL = {x:0.5, y:0.5}

RED = "#FF0000"
GREEN = "#00FF00"
BLUE = "#0000FF"
CYAN = "#00FFFF"
MAGENTA = "#FF00FF"
YELLOW = "#FFFF00"
WHITE = "#FFFFFF"
BLACK = "#000000"



### Debug: a canvas for drawing overlay debug information, graphs etc. ###

Debug = (w, h) ->
	super(w, h)

Debug extends Canvas

Debug::demo = (bullet) ->
	this.color = RED
	bullet.demo = true
	this.plot(bullet.position)
	camera.focusTo(bullet.position)
	this.drawArrow(bullet.position, bullet.velocity)
	render()


### game: a container object for the basic game logic ###

game = (canvas_container) ->


	### Runtime logic ###

	keys = {}

	commands = ( -> 
		cmd = {}
		cmd[UP] = -> player.acc(0.18)
		cmd[DOWN] = -> player.dec(0.18)
		cmd[LEFT] = -> player.rotate(-0.06)
		cmd[RIGHT] = -> player.rotate(0.06)
		cmd[SPACE] = -> player.shoot()
		cmd[ENTER] = -> player.velocity = {x:0, y:0}
		cmd[A] = -> debug.clear()
#	->
#			window.joo = true
#			for x in [-10..10]
#				for y in [-10..10]
#					terrain.lineHit(150+(x*12), 150+(y*12), 150+(x*12)+x, 150+(y*12)+y)
		return cmd
		)()

	logic = ->
		action() for key, action of commands when keys[key]
		
		GameObject.update()
		cam.focusTo(player.position);

	render = ->
		ctx.save()
		ctx.clearRect(0,0, CANVAS_WIDTH, CANVAS_HEIGHT);
		terrain.render(ctx, cam)
		ctx.translateRound(-cam.position.x, -cam.position.y)
		GameObject.render(ctx)
#		debug.render(ctx, cam)
		ctx.restore()

	tick = ->
		logic()
		render()
		requestAnimFrame(tick)



	### Initialization ###

	document.addEventListener("keydown", ((eventInfo) -> keys[eventInfo.which] = true), false)
	document.addEventListener("keyup", ((eventInfo) -> keys[eventInfo.which] = false), false)

#	canvas = new Canvas(CANVAS_WIDTH, CANVAS_HEIGHT, canvas_container)
	canvas = document.createElement("canvas")
	canvas.width = CANVAS_WIDTH
	canvas.height = CANVAS_HEIGHT
	ctx = canvas.getContext("2d")
	ctx.imageSmoothingEnabled = false
	canvas_container.appendChild(canvas)

	ctx.translateRound = (x, y) ->
		this.translate(Math.floor(x), Math.floor(y))

	loader = loader(tick)
	loader.asyncWaitForLoading(game)

	terrain = new Terrain("img/terrain2.png", 1400, 1000)
	debug = new Debug(terrain.width, terrain.height)
	player = new Ship({x: 20, y: 100}, terrain)
	cam = new Camera({x: 60, y: 60}, CANVAS_WIDTH, CANVAS_HEIGHT, terrain)



	game.onload()					## So the game is ready to run.

	return [debug, render, cam]

debug = null
render = null
camera = null



$(document).ready( ->
	container = document.getElementById("shinkuunotsubasa")
	[debug, render, camera] = game(container)
)