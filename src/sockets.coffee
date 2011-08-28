
socket = null

Phon.Socket.on 'wall', (data) ->
	switch data.action
		when 'del'
			log data.index
			line = wallList[data.index]
			console.log wallList
			switch line.info.type
				when "wall"
					line.info.cells.forEach((cell)->
						cells["#{cell[0]}_#{cell[1]}_1"].walls -= cell[2]
					)
				when "split"
					cells["#{line.info.cell[0]}_#{line.info.cell[1]}_1"].split = 0
			line.remove()
			wallList[data.index]
		else
			xys = data.points
			vector.addWall xys[0][0], xys[0][1], xys[1][0], xys[1][1]

server = {
	delWall: (row1, col1, row2, col2) ->

		socket.emit 'wall', action: 'del', points: [[row1, col1],[row2, col2]]
	updateCell: (row, col, instrument, settings) ->
		if instrument is null
			socket.emit('cell', row: row, col: col, inst: null)
		else
			socket.emit 'cell', row: row, col: col, inst: instrument, settings: settings
	sendEffect: (effect, value) ->
		socket.emit 'effect', type: effect, value: value
}
