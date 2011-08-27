
#Raphael = window.Raphael


Raphael.fn.octagon = (x, y, side, side_rad) ->
	p = this.path "M#{x+side_rad} #{y}l#{side} 0l#{side_rad} #{side_rad}l0 #{side}l#{-side_rad} #{side_rad}l#{-side} 0l#{-side_rad} #{-side_rad}l0 #{-side}l#{side_rad} #{-side_rad}z"
	return p



	
	

Raphael.fn.octogrid = (x, y, rows, cols, width, fill, diamondFill) ->
	console.time('octogrid')
	cellHash	= {}
	side		= width / (1+Math.SQRT2)
	side_rad	= side / Math.SQRT2
	startx		= x
	starty		= y
	raph		= this


	class Oct
		constructor: (x, y, side, side_rad, @row, @col) ->
			@shape = raph.octagon x, y, side, side_rad
		active: false
		row: 0
		col: 0
		fill: (color) ->
			@shape.attr('fill', color)
		activate: ->
			@active = true
		deactivate: ->
			@active = false

	class Diamond
		constructor: (x, y, side, @row, @col)->
			@shape = raph.rect x-side/2, y-side/2, side, side
			@shape.rotate 45
			@shape.drag @dragMove, @dragStart, @dragUp
		row: 0
		col: 0
		dragLine: null
		dragStart: =>
			@shape.attr opacity: 0.5
		dragMove: (x, y) =>
			if Math.abs(x) > width*.6 or Math.abs(y) > width*.6
				target = @getAngle x, y
				if @row is 1 and (target is 5 or target is 6 or target is 7) then return false
				else if @col is 1 and (target is 3 or target is 4 or target is 5) then return false
				else if @row is (rows-1) and (target is 1 or target is 2 or target is 3) then return false
				else if @col is (cols-1) and (target is 0 or target is 1 or target is 7) then return false
				else line = @neighbors[target]

				pathString = "M#{@shape.attrs.x+@shape.attrs.height/2} #{@shape.attrs.y+@shape.attrs.height/2}l#{line[0]*width} #{line[1]*width}"
				if @dragLine? then @dragLine.animate path: pathString, 20
				else @dragLine = @shape.paper.path pathString
				@dragLine.valid = true;
			else
				pathString = "M#{@shape.attrs.x+@shape.attrs.height/2} #{@shape.attrs.y+@shape.attrs.height/2}l#{x} #{y}"
				log pathString
				if @dragLine? then @dragLine.animate path: pathString, 20
				else @dragLine = @shape.paper.path pathString
				@dragLine.valid = false
			@dragLine.attr 'stroke-width', 5

		dragUp: =>
			if not @dragLine.valid then @dragLine.remove()
			@dragLine = null
			@shape.attr opacity: 1
		getAngle: (x, y)->
			i		= 1
			target	= 0
			atan	= Math.atan(y/x)/(Math.PI/180)
			inc		= 22.5
			if x < 0 then atan += 180
			else if y < 0 then atan += 360

			while i*inc < atan
				target	+= 1
				i		+= 2
			return if target > 7 then target % 8 else target
		neighbors: {
			0: [1,0]
			1: [1,1]
			2: [0,1]
			3: [-1,1]
			4: [-1,0]
			5: [-1,-1]
			6: [0,-1]
			7: [1,-1]
		}



	for row in [0...rows]
		x = startx
		for col in [0...cols]
			cell = new Oct x, y, side, side_rad, row, col
			cell.shape.attr('fill', fill)

			cellHash["#{row+1}_#{col+1}_1"] = cell

			unless row is 0 or col is 0
				diamond = new Diamond x, y, side, row, col
				diamond.shape.attr('fill', diamondFill)

				cellHash["#{row}_#{col}_2"] = diamond
			
			x += width
		y += width

	console.timeEnd('octogrid')
	return cellHash

















#Constants
NUM_ROWS	= 10
NUM_COLS	= 10
cells		= {}
particles	= []


##DEV##DEV##DEV##DEV##DEV##
log = (msg) ->
	console.log msg
##DEV##DEV##DEV##DEV##DEV##

#### Classes #### 

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
	walls: 0
	active: false

class StateHash
	constructor: ->
		@h = {}
	add: (particle) ->
		index = "#{particle.row}_#{particle.col}_#{particle.state}"
		if not @h[index]
			@h[index]			= cells[index]
			@h[index].particles	= []
			@h[index].sums		= [0,0]
		@h[index].sums[particle.excited] += particle.direction
		@h[index].particles.push(particle)


#### Probability Tools ####
Array::shuffle = -> @sort -> 0.5 - Math.random()
decays = {
	single: -> return Math.random()*100 < 50
	pair: -> return Math.random()*100 < 50
}


#### Looping Functions ####

init = ->
	for row in [1..NUM_ROWS]
		for col in [1..NUM_COLS]
			cells["#{row}_#{col}_1"] = new Cell row, col, 1
			unless row is NUM_ROWS or col is NUM_COLS
				cells["#{row}_#{col}_2"] = new Cell row, col, 2

iterate = ->
	occupied	= new StateHash
	toKill		= []

	for particle, index in particles
		if particle.lifetime is 0
			toKill.push(index)
		else
			particle.move()
			occupied.add(particle)
	
	
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
	return occupied


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
						log eSum
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

devList = []
doLoop = ->
	devList.forEach((cell) ->
		raphGrid[cell].shape.attr("fill", "#ccc")
	)
	devList = []

	o = iterate()

	for ind,cell of o.h
		#log cell
		raphGrid["#{cell.row}_#{cell.col}_#{cell.state}"].shape.attr('fill', '#0f0')
		devList.push("#{cell.row}_#{cell.col}_#{cell.state}")
	
	setTimeout doLoop, 500



#####TESTING#####TESTING#####

window.doLoop = doLoop
window.particles = particles
window.cells = cells
setTimeout(->
	paper = Raphael("paper", 800, 800)
	window.raphGrid = paper.octogrid(10,10,10,10,32,'#d1d1d1', '#0f0');
	init()
	particles.push(
		new Particle(3,2,1,1), 
		new Particle(5,4,1,8), 
		new Particle(3,6,1,4),
		new Particle(9,10,1,4),
		new Particle(6,6,1,8),
		new Particle(7,2,1,1),
		new Particle(4,5,1,2)
	)
	doLoop()

, 2000)

