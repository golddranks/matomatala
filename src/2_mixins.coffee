### Mixins ###

# Mixin lisätään luokkaan komennolla @extend Mixin
# Mixinin property: kopioituvat luokalle mutta @property: eivät.

# Mixineillä on muutama erikoisominaisuus:

# Mixin.init()
# 	Mixinillä voi olla staattinen metodi @init, jota @extend kutsuu aina kun sitä kutsutaan, siis pelin alustusvaiheessa

# Type::mixins, Instance.mixins
#	Prototyypeillä on aina lista mixins, joka sisältää kaikki mixinit joilla tyyppiä on laajennettu.

# Mixin.descendants
# 	Mixineillä on lista descendants, joka sisältää kaikki tyypit joita mixinillä on laajennettu





# Toteuttaa metodin supers, joka kutsuu mixineiden staattisia metodeita @construct
class Constructable
	
	supers: ->
		for M in @mixins
			if M.construct?
				M.construct(this)
#		console.log("create", @toString(), @id)


# Toteuttaa metodin destroy, joka tuhoaa instanssin ja kutsuu mixineiden staattisia metodeita @destruct
class Destructable

	@construct: (instance) ->
		instance.__destroyed = false

	@destroyThese = []

	@cleanTrash = ->
		while deadObject = @destroyThese.pop()
#			console.log("purge", deadObject.toString(), deadObject.id)
			for M in deadObject.mixins
				if M.destruct?
					M.destruct(deadObject)

	destroy: ->
		this.__destroyed = true
		Destructable.destroyThese.push(this)
#		console.log("destroy", @toString(), @id)

	@annihilateEverything: ->
		for type in Destructable.descendants
			for i in type::instances
				i.destroy()
		Destructable.cleanTrash()
		clearActions()


# Toteuttaa kirjanpidon, jossa prototyypillä on aina lista instances siitä luoduista instansseista
class Bookkeeping
	
	@base_typeid = 1000

	@init: (type) ->
		type::created = []
		type::instances = []
		type::ids = {typeid: @base_typeid, base_instanceid: @base_typeid+1}
		@base_typeid += 1000

	@bookCreated: ->
		for bookType in @descendants
			while instance = bookType::created.pop()
				bookType::instances.push(instance)
				instance.__new = false
#				console.log("booked", instance.toString(), instance.id)

	@construct: (instance) ->
		instance.created.push(instance)
		instance.__new = true
		instance.id = instance.ids.base_instanceid
		instance.ids.base_instanceid++

	@destruct: (instance) ->
		if instance.__new
			if (index = instance.created.indexOf(instance)) > -1
				instance.created.splice(index, 1)
		else
			if (index = instance.instances.indexOf(instance)) > -1
				instance.instances.splice(index, 1)


# Alla muita mixineitä jotka toteuttavat peliobjektien ominaisuuksia

class Position

	Position: (x, y) ->
		if y?
			@moveTo(new Vector(x, y))
		else
			@moveTo(x) # x = position

	moveTo: (position) ->
		@position = position
		if @size?
			@update_edges()

class Renderable
	
	@construct: (instance) ->
		if instance.image?
			instance.render_img = instance.image

	Renderable: (img) ->
		@render_img = img

	render: (ctx) ->
		ctx.save()
		ctx.translate(@position.x, @position.y)
		ctx.drawImage(@render_img.img, @render_img.offset.x, @render_img.offset.y)
		ctx.restore()


class Size

	Size: (w, h) ->
		if h?
			@size = new Vector(w, h)
		else
			@size = w	# w on size
		@edge =
			left: null
			right: null
			top: null
			bottom: null
		@update_edges()

	update_edges: ->
		half_x = @size.x/2
		half_y = @size.y/2
		@edge.left = @position.x - half_x
		@edge.right = @position.x + half_x
		@edge.top = @position.y - half_y
		@edge.bottom = @position.y + half_y


class Collision

	@init: (type) ->
		if type::mixins.indexOf(Size) == -1
			throw("Objektilla on oltava koko!" + type::toString())

	bbox_collision: (that) ->
		if (this.edge.right > that.edge.left) and (this.edge.left < that.edge.right)
			if (this.edge.top < that.edge.bottom) and (this.edge.bottom > that.edge.top)
				return that
		return false

	collidesAny: (objects) ->
		for obj in objects
			if obj is this
				continue
			result = @bbox_collision(obj)
			if result
				return result
		return false

	collidesAll: (objects) ->
		colliders = []
		for obj in objects
			if obj is this
				continue
			result = @bbox_collision(obj)
			if result
				colliders.push(result)
		return colliders

class Movable

	@construct: (instance) ->
		instance.velocity = new Vector(0, 0)
		instance.speed = 0

	move: ->
		if @speed > 0
			@position.increment(@velocity.times(game.ticker.delta_time))
			if @update_edges?
				@update_edges()

	setVelocity: (x, y) ->
		if y?
			@velocity = new Vector(x, y)
		else
			@velocity = x
		@speed = @velocity.length()

	accelerate: (x, y) ->
		@velocity.increment(new Vector(x, y))
		@speed = @velocity.length()

	@move: ->
		for movingType in @descendants
			for mover in movingType::instances
				mover.move()



### Let's collect 'em together. ###

class BaseObject
	@include Constructable
	@include Destructable
	@include Bookkeeping

class PhysicalObject
	@include BaseObject
	@include Renderable
	@include Position
	@include Size
	@include Collision

class Renderer
	@include Constructable
	@include Destructable
	@include Bookkeeping

