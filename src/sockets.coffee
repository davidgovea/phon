
socket = null

initSockets = ->

	socket = io.connect()
	socket.on 'cell', (data) ->
		log data

	socket.on 'wall', (data) ->
		log data
	
	socket.on 'chat', (data) ->
		log data

newWall: (row1, col1, row2, col2) ->
	socket.emit 'wall', action: 'new', points: [[row1, col1],[row2, col2]]
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
	