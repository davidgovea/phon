
#automation.coffee

class Particle
	constructor: (@row, @col, @state, @direction, lifetime) ->
		@lifetime = lifetime ? 200
	excited: 0
	excite:	-> @excited	= 1
	decay: -> @excited	= 0
	kill: -> @lifetime	= 0
	move: ->
		if @state is 1							# On a standard cell
			unless @excited						# Normal Horiz/Vert particle
				switch @direction
					when 1 then @col++
					when 2 then @row++
					when 4 then @col--
					when 8 then @row--
					else throw new Error "Don't know where to go! Normal particle: [#{@row},#{@col}], direction #{@direction}"
			else								# Energetic particle
				switch @direction	
					when 1 then
					when 4 then @col--
					when 16 
						@row--
						@col--
					when 64 then @row--
					else throw new Error "Don't know where to go! Energetic particle, normal space: [#{@row},#{@col}], direction #{@direction}"
				@state = 2						# Move into high-energy
		else 									# On a high-energy cell
			switch @direction
				when 1
					@row++
					@col++
				when 4 then @row++
				when 16 then
				when 64 then @col++
			@state = 1							# Moving back to standard cell
		
		if @lifetime > 0 then @lifetime--		# Reduce lifetime by 1, unless lifetime=-1
			
	reverse: ->
		unless @excited
			@direction = @direction << 2
			if @direction > 8 then @direction = @direction >> 4
		else
			@direction = @direction << 4
			if @direction > 64 then @direction = @direction >> 8

	checkObstacles: ->
		unless @excited
			if (@row is 1 and @direction is 8) or
			(@row is NUM_ROWS and @direction is 2) or
			(@col is 1 and @direction is 4) or
			(@col is NUM_COLS and @direction is 1)
				@reverse()						# Grid boundary detection, normal particles
		else if @state is 1
			if (@row is 1 and (@direction is 16 or @direction is 64)) or
			(@row is NUM_ROWS and (@direction is 1 or @direction is 4)) or
			(@col is 1 and (@direction is 4 or @direction is 16)) or
			(@col is NUM_COLS and (@direction is 1 or @direction is 64))
				@reverse()						# Grid boundary detection, excited particles	

class Cell
	constructor: (@row, @col, @state) ->
	split: false
	walls: 0 # 1=east, 2=south, 4=west, 8=north
	active: false
	shape: null
	sound: false
	# ckpcw: this addSound method should get called when the client receives a message a new sound has been added
	# the audio stuff should bind to the @sound model property changes
	addSound: (sound) ->
		@sound = sound
	# ckpcw: this method gets called on "deactivate" click
	# it should somehow notify the audio code to clean up the sound
	removeSound: ->
		@sound = false
	activate: ->
	deactivate: ->
	setInstrument: (parameters) ->
	select: (state=true) ->
		if state
			if cells.selected? then cells.selected.select(false)
			@shape.attr stroke: select_color, 'stroke-width': 4
			cells.selected = @
			Phon.Elements.$paper.trigger 'cell-selected', [@]
		else
			@shape.attr stroke: "#000", 'stroke-width': 1
	activate: ->
		#phon.activate @row, @col
		# show activation pending cell state (until server responds & sets)
	deactivate: ->
		#phon.deactivate @row, @col
		# show deactivation pending state (until server responds & sets)
	setInstrument: (parameters) ->
		#phon.setInstrument @row, @col, parameters
		# show instrument settings pending state (until server responds & sets)
	occupy: (state) ->
		if state is true
			@shape.attr fill: particle_color
		else
			@shape.attr fill: cell_colors[@state]
			
class Emitter




class StateHash
	constructor: ->
		@h			= {}
		@lastBeat	= []
		@thisBeat	= []
	add: (particle) ->
		index = "#{particle.row}_#{particle.col}_#{particle.state}"
		if not @h[index]
			@h[index]			= cells[index]
			@h[index].particles	= []
			@h[index].sums		= [0,0]
			@thisBeat.push index
		@h[index].sums[particle.excited] += particle.direction
		@h[index].particles.push particle
	reset: ->
		@h			= {}
		@lastBeat	= @thisBeat
		@thisBeat	= []





#### Probability Tools ####
Array::shuffle = -> @sort -> 0.5 - Math.random()
decays = {
	single: -> return Math.random()*100 < 50
	pair: -> return Math.random()*100 < 50
}


#### Looping Functions ####

init = ->
	occupied = new StateHash
	for row in [1..NUM_ROWS]
		for col in [1..NUM_COLS]
			cells["#{row}_#{col}_1"] = new Cell row, col, 1
			unless row is NUM_ROWS or col is NUM_COLS
				cells["#{row}_#{col}_2"] = new Cell row, col, 2

iterate = ->
	occupied.reset()
	toKill = []

	for particle in particles
		if particle.lifetime is 0
			toKill.push(particle)
		else
			particle.move()
			occupied.add(particle)

	if toKill.length > 0
		toKill.forEach((p) ->
			particles.splice(particles.indexOf(p), 1)
		)
	
	for cellIndex, cell of occupied.h
		if cell.state is 1						# Normal cell
			if cell.split
				# TODO / process split cells
			else 
				if cell.sums[1] or cell.particles.length > 1	# It's a collision! DUCK!!!!
					#log cell.sums
					collide(cell.sums, cell.particles)

				cell.particles.forEach((p) ->
					p.checkObstacles()		#just tack this on the end of collide()
				)
			
			if cell.active
				log "TODO / record note playback info"
		
		else	# Diamond, no processing
			#log "I'm a diamond!"
	return this:occupied.thisBeat, last:occupied.lastBeat



collide = (sums, particles) ->
	nSum	= sums[0]
	eSum	= sums[1]

	switch nSum
		when 1, 4, 8, 16				# 1 Normal
			switch eSum
				when 1, 4, 16, 64 then		# 1 Excited particle
					# result = {
					# 	1: {
					# 		4: 
					# 		16: 
					# 	},
					# 	4: {
							
					# 	}
					# }
				when 2, 8, 32, 128 then			# 2 Excited: Pair
					
		when 5, 10						# 2 Normal, Head-On
			switch eSum
				when 0						# 0 Excited
					particles.forEach((p) -> p.reverse())
		when 3, 6, 9, 12				# 2 Normal, 90 degree
			switch eSum
				when 0						# 0 Excited
					dir = {
						3:	1
						6:	4
						9:	64
						12:	16
					}[nSum]
					particles.forEach((p) ->
						p.excite()
						p.direction	= dir
					)
		when 7, 11, 13, 14				# 3 Normal, T-collide
			switch eSum
				when 0						# 0 Excited
					result = {
						7:	{kill: 2, dir: {4:4,	1:1}}
						11:	{kill: 1, dir: {2:1,	8:64}}
						13:	{kill: 8, dir: {1:64,	4:16}}
						14:	{kill: 4, dir: {8:16,	2:4}}
					}[nSum]
					particles.forEach((p) ->
						#log p
						p.excite()
						if p.direction is result.kill
							p.kill()
						else p.direction = result.dir[p.direction]
					)
		when 15							# 4 Normal, Plus-collide
			switch eSum
				when 0						# 0 Excited
					dirs = [1, 4, 16, 64].shuffle()
					particles.forEach((p) ->
						p.econsoxcite()
						p.direction = dirs.shift()
					)

		when 0							# 0 Normal Particles
			switch eSum
				when 1, 4, 16, 64			# 1 Excited particle
					if decays.single()
						#log eSum
						dirs = {
							1:		[1,	2]
							4:		[2,	4]
							16:		[4,	8]
							64:		[8,	1]
						}[eSum].shuffle()
						particles.forEach((p) ->
							p.decay()
							p.direction = dirs.shift()
						)
				when 2, 8, 32, 128			# 2 Excited: Pair
					if decays.pair()
						dirs = {
							2:		[1,	2]
							8:		[2,	4]
							32:		[4,	8]
							128:	[8,	1]
						}[eSum].shuffle()
						particles.forEach((p) ->
							p.decay()
							p.direction = dirs.shift()
						)
				when 17, 64					# 2 Excited: Head-On 
					dirs = [[2, 8], [1, 4]].shuffle().shift().shuffle()

