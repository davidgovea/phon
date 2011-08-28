
socket = null

initSockets = ->

	socket = io.connect(3001)
	socket.on 'cell', (data) ->
		log data

	socket.on 'wall', (data) ->
		log data
		xys = data.points
		vector.addWall xys[0], xys[1], xys[2], xys[3]

	
	socket.on 'chat', (data) ->
		log data

server = {
	newWall: (row1, col1, row2, col2) ->
		log "wall"
		socket.emit 'wall', action: 'new', points: [[row1, col1],[row2, col2]]
		vector.addWall row1, col1, row2, col2, true
	newSplit: (row1, col1, row2, col2) ->
		log "split"
		socket.emit 'wall', "test"
		vector.addWall row1, col1, row2, col2, true
	delWall: (row1, col1, row2, col2) ->

		socket.emit 'wall', action: 'del', points: [[row1, col1],[row2, col2]]
	updateCell: (row, col, instrument, settings) ->
		if instrument is null
			socket.emit('cell', row: row, col: col, inst: null)
		else
			socket.emit 'cell', row: row, col: col, inst: instrument, settings: settings
	sendChat: (userName, msg) ->
		socket.emit 'chat', user: userName, msg: msg
	sendEffect: (effect, value) ->
		socket.emit 'effect', type: effect, value: value
}
