#Constants
NUM_ROWS	= 10
NUM_COLS	= 10
cells		= {}
particles	= []

class Particle
	constructor: (@row, @col, @state, @direction, lifetime) ->
		@lifetime = lifetime ? 16
	excited: 0
	move: ->
		if @state is 1							# On a standard cell
			unless @excited						# Normal Horiz/Vert particle
				switch @direction
					when 1 then @col++
					when 2 then @row++
					when 4 then @col--
					when 8 then @row--
					else throw new Error "Don't know where to go! Normal particle: [#{@row},#{@col}], direction #{direction}"
			else								# Energetic particle
				switch @direction	
					when 1 then
					when 4 then @col--
					when 16 
						@row--
						@col--
					when 64 then @row--
					else throw new Error "Don't know where to go! Energetic particle, normal space: [#{@row},#{@col}], direction #{direction}"
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
			if @direction > 64 then @direction = @direction >> 

	checkObstacles: ->
		unless @excited
			if (@row is and @direction is 8) or
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
	walls: 0
	active: false

class StateHash
	@constructor: ->
		@h = {}
	add: (particle) ->
		index = "#{particle.row}_#{particle.col}_#{particle.state}"
		if not @h[index]
			@h[index]			= cells[index]
			@h[index].particles	= []
			@h[index].sums		= [0,0]
		@h[index].sums[particle.excited - 1] += particle.direction
		@h[index].particles.push(particle)



init = ->
	for row in [1..NUM_ROWS]
		for col in [1..NUM_COLS]
			cells["#{row}_{col}_1"] = new Cell row, col, 1
			unless row is NUM_ROWS or col is NUM_COLS
				cells["#{row}_#{col}_2"] = new Cell row, col, 2

iterate = ->


collide = (sums, particles) ->