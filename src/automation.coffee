
#automation.coffee

class Particle
	constructor: (@row, @col, @state, @direction, lifetime) ->
		@lifetime = lifetime ? 32
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

	splitReverse: (splitMode) ->
		results = {
			1: 
				1: 2
				8: 4
				4: 8
				2: 1
				excited:
					1:1
					16:16
					64:4
					4:64
			2:
				1: 8
				2: 4
				4: 2
				8: 1
				excited: 
					4: 4
					64: 64
					16: 1
					1: 16
		}[splitMode]
		@direction = if @excited then results.excited[@direction] else results[@direction]
		if @excited then @direction = results.excited[@direction]
		else
		
	checkObstacles: (repeat=false, split=0)->
		unless @excited
			if (@row is 1 and @direction is 8) or
			(@row is NUM_ROWS and @direction is 2) or
			(@col is 1 and @direction is 4) or
			(@col is NUM_COLS and @direction is 1)
				unless repeat 
					@reverse()
					if split then @splitReverse split
					@checkObstacles true		# Grid boundary detection, normal particles
				else @lifetime = 0
			else if cells["#{@row}_#{@col}_1"].walls & @direction
				unless repeat 
					@reverse()
					if split then @splitReverse split
					@checkObstacles true
				else @lifetime = 0
		else if @state is 1
			if (@row is 1 and (@direction is 16 or @direction is 64)) or
			(@row is NUM_ROWS and (@direction is 1 or @direction is 4)) or
			(@col is 1 and (@direction is 4 or @direction is 16)) or
			(@col is NUM_COLS and (@direction is 1 or @direction is 64))
				@reverse()						# Grid boundary detection, excited particles
				if split then @splitReverse split
			

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
		@activate()
		@sound = sound
	# ckpcw: this method gets called on "deactivate" click
	# it should somehow notify the audio code to clean up the sound
	removeSound: ->
		@setActive false
		@sound = null
	activate: (sound) ->
		@active = true
		@sound = sound
		@shape.attr fill: "#0f0"
	deactivate: ->
		@active = false
		@shape.attr fill: cell_colors[@state]
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
	setActive: (state=true) ->
		if state is true
			@shape.attr fill: note_color
		else
			@shape.attr fill: cell_colors[@state]
		@active = state
	occupy: (state) ->
		if state is true
			@shape.attr fill: particle_color
		else if @active
			@shape.attr fill: note_color
		else
			@shape.attr fill: cell_colors[@state]
			

emitterHash = {}
emitter_every = 7
emitter_periods = [8, 16, 32, 16]
emitter_counter = 0
emitter_counter2 = 0
emitter_counter3 = Math.floor(emitter_every/2)

class Emitter
	constructor: (@row, @col, @period, @direction) ->
	index: 0
	step: ->
		@index++
		if @index is @period 
			@index = 0
			@emit()
	setIndex: (num) ->
		@index = num % @period
	emit: ->
		particle = new Particle @row, @col, 1, @direction
		occupied.add particle
		particles.push particle



class StateHash
	constructor: ->
		@h			= {}
		@lastBeat	= []
		@thisBeat	= []
	add: (particle) ->
		index = "#{particle.row}_#{particle.col}_#{particle.state}"
		if not @h[index]
		#	log index
			@h[index]			= cells[index]
			@h[index].particles	= []
			@h[index].sums		= [0,0]
			@thisBeat.push index
		if @h[index].split
			dir = particle.direction
			@h[index].sums = [0,0,0,0]
			if @h[index].split is 1
				if not(particle.excited is 1 and (dir is 1 or dir is 16))
					if dir is 1 or dir is 8 or dir is 64
						@h[index].sums[particle.excited] += dir
					else
						@h[index].sums[2+particle.excited] += dir
			else
				if not(particle.excited is 1 and (dir is 4 or dir is 64))
					if dir is 1 or dir is 2
						@h[index].sums[particle.excited] += dir
					else
						@h[index].sums[2+particle.excited] += dir
		else
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
	headon: -> return Math.random()*100 < 15
}


#### Looping Functions ####

init = ->
	occupied = new StateHash
	for row in [1..NUM_ROWS]
		if row is 1 
			emitter_counter = 0
		else if row is NUM_ROWS  
			emitter_counter = Math.floor(emitter_every/2)
		for col in [1..NUM_COLS]
			cells["#{row}_#{col}_1"] = new Cell row, col, 1
			unless row is NUM_ROWS or col is NUM_COLS
				cells["#{row}_#{col}_2"] = new Cell row, col, 2
			if row is 1
				emitter_counter++
				if emitter_counter is emitter_every
					emitter_counter = 0
					period = emitter_periods.shift()
					emitterHash["#{row}_#{col}"] = new Emitter row, col, period, 2
					emitter_periods.push period
			else if row is NUM_ROWS
				emitter_counter++
				if emitter_counter is emitter_every
					emitter_counter = 0
					period = emitter_periods.shift()
					emitterHash["#{row}_#{col}"] = new Emitter row, col, period, 8
					emitter_periods.push period
			else if col is 1
				emitter_counter2++
				if emitter_counter2 is emitter_every
					emitter_counter2 = 0
					period = emitter_periods.shift()
					emitterHash["#{row}_#{col}"] = new Emitter row, col, period, 1
					emitter_periods.push period	
			else if col is NUM_COLS
				emitter_counter3++
				if emitter_counter3 is emitter_every
					emitter_counter3 = 0
					period = emitter_periods.shift()
					emitterHash["#{row}_#{col}"] = new Emitter row, col, period, 4
					emitter_periods.push period	
	
	setNotes = ->
		leadCount = 0
		bassCount = 0
		notes = doLoop()
		log notes
		for note in notes
			if note.type == "Lead" && leadCount < 4
				leads[leadCount].frequency = Note.fromLatin(note.pitch.toUpperCase()+'4').frequency()
				log note
				leadCount++
		
		return {
			leads: leadCount
			bass: bassCount
		}
			

	bCount = 0

	enabled = setNotes()
	fillBuffer = (buf, channelCount) ->
		l = buf.length

		for i in [0...l] by channelCount
			bCount++
			smpl = 0
			if bCount is noteLength
				enabled = setNotes()
				bCount = 0

			for lead in [0...enabled.leads]
				leads[lead].generate()
				smpl += leads[lead].getMix()

			for n in [0...channelCount]
				buf[i+n] = smpl
		
		
			


		

			
				
				




	dev	= audioLib.AudioDevice(fillBuffer, 2)
	sampleRate = dev.sampleRate
	noteLength = sampleRate * 0.001 * 200
	reverb	= new audioLib.Reverb(sampleRate, 2)
	drum1	= new audioLib.Sampler(sampleRate)
	drum2	= new audioLib.Sampler(sampleRate)
	leads	= [new audioLib.Oscillator(sampleRate, 440),new audioLib.Oscillator(sampleRate, 440),new audioLib.Oscillator(sampleRate, 440),new audioLib.Oscillator(sampleRate, 440)]
	bass	= [new audioLib.Oscillator(sampleRate, 440),new audioLib.Oscillator(sampleRate, 440),new audioLib.Oscillator(sampleRate, 440)]


	
		

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
	
	for emitIndex, emit of emitterHash
	 	emit.step()

	toPlay = []
	for cellIndex, cell of occupied.h
		if cell.state is 1						# Normal cell
			if cell.split
				processSplit cell.split, cell.sums, cell.particles
				cell.particles.forEach((p) ->
					p.checkObstacles(false, cell.split)
				)
			else 
				if cell.sums[1] or cell.particles.length > 1	# It's a collision! DUCK!!!!
					#log cell.sums
					collide(cell.sums, cell.particles)
				cell.particles.forEach((p) ->
					p.checkObstacles()		#just tack this on the end of collide()
				)
			
			if cell.active
				toPlay.push(cell.sound)
		#else # Diamond, no processing
			#log "I'm a diamond!"
	return this:occupied.thisBeat, last:occupied.lastBeat, sounds:toPlay


processSplit = (split, sums, particles) ->
	nSum1 = sums[0]
	eSum1 = sums[1]
	nSum2 = sums[2]
	eSum2 = sums[3]
	switch split
		when 1
			switch nSum1
				when 1, 8
					switch eSum1
						when 0
							particles.forEach((p) ->
								if p.direction is 1 or p.direction is 8
									p.splitReverse(split)
							)
						when 64 then
						when 128 then
				when 9 then
			switch nSum2
				when 2, 4
					switch eSum2
						when 0 
							particles.forEach((p) ->
								if p.direction is 2 or p.direction is 4
									p.splitReverse(split)
							)
						when 4 then
						when 8 then
				when 6 then
		when 2
			switch nSum1
				when 1, 2
					switch eSum1
						when 0
							particles.forEach((p) ->
								if p.direction is 1 or p.direction is 2
									p.splitReverse(split)
							)
						when 1 then
						when 2 then
				when 3 then
			switch nSum2
				when 4, 8
					switch eSum2
						when 0
							particles.forEach((p) ->
								if p.direction is 4 or p.direction is 8
									p.splitReverse(split)
							)
						when 16 then
						when 64 then
				when 12 then



collide = (sums, particles) ->
	nSum	= sums[0]
	eSum	= sums[1]
	console.time 'find'

	switch nSum
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
					return true
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
					return true
				when 17, 64					# 2 Excited: Head-On 
					dirs = [[2, 8], [1, 4]].shuffle().shift().shuffle()
					return true
				else
					particles.forEach((p) ->
						#p.decay()
					)
					return false
		when 1, 4, 8, 16				# 1 Normal
			switch eSum
				when 1, 4, 16, 64 		# 1 Excited particle
					# result = {
					# 	1: {
					# 		4: 
					# 		16: 
					# 	},
					# 	4: {
							
					# 	}
					# }
					return true
				when 2, 8, 32, 128 			# 2 Excited: Pair
					return true
		when 5, 10						# 2 Normal, Head-On
			switch eSum
				when 0						# 0 Excited
					# if decays.headon()
					# 	out = [[1,16],[4,64]].shuffle()
					# 	particles.forEach((p) ->
					# 		p.excite()
					# 		p.direction = out.pop()
					# 	)
					# else
					particles.forEach((p) -> p.reverse())
					return true
				#else alert 'unhandled 1'
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
					return true
				#else alert 'unhandled 2'
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
					return true
				#else alert 'unhandled 3'
		when 15							# 4 Normal, Plus-collide
			switch eSum
				when 0						# 0 Excited
					dirs = [1, 4, 16, 64].shuffle()
					particles.forEach((p) ->
						p.excite()
						p.direction = dirs.shift()
					)
					return true
				#else alert 'unhandled 4'
