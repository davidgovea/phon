
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
			@shape	= raph.rect x-side/2, y-side/2, side, side
			@shape.center	= [x, y]
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

				pathString = "M#{@shape.attrs.x+@shape.attrs.height/2} #{@shape.attrs.y+@shape.attrs.height/2}l#{line[0]*(width+3)} #{line[1]*(width+3)}"
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
				unless @dragLine.valid then @dragLine.remove()
				else
					server.newWall @row, @col, @row+@dragLine.line[1], @col+@dragLine.line[0]
					vector.addWall @row, @col, @row+@dragLine.line[1], @col+@dragLine.line[0], true
					@dragLine.remove()
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
				diamond = new Diamond x-1.5, y-1.5, side, row, col
				diamond.shape.attr('fill', cell_colors[2])

				cells["#{row}_#{col}_2"].shape = diamond.shape
			
			x += width+3
		y += width+3

	console.timeEnd('octogrid')


paper = null

vector = {
	init: ->
		paper = Raphael("paper", (NUM_COLS+2)*(CELL_SIZE+3), (NUM_ROWS+2)*(CELL_SIZE+3))
		paper.octogrid(1,1,NUM_ROWS,NUM_COLS,CELL_SIZE);
	addWall: (row1, col1, row2, col2, pending=false) ->
		cell1		= cells["#{row1}_#{col1}_2"]
		cell2		= cells["#{row2}_#{col2}_2"]
		rowdiff		= row1-row2
		coldiff		= col1-col2
		if col1 >= col2
			upperCol = col1
			order	= [row1, col1, row2, col2]
		else
			upperCol = col2
			order = [row2, col2, row1, col1]
		if row1 >= row2 
			upperRow = row1
			if row1 isnt row2 then order = [row1, col1, row2, col2]
		else
			upperRow = row2
			order = [row2, col2, row1, col1]

		log cell1
		log cell2
		line 		= paper.path("M#{cell1.shape.center[0]} #{cell1.shape.center[1]}L#{cell2.shape.center[0]} #{cell2.shape.center[1]}")
		cell1.shape.toFront()
		cell2.shape.toFront()

		index = "#{order[0]}_#{order[1]}_#{order[2]}_#{order[3]}"
		walls[index] = line

		if rowdiff is coldiff
			toSplit = [upperRow, upperCol, 1]
		else if rowdiff is -coldiff
			toSplit = [upperRow, upperCol, 2]
		else if rowdiff is 0
			walls = [[upperRow, upperCol, 2], [upperRow+1, upperCol, 8]]
		else
			walls = [[upperRow, upperCol, 1], [upperRow, upperCol, 4]]
		
		if pending
			setTimeout ->
				line.remove()
				walls[index] = null
			, 3000
		else
			if toSplit? 
				cells["#{toSplit[0]}_#{toSplit[1]}_1"].split = toSplit[2]
			else if walls?
				walls.forEach((cell) ->
					cells["#{cell[0]}_#{cell[1]}_1"].walls += cell[2]
				)
}

