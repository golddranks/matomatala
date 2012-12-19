### loader: keeps list of things that have to load before the game can start ###

loader = (start) ->
	waitList = []					# The list of objects that need to be marked ready

	asyncWaitForLoading = (object, callback) ->	## Param object: wait for this object to load
												## Param callback: this callback is run when object is loaded
		waitList.push(object)
		object.ready = false
		object.onload = ->
			object.ready = true
			if callback?
				callback(object)
			runIfReady()

	runIfReady = ->							## Checks whether all objects are loaded and the game is ready to start
		return false for object in waitList when not object.ready
		start();							## If all objects were loaded, do the first tick!

	return {asyncWaitForLoading: asyncWaitForLoading, runIfReady: runIfReady}