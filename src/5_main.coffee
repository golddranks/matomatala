CANVAS_WIDTH = 400
CANVAS_HEIGHT = 400


game = ->


	### Pre-initialization ###

	container = document.getElementById("game_area")
	game.context = prepareCanvas(container)

	commands = {}
	commands[UP] = -> game.playerA.up()
	commands[DOWN] = -> game.playerA.down()
	commands[LEFT] = -> game.playerA.left()
	commands[RIGHT] = -> game.playerA.right()
	commands[W] = -> game.playerB.up()
	commands[S] = -> game.playerB.down()
	commands[A] = -> game.playerB.left()
	commands[D] = -> game.playerB.right()
	commands[Y] = -> Yaoi.run()
	commands[R] = -> initMenu()


	### Game initialization ###

	initMenu = ->
		Destructable.annihilateEverything()
		game.winningScore = 20
		game.speedMultiplier = 1

		game.playerA = new Player(200, 200, "Jäbä")
	
		game.cam = new Camera()
		game.hud = new HUD()

		bg = new Background()

		wall1 = new Wall(new Vector(200, 8), new Vector(400, 16), 1) # SEINÄT ON LUOTAVA ENNEN NAMUA!!!!
		wall2 = new Wall(new Vector(200, 392), new Vector(400, 16), 1)
		wall3 = new Wall(new Vector(8, 200), new Vector(16, 400), 1)
		wall4 = new Wall(new Vector(392, 200), new Vector(16, 400), 1)

		game.playerA.spawn()

		Bookkeeping.bookCreated()

		new MenuNamu(initTwoPlayerGame)
		new MenuNamu(initOnePlayerGame)

		l = new Label("Mato", new Vector(50, 50), "bold 20px sans-serif")
		game.hud.add(l)
		l = new Label("matalan", new Vector(100, 70), "bold 30px sans-serif")
		game.hud.add(l)
		l = new Label("touhukas", new Vector(150, 100), "bold 50px sans-serif")
		game.hud.add(l)
		l = new Label("maailma!", new Vector(405, 420), "bold 170px sans-serif")
		game.hud.add(l)
		l = new Label("'R' resettaa pelin.", new Vector(100, 111), "bold 10px sans-serif")
		game.hud.add(l)
		l = new Label("© Pyry Kontio / @GolDDranks", new Vector(380, 27), "bold 10px sans-serif", "right")
		game.hud.add(l)

		Bookkeeping.bookCreated()

		game.ticker.launch()



	initTwoPlayerGame = ->
		Destructable.annihilateEverything()

		game.winningScore = 20
		game.speedMultiplier = 1

		game.playerA = new Player(200, 50, "Ylämato")
		game.playerB = new Player(200, 350, "Alamato")
	
		game.cam = new Camera()
		game.hud = new HUD()
		game.hud.add(new Label(game.playerA.score, new Vector(20, 13), "bold 12px sans-serif", "left"))
		game.hud.add(new Label(game.playerB.score, new Vector(20, 396), "bold 12px sans-serif", "left"))

		bg = new Background()

		wall1 = new Wall(new Vector(200, 8), new Vector(400, 16), 1) # SEINÄT ON LUOTAVA ENNEN NAMUA!!!!
		wall2 = new Wall(new Vector(200, 392), new Vector(400, 16), 1)
		wall3 = new Wall(new Vector(8, 200), new Vector(16, 400), 1)
		wall4 = new Wall(new Vector(392, 200), new Vector(16, 400), 1)

		Bookkeeping.bookCreated()	# Seinät kohdallaan ja rekisteröity

		game.playerA.spawn()
		game.playerB.spawn()

		Bookkeeping.bookCreated()	# Madot kohdallaan ja rekisteröity

		new Namu()	# Sitten vasta tehdään noita, ettei ne späwnää minkään päälle
		new Namu()
		new Namu()

		game.ticker.launch()


	initOnePlayerGame = ->
		Destructable.annihilateEverything()

		game.winningScore = 20
		game.speedMultiplier = 1.05

		game.playerA = new Player(200, 200, "Jäbä")
	
		game.cam = new Camera()
		game.hud = new HUD()
		game.hud.add(new Label(game.playerA.score, new Vector(20, 13), "bold 12px sans-serif", "left"))

		bg = new Background()

		wall1 = new Wall(new Vector(200, 8), new Vector(400, 16), 1) # SEINÄT ON LUOTAVA ENNEN NAMUA!!!!
		wall2 = new Wall(new Vector(200, 392), new Vector(400, 16), 1)
		wall3 = new Wall(new Vector(8, 200), new Vector(16, 400), 1)
		wall4 = new Wall(new Vector(392, 200), new Vector(16, 400), 1)

		Bookkeeping.bookCreated()	# Seinät kohdallaan ja rekisteröity eka

		game.playerA.spawn()

		Bookkeeping.bookCreated()	# Madot kohdallaan ja rekisteröity eka

		new Namu()
		new Namu()

		game.ticker.launch()

	initOnePlayerGame.title = "一人で"
	initTwoPlayerGame.title = "一対一"


	### Runtime logic ###

	game.declareWinner = (player) ->
		if not game.won?
			game.won = true
			player.snake.delirium()
			Namu.destroyAll()
			l = new Label(player.name + " voitti!", new Vector(200, 180), "bold 40px sans-serif")
			game.hud.add(l)
			l = new Label("'R' resettaa pelin.", new Vector(130, 191), "bold 10px sans-serif")
			game.hud.add(l)

	tick = ->
		processControls(commands)
		Movable.move()
		Destructable.cleanTrash()
		Bookkeeping.bookCreated()



	### Launch ###

	game.ticker = new Ticker(tick)
	gameLoader.runWhenReady(initMenu)



### By this time, the DOM tree should have been loaded ###
game()
