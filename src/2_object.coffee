dotProduct = (a,b) ->
	return ( a.x * b.x ) + ( a.y * b.y )

vectorSum = (a,b) ->
	return {x: ( a.x + b.x ), y: ( a.y + b.y )}

vectorDifference = (a,b) ->
	return {x: ( a.x - b.x ), y: ( a.y - b.y )}

vectorQuotient = (a,divisor) ->
	return {x: ( a.x / divisor ), y: ( a.y / divisor )}

vectorScale = (a,multiplier) ->
	return {x: a.x * multiplier, y: a.y * multiplier }

vectorLength = (a) ->
	return Math.sqrt( a.x*a.x + a.y*a.y )

floorVector = (a) ->
	return {x: Math.floor(a.x), y: Math.floor(a.y)}

vectorEqual = (a, b) ->
	if a.x == b.x and a.y == b.y
		return true
	else
		return false

unitVector = (a) ->
	return vectorQuotient(a, vectorLength(a)) 

createVector = (direction, length) ->
	return {x: Math.sin(direction) * length, y: -Math.cos(direction) * length}

reflectVector = (normal, incidence, bullet) ->
	normal = unitVector(normal)
	product = dotProduct(normal, incidence)
	unless product > 0	# In normal case, the dot product is negative (the angle between normal and incidence is over 90 degrees)
		reflection = vectorDifference(incidence, vectorScale(normal, 2*product))
	else				# BUT if it happens to be positive, we are having an odd situation.
		reflection = incidence		# so we just don't reflect it
		debug.demo(bullet)
		alert("kiven sisästä TODO")
	return reflection

GameObject = (position, terrain, velocity = {x: 0, y: 0}) ->
	this.position = position
	this.terrain = terrain
	this.velocity = velocity
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

aa = {x:1, y:1}
bee = {x:1, y:1}

GameObject::move = (displacement = this.velocity) ->
	if this.junnaus > 2
		alert "haistakaa vittu ku junnaa pahasti"
	target_position = vectorSum(this.position, displacement)
	[hit_coords, last_safe] = this.terrain.lineHit(this.position, target_position)
	if not hit_coords							# Nothing but empty space here! Let's move ahead.
		this.position = target_position
		this.junnaus = 0
		debug.clear()
	else										# Land a-hoy! A collision!
		surface_normal = this.terrain.detectCurvature(last_safe)
		surplus_displacement = vectorDifference(floorVector(target_position), last_safe)
		unless vectorEqual(last_safe, this.position) # In the common case, let's move as far as we can without colliding into anything.
			this.position = last_safe
			displacement = this.bounce(surface_normal, surplus_displacement)
			debug.color = RED
			debug.plot(last_safe)
			debug.color = GREEN
			debug.plot(hit_coords)
		else								# BUT if there wasn't any open space before the colliding pixel...
			this.junnaus++
			tip_of_normal = vectorSum(hit_coords, surface_normal)
			[root_of_normal, last_solid_pixel] = this.terrain.lineHit(hit_coords, tip_of_normal, reverse=true)
			debug.color = WHITE
			debug.plot(tip_of_normal)
			debug.plot(root_of_normal)
#			debug.demo(this)
#			console.log "junnnaa. root of normal"	# the odds are high, that the reflected displacement will lead us inside a solid rock.
#			console.log root_of_normal
#			alert("jun jun")
			this.position = root_of_normal	# So let's move to the point where the normal vector start, as it's usually more open
#			displacement = vectorDifference(displacement, vectorDifference(this.position, last_safe)) # that movement is subtracted from displacement
			if this.junnaus > 1
				console.log "Last safe position: "
				console.log last_safe
				console.log "Surplus displacement: "
				console.log surplus_displacement
				console.log "After refl. Next displacement: "
				console.log displacement
				console.log "velocity: "
				console.log this.velocity
				debug.demo(this)
				alert("jun jun 2")
		this.move(displacement)

GameObject::bounce = (surface_normal, surplus_displacement) ->
	this.velocity = reflectVector(surface_normal, this.velocity, this)
	return displacement_reflection = reflectVector(surface_normal, surplus_displacement, this)


GameObject::render = (ctx) ->
	throw("This needs to be implemented!")

GameObject::destroy = ->
	this.destroyed = true
	GameObject.toBeDestroyed.push(this)