### Camera: a movable object which points to the centre of the place that is supposed to be "on-screen" ###

Camera = (position, viewport_width, viewport_height, terrain) -> # Params x and y signify the left-top corner
	this.position = position
	this.width = viewport_width
	this.height = viewport_height
	this.terrain = terrain
	return

Camera::focusTo = (coords) ->	# Params x and y signify the point, which is supposed to be at the centre of screen
	x = coords.x - (this.width/2)
	y = coords.y - (this.height/2)
	if x < 0
		x = 0
	if x+this.width > this.terrain.width
		x = this.terrain.width - this.width
	if y < 0
		y = 0
	if y+this.height > this.terrain.height
		y = this.terrain.height - this.height
	this.position = floorVector({x:x, y:y})
