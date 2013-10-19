#	
#	A Coffeescript web browser game engine.
#	Written by Pyry Kontio.
#	Follow me on Twitter! @GolDDranks
#

### EXTEND JAVASCRIPT BASE OBJECT FOR MIXIN SUPPORT ###

# Lisää mixinin ominaisuudet tyypille ja kutsuu mixinin inittiä heti
Object::extend = (mixin) ->	
	for key, value of mixin.prototype when key != 'mixins'
		this.prototype[key] = value
	this::mixins ?= []
	mixin::mixins ?= []
	this::mixins.push.apply(this::mixins, mixin::mixins)
	this::mixins.push(mixin)
	mixin.descendants ?= []
	mixin.descendants.push(this)
	if mixin.init?
		mixin.init(this)

# Lisää mixinin ominaisuudet tyypille, mutta delegoi initin kutsumisen oman initinsä tehtäväksi
Object::include = (mixin) ->
	for key, value of mixin.prototype when key != 'mixins'
		this.prototype[key] = value
	this::mixins ?= []
	mixin::mixins ?= []
	this::mixins.push.apply(this::mixins, mixin::mixins)
	this::mixins.push(mixin)
	this.init = (obj) =>
		for M in this::mixins
			M.descendants ?= []
			if M.descendants.indexOf(obj) is -1
				M.descendants.push(obj)
			if M.init?
				M.init(obj)





### LOADER: keeps list of things that have to be ready before the game "runtime" can start ###

class Loader

	constructor: ->
		@waitForThese = [this]	# The list of objects that need to be marked ready (loader waits for itself too)
		@__readyAndLoaded = false

	runWhenReady: (callback) ->
		this.launcher = callback
		this.__readyAndLoaded = true
		@testIfReady()

	asyncWaitForLoading: (object, callback) ->	## Param object: wait for this object to load
												## Param callback: this callback is run when object is loaded
		@waitForThese.push(object)
		object.__readyAndLoaded = false
		object.onload = =>
			object.__readyAndLoaded = true
			if callback?
				callback(object)
			@testIfReady()

	testIfReady: ->
		return false for object in this.waitForThese when not object.__readyAndLoaded
		this.launcher()							## If all objects were loaded, RUN!

gameLoader = new Loader()



class LoadedImage
	constructor: (src) ->
		@img = new Image()
		gameLoader.asyncWaitForLoading(@img, @loaded)
		@img.src = src

	loaded: =>
		@size = new Vector(@img.width, @img.height)
		@offset = new Vector(-@img.width, -@img.height)
		@offset.scale(0.5)

	toString: -> "LoadedImage "+@img.src+" "+@size+" "+@offset




### KEY CONTROL HELPERS ###

### Constant values ###
LEFT = 37
UP = 38
RIGHT = 39
DOWN = 40
SPACE = 32
ENTER = 13
A = 65
S = 83
D = 68
R = 82
W = 87
Y = 89
X = 88
ONE = 49
TWO = 50

controlActions = []
controlDownEvents = []
controlUpEvents = []

document.addEventListener("keydown", ((eventInfo) -> controlDownEvents.push(eventInfo.which)), false)
document.addEventListener("keyup", ((eventInfo) -> controlUpEvents.push(eventInfo.which)), false)

clearActions = ->
	while controlActions.pop()
		false
	while controlDownEvents.pop()
		false
	while controlUpEvents.pop()
		false

processControls = (commands) ->
	while (e = controlDownEvents.pop())?
		action = commands[e]
		if action? and (controlActions.indexOf(action) is -1)
			controlActions.push(action)

	action() for action in controlActions

	while (e = controlUpEvents.pop())?
		action = commands[e]
		if action?
			index = controlActions.indexOf(action)
			if index isnt -1
				controlActions.splice(index, 1)





### PREPARE CANVAS ###

prepareCanvas = (canvas_container) ->
	canvas = document.createElement("canvas")
	canvas.width = CANVAS_WIDTH
	canvas.height = CANVAS_HEIGHT
	ctx = canvas.getContext("2d")
	canvas_container.appendChild(canvas)
	return ctx




### RUNTIME HELPERS ###

### re-define requestAnimFrame for cross-browser compability ###

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


class Ticker

	constructor: (tick) ->
		@tick_time = new Date().getTime()
		@ticks = 0
		@fps = 0
		@last_fps_update_time = 0
#		setInterval(@updateFPScounter, 500)
		@tick = tick
		@running = false
		@todo = []

	updateFPScounter: =>
		elapsed_time = (new Date().getTime() - @last_fps_update_time)/1000
		@last_fps_update_time = @tick_time
		@fps = Math.round(@ticks/elapsed_time)
		@ticks = 0

	render: ->
		for type in Renderer.descendants
			for r in type::instances
				r.render(game.context)

	stop: ->
		@run = -> console.log("Stopped.")

	launch: ->
		if not @running
			@running = true
			@run()

	doNextTick: (callback) ->
		@todo.push(callback)

	run: =>
		requestAnimFrame(@run)
		@delta_time = (new Date().getTime() - @tick_time)/1000
		if @delta_time > 0.1 # Ehkäisee etteä peli hidastuu eikä harppaa jos fps tippuu alle 10
			@delta_time = 0.1
		@tick_time = new Date().getTime()
		@ticks++
		while d = @todo.pop()
			d()
		@tick()
		@render()
