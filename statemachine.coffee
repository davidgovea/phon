((exports) ->


	NUM_ROWS	= 18
	NUM_COLS	= 24
	exports.cells = {}


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

		checkObstacles: (repeat=false)->
			unless @excited
				if (@row is 1 and @direction is 8) or
				(@row is NUM_ROWS and @direction is 2) or
				(@col is 1 and @direction is 4) or
				(@col is NUM_COLS and @direction is 1)
					unless repeat then @reverse()			# Grid boundary detection, normal particles
					else @lifetime = 0
				else if cells["#{@row}_#{@col}_1"].walls & @direction
					unless repeat then @reverse()
					else @lifetime = 0
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


	exports.init = ->
		for row in [1..NUM_ROWS]
			for col in [1..NUM_COLS]
				cells["#{row}_#{col}_1"] = new Cell row, col, 1
				unless row is NUM_ROWS or col is NUM_COLS
					cells["#{row}_#{col}_2"] = new Cell row, col, 2



)(exports)