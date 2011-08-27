
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