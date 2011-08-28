
#wrapper-start.coffee

window.Phon = {}
	
Phon.Properties =
	tick: 200

#Constants
NUM_ROWS	= 10
NUM_COLS	= 10
cells		= {}
particles	= []
occupied	= null

cell_colors	= {
	1: "#d1d1d1"
	2: "#00bb00"
}
particle_color	= "#cc0000"
select_color	= "#0000ff"

log = (msg) ->
	console.log msg

# Vector.coffee - grid stuff

Raphael.fn.octagon = (x, y, side, side_rad) ->
	p = this.path "M#{x+side_rad} #{y}l#{side} 0l#{side_rad} #{side_rad}l0 #{side}l#{-side_rad} #{side_rad}l#{-side} 0l#{-side_rad} #{-side_rad}l0 #{-side}l#{side_rad} #{-side_rad}z"
	return p

Raphael.fn.octogrid = (x, y, rows, cols, width) ->
	console.time('octogrid')
	side		= width / (1+Math.SQRT2)
	side_rad	= side / Math.SQRT2
	startx		= x
	starty		= y
	raph		= this


	class Oct
		constructor: (x, y, side, side_rad, @row, @col) ->
			@shape = raph.octagon x, y, side, side_rad
			@shape.click @onClick
			@shape.dblclick @onDblClick
		row: 0
		col: 0
		onClick: (evt) =>
			#catshirt - hook in here
			log cells["#{@row}_#{@col}_1"]
			cells["#{@row}_#{@col}_1"].select()
		onDblClick: (evt) =>
			log "dblclick #{@row},#{@col}"


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
				@dragLine.valid = true
				@dragLine.line = line
			else
				pathString = "M#{@shape.attrs.x+@shape.attrs.height/2} #{@shape.attrs.y+@shape.attrs.height/2}l#{x} #{y}"
				if @dragLine? then @dragLine.animate path: pathString, 20
				else @dragLine = @shape.paper.path pathString
				@dragLine.valid = false
			@dragLine.attr 'stroke-width', 5

		dragUp: =>
			if @dragLine? 
				log @dragLine.valid
				unless @dragLine.valid then @dragLine.remove()
				else
					# TODO - handle this
					#phon.addLink @row, @col, @row+@dragLine.line[1], @col+@dragLine.line[0], @dragLine
					#@dragLine.click
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
			cell = new Oct x, y, side, side_rad, row+1, col+1
			cell.shape.attr fill: cell_colors[1]

			cells["#{row+1}_#{col+1}_1"].shape = cell.shape

			unless row is 0 or col is 0
				diamond = new Diamond x, y, side, row, col
				diamond.shape.attr('fill', cell_colors[2])

				cells["#{row}_#{col}_2"].shape = diamond.shape
			
			x += width
		y += width

	console.timeEnd('octogrid')
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
	walls: 0
	active: false
	shape: null
	activate: ->
	deactivate: ->
	setInstrument: (parameters) ->
	select: (state=true) ->
		if state
			if cells.selected? then cells.selected.select(false)
			@shape.attr stroke: select_color, 'stroke-width': 3
			cells.selected = @
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

$ ->
	
	Defaults = {}
	
	Defaults.Instrument =
		
		Note:
			'a': 220
			'a#': 233.08
			'b': 246.94
			'c': 261.63
			'c#': 277.18
			'd': 293.66
			'd#': 311.13
			'e': 329.63
			'f': 349.23
			'f#': 369.99
			'g': 392.00
		
		Length:
			default: 100
			min: 0
			max: 100
			
	Defaults.Sample =

		Sample: ['kick', 'snare']

		Pitch:
			default: 440
			min: 0
			max: 1000

		Offset:
			default: 0
			min: 0
			max: 99
		
	Modules = {}

	Modules.Global = class extends Backbone.Model
		
		defaults:
			closed: false
		
		initialize: ->
			@gui = new DAT.GUI
			@gui.add(Phon.Properties, 'tick').min(0).max(300)
	
	Modules.Instrument = class extends Backbone.Model

		defaults:
			
			closed: true
			note: Defaults.Instrument.Note['a']
			length: Defaults.Instrument.Length.default

		initialize: ->
			
			@gui = new DAT.GUI
			@gui.add(@attributes, 'note').options(Defaults.Instrument.Note)
			@gui.add(@attributes, 'length').min(Defaults.Instrument.Length.min).max(Defaults.Instrument.Length.max)
			
	Modules.Sample = class extends Backbone.Model

		defaults:
			
			closed: true
			sample: Defaults.Sample.Sample[0]
			pitch: Defaults.Sample.Pitch.default
			offset: Defaults.Sample.Offset.default

		initialize: ->
			
			@gui = new DAT.GUI
			controller = @gui.add(@attributes, 'sample')
			controller.options.apply(controller, Defaults.Sample.Sample)
			@gui.add(@attributes, 'pitch').min(Defaults.Sample.Pitch.min).max(Defaults.Sample.Pitch.max)
			@gui.add(@attributes, 'offset').min(Defaults.Sample.Offset.min).max(Defaults.Sample.Offset.max)
			
	Sidebar = class extends Backbone.Model

		defaults:
			active: false
			
	SidebarView = class extends Backbone.View
	
		el: '#sidebar'
	
		events:
			'click h2': 'toggle_content'
			
		initialize: (options) ->
			
			_.bindAll this
			
			# views store options as properties anyway
			# but for some reason they arent accessible in constructor?
			model = options.model
			
			$('.module', @el).each ->
				
				$module = $(this)
				module = new Modules[$module.attr 'data-module']
				
				# store reference to the model in DOM to be easily accessed from events
				$module.data 'model', module
				
				# move DAT.GUI into container
				$('.content', $module).append module.gui.domElement
				
				# setting the closed property on the module
				# shows it and sets it as active
				module.bind 'change:closed', (module, closed) =>
					$module[if closed then 'removeClass' else 'addClass']('open')
					if not closed
						model.set active: module
				
				# setting a new active module closes old active module
				model.bind 'change:active', (sidebar, active) ->
					prev = sidebar.previous('active')
					if prev
						prev.set closed: true
				
		# shows / hides the current sidebar module
		toggle_content: (e) ->
			
			$module = $(e.target).closest('.module')
			model = $module.data('model')
			active = @model.get 'active'
			
			# module can have a "persistent" class to refuse closing
			if $module.hasClass('persistent')
				return false
			
			# set property/display on new module
			model.set 'closed': !(model.get 'closed')
	
	# init sidebar
	new SidebarView
	 	model: new Sidebar
#wrapper-end.coffee

doLoop = ->
	# console.time 'loop'

	o = iterate()

	o.last.forEach((index)->
		cells[index].occupy false
	)
	o.this.forEach((index)->
		cells[index].occupy true
	)
	setTimeout doLoop, Phon.Properties.tick
	console.timeEnd 'loop'



#####TESTING#####TESTING#####

window.doLoop = doLoop
window.particles = particles
window.cells = cells
setTimeout(->
	init()
	paper = Raphael("paper", 1200, 800)
	paper.octogrid(1,1,NUM_ROWS,NUM_COLS,32);
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