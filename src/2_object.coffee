GameObject = (position, terrain, velocity = new Vector(0, 0)) ->
	this.position = position
	this.terrain = terrain
	this.velocity = velocity	# velocity: pixels per second
	this.junnaus = 0
	GameObject.objects.push(this)
	return

GameObject.objects = []
GameObject.toBeDestroyed = []

GameObject.update = ->
	if GameObject.toBeDestroyed.length > 0
		GameObject.performDestroy()
	for object in GameObject.objects
		object.update()

GameObject.performDestroy = ->
	for deadObject in GameObject.toBeDestroyed
		for index, object of GameObject.objects
			if object == deadObject
				break
		GameObject.objects.splice(index, 1)
	GameObject.toBeDestroyed = []

GameObject.render = (ctx) ->
	object.render(ctx) for object in GameObject.objects

GameObject::render = (ctx) ->
	throw ("This method has to be implemented!")

GameObject::update = ->
	this.move()

GameObject::move = (displacement) ->
	if this.junnaus > 2
		alert "haistakaa vittu ku junnaa pahasti"
	unless displacement?	
		displacement = this.velocity.scaledBy game.delta_time	# Normally, the displacement moved equals to object velocity.
	target_position = this.position.plus displacement
	[hit_coords, last_safe] = this.terrain.lineHit(this.position, target_position)
	if not hit_coords							# Nothing but empty space here! Let's move ahead.
		this.position = target_position
		this.junnaus = 0
#		debug.clear()
	else										# Land a-hoy! A collision!
		surface_normal = this.terrain.detectCurvature(last_safe, hit_coords)
		surplus_displacement = target_position.floor().minus last_safe
		unless last_safe.equals this.position	# In the common case, let's move as far as we can without colliding into anything.
			this.position = last_safe
			displacement = this.bounce(surface_normal, surplus_displacement)
#			debug.color = RED
#			debug.plot(last_safe)
#			debug.color = GREEN
#			debug.plot(hit_coords)
		else									# BUT if there wasn't any open space before the colliding pixel...
			this.junnaus++
			tip_of_normal = hit_coords.plus surface_normal
			[root_of_normal, last_solid_pixel] = this.terrain.lineHit(hit_coords.plus(HALF_PIXEL), tip_of_normal.plus(HALF_PIXEL), reverse=true)
#			debug.color = WHITE
#			debug.plot(tip_of_normal)
#			debug.plot(root_of_normal)
#			debug.demo(this)
#			console.log "junnnaa. root of normal"	# the odds are high, that the reflected displacement will lead us inside a solid rock.
#			console.log root_of_normal
#			alert("jun jun")
			this.position = root_of_normal	# So let's move to the point where the normal vector start, as it's usually more open
#			displacement = displacement.minus this.position.minus last_safe # that movement is subtracted from displacement
			if this.junnaus > 1
				console.log "Last safe position: "
				console.log last_safe
				console.log "Surplus displacement: "
				console.log surplus_displacement
				console.log "After refl. Next displacement: "
				console.log displacement
				console.log "velocity: "
				console.log this.velocity
#				debug.demo(this)
				alert("jun jun 2")
		this.move(displacement)

GameObject::bounce = (surface_normal, surplus_displacement) ->
	this.velocity = this.velocity.reflectWith surface_normal
	return displacement_reflection = surplus_displacement.reflectWith surface_normal

GameObject::render = (ctx) ->
	throw("This needs to be implemented!")

GameObject::destroy = ->
	this.destroyed = true
	GameObject.toBeDestroyed.push(this)