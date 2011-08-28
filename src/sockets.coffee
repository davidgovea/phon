
socket = null

Phon.Socket.on 'wall', (data) ->
	log data
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
