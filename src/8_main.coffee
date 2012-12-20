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

CANVAS_WIDTH = 320
CANVAS_HEIGHT = 240

NULL_VECTOR = new Vector(0, 0)
HALF_PIXEL = new Vector(0.5, 0.5)

FULL_ARC = Math.PI*2

RED = "#FF0000"
GREEN = "#00FF00"
BLUE = "#0000FF"
CYAN = "#00FFFF"
MAGENTA = "#FF00FF"
YELLOW = "#FFFF00"
WHITE = "#FFFFFF"
BLACK = "#000000"



### Debug: a canvas for drawing overlay debug information, graphs etc. ###

Debug = (width, height) ->
	super(width, height)
	this.color = RED

Debug extends Canvas

Debug::demo = (bullet) ->
	this.color = RED
	bullet.demo = true
	this.plot(bullet.position)
	camera.focusTo(bullet.position)
	this.drawArrow(bullet.position, bullet.velocity)
	render()

Debug::showLines = ->
	for x in [-10..10]
		for y in [-10..10]
			terrain.lineHit(150+(x*12), 150+(y*12), 150+(x*12)+x, 150+(y*12)+y)


### game: a container object for the basic game logic ###

game = (canvas_container) ->


	### Runtime logic ###

	keys = {}

	commands = ( -> 
		cmd = {}
		cmd[UP] = -> player.acc(150)
		cmd[DOWN] = -> player.dec(150)
		cmd[LEFT] = -> player.rotate(-3)
		cmd[RIGHT] = -> player.rotate(3)
		cmd[SPACE] = -> player.shoot()
		cmd[ENTER] = -> player.velocity = NULL_VECTOR
		cmd[A] = -> debug.clear()
		return cmd
		)()

	logic = ->
		action() for key, action of commands when keys[key]
		
		GameObject.update()
		cam.focusTo(player.position);

	render = ->
		cam.render(ctx)
#		debug.render(ctx, cam)
		ctx.fillStyle = "#FFFFFF"
		ctx.fillText(game.fps,10,10);
		ctx.fillText(player.velocity,10,30);
		
	updateFPS = ->
		elapsed_time = (new Date().getTime() - game.last_fps_update_time)/1000 # convert ms to seconds
		game.last_fps_update_time = game.tick_time
		game.fps = Math.round(game.elapsed_tick_count/elapsed_time)
		game.elapsed_tick_count = 0

	tick = ->
		requestAnimFrame(tick)
		game.delta_time = (new Date().getTime() - game.tick_time)/1000
		game.tick_time = new Date().getTime()
		game.elapsed_tick_count++
		logic()
		render()

	### Initialization ###

	document.addEventListener("keydown", ((eventInfo) -> keys[eventInfo.which] = true), false)
	document.addEventListener("keyup", ((eventInfo) -> keys[eventInfo.which] = false), false)

#	canvas = new Canvas(CANVAS_WIDTH, CANVAS_HEIGHT, canvas_container)
	canvas = document.createElement("canvas")
	canvas.width = CANVAS_WIDTH
	canvas.height = CANVAS_HEIGHT
	ctx = canvas.getContext("2d")
	ctx.imageSmoothingEnabled = false
	ctx.webkitImageSmoothingEnabled = false
	canvas_container.appendChild(canvas)

	ctx.translateRound = (x, y) ->
		this.translate(Math.floor(x), Math.floor(y))

	loader = loader(tick)
	loader.asyncWaitForLoading(game)

	terrain = new Terrain("img/terrain2.png", new Vector(1400, 1000))
#	debug = new Debug(terrain.width, terrain.height)
	player = new Ship(new Vector(20, 100), terrain)
	cam = new Camera(new Vector(CANVAS_WIDTH, CANVAS_HEIGHT), terrain)

	game.tick_time = new Date().getTime()
	game.elapsed_tick_count = 0
	game.fps = 0
	game.last_fps_update_time = 0
	setInterval(updateFPS, 500)

	game.onload()					## So the game is ready to run.

	return [debug, render, cam]

debug = null
render = null
camera = null



$(document).ready( ->
	container = document.getElementById("shinkuunotsubasa")
	[debug, render, camera] = game(container)
)